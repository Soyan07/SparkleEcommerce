using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Sparkle.Infrastructure;
using Sparkle.Domain.Support;
using System.Security.Claims;

namespace Sparkle.Api.Hubs;

/// <summary>
/// SignalR Hub for real-time chat between Users and Sellers.
/// </summary>
[Authorize]
public class ChatHub : Hub
{
    private readonly ApplicationDbContext _db;
    private readonly ILogger<ChatHub> _logger;

    public ChatHub(ApplicationDbContext db, ILogger<ChatHub> logger)
    {
        _db = db;
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userId))
        {
            // Join user-specific group for receiving messages
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
            
            // Check if user is a seller and join seller group
            var seller = await _db.Sellers.FirstOrDefaultAsync(s => s.UserId == userId);
            if (seller != null)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"seller_{seller.Id}");
            }
            
            _logger.LogInformation("User {UserId} connected to ChatHub", userId);
        }
        
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"user_{userId}");
            
            var seller = await _db.Sellers.FirstOrDefaultAsync(s => s.UserId == userId);
            if (seller != null)
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"seller_{seller.Id}");
            }
            
            _logger.LogInformation("User {UserId} disconnected from ChatHub", userId);
        }
        
        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Send a message in an existing chat.
    /// </summary>
    public async Task SendMessage(int chatId, string content, string? attachmentUrl = null, string? attachmentName = null)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId) || (string.IsNullOrWhiteSpace(content) && string.IsNullOrEmpty(attachmentUrl)))
        {
            await Clients.Caller.SendAsync("Error", "Invalid message");
            return;
        }

        var chat = await _db.Chats
            .Include(c => c.Seller)
            .FirstOrDefaultAsync(c => c.Id == chatId);
        
        if (chat == null)
        {
            await Clients.Caller.SendAsync("Error", "Chat not found");
            return;
        }

        // Verify user is part of this chat
        bool isSeller = chat.Seller.UserId == userId;
        bool isUser = chat.UserId == userId;
        
        if (!isSeller && !isUser)
        {
            await Clients.Caller.SendAsync("Error", "Unauthorized");
            return;
        }

        // Determine message type based on attachment
        var msgType = "Text";
        if (!string.IsNullOrEmpty(attachmentUrl))
        {
            var imageExts = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };
            msgType = imageExts.Any(e => attachmentUrl.EndsWith(e, StringComparison.OrdinalIgnoreCase)) ? "Image" : "File";
        }

        // Create and save the message
        var message = new ChatMessage
        {
            ChatId = chatId,
            SenderId = userId,
            IsSeller = isSeller,
            Content = (content ?? "").Trim(),
            MessageType = msgType,
            AttachmentUrl = attachmentUrl,
            AttachmentName = attachmentName,
            SentAt = DateTime.UtcNow
        };

        _db.ChatMessages.Add(message);
        
        // Update chat metadata
        chat.LastMessageAt = DateTime.UtcNow;
        if (isSeller)
            chat.UserUnreadCount++;
        else
            chat.SellerUnreadCount++;

        await _db.SaveChangesAsync();

        // Prepare message DTO for transmission
        var sender = await _db.Users.FindAsync(userId);
        var messageDto = new
        {
            Id = message.Id,
            ChatId = chatId,
            SenderId = userId,
            SenderName = sender?.FullName ?? "Unknown",
            IsSeller = isSeller,
            Content = message.Content,
            MessageType = message.MessageType,
            AttachmentUrl = message.AttachmentUrl,
            AttachmentName = message.AttachmentName,
            SentAt = message.SentAt.ToString("o"),
            IsRead = false,
            IsDeleted = false
        };

        // Send to both parties
        await Clients.Group($"user_{chat.UserId}").SendAsync("ReceiveMessage", messageDto);
        await Clients.Group($"seller_{chat.SellerId}").SendAsync("ReceiveMessage", messageDto);
        
        _logger.LogInformation("Message sent in chat {ChatId} by {UserId}", chatId, userId);
    }

    /// <summary>
    /// Start a new chat with a seller (for users).
    /// </summary>
    public async Task StartChat(int sellerId, int? productId, string initialMessage)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId) || string.IsNullOrWhiteSpace(initialMessage))
        {
            await Clients.Caller.SendAsync("Error", "Invalid request");
            return;
        }

        var seller = await _db.Sellers.FindAsync(sellerId);
        if (seller == null)
        {
            await Clients.Caller.SendAsync("Error", "Seller not found");
            return;
        }

        // Check if chat already exists
        var existingChat = await _db.Chats
            .FirstOrDefaultAsync(c => c.UserId == userId && c.SellerId == sellerId && c.Status == "Active");
        
        Chat chat;
        if (existingChat != null)
        {
            chat = existingChat;
        }
        else
        {
            // Create new chat
            chat = new Chat
            {
                UserId = userId,
                SellerId = sellerId,
                ProductId = productId,
                Status = "Active",
                StartedAt = DateTime.UtcNow,
                LastMessageAt = DateTime.UtcNow,
                SellerUnreadCount = 1
            };
            
            _db.Chats.Add(chat);
            await _db.SaveChangesAsync();
        }

        // Add the initial message
        var message = new ChatMessage
        {
            ChatId = chat.Id,
            SenderId = userId,
            IsSeller = false,
            Content = initialMessage.Trim(),
            MessageType = "Text",
            SentAt = DateTime.UtcNow
        };

        _db.ChatMessages.Add(message);
        chat.LastMessageAt = DateTime.UtcNow;
        chat.SellerUnreadCount++;
        
        await _db.SaveChangesAsync();

        // Notify both parties
        var sender = await _db.Users.FindAsync(userId);
        var chatDto = new
        {
            ChatId = chat.Id,
            SellerId = sellerId,
            SellerName = seller.ShopName,
            ProductId = productId,
            LastMessage = message.Content,
            LastMessageAt = chat.LastMessageAt.ToString("o")
        };

        await Clients.Group($"user_{userId}").SendAsync("ChatStarted", chatDto);
        await Clients.Group($"seller_{sellerId}").SendAsync("NewChat", chatDto);
        
        _logger.LogInformation("New chat started between user {UserId} and seller {SellerId}", userId, sellerId);
    }

    /// <summary>
    /// Mark messages as read.
    /// </summary>
    public async Task MarkAsRead(int chatId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId)) return;

        var chat = await _db.Chats
            .Include(c => c.Seller)
            .FirstOrDefaultAsync(c => c.Id == chatId);
        
        if (chat == null) return;

        bool isSeller = chat.Seller.UserId == userId;
        bool isUser = chat.UserId == userId;
        
        if (!isSeller && !isUser) return;

        // Mark unread messages as read
        var unreadMessages = await _db.ChatMessages
            .Where(m => m.ChatId == chatId && !m.IsRead && m.SenderId != userId)
            .ToListAsync();

        foreach (var msg in unreadMessages)
        {
            msg.IsRead = true;
            msg.ReadAt = DateTime.UtcNow;
        }

        // Reset unread count
        if (isSeller)
            chat.SellerUnreadCount = 0;
        else
            chat.UserUnreadCount = 0;

        await _db.SaveChangesAsync();
        
        // Notify sender that messages were read
        await Clients.Group($"user_{chat.UserId}").SendAsync("MessagesRead", chatId);
        await Clients.Group($"seller_{chat.SellerId}").SendAsync("MessagesRead", chatId);
    }

    /// <summary>
    /// Typing indicator.
    /// </summary>
    public async Task Typing(int chatId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId)) return;

        var chat = await _db.Chats
            .Include(c => c.Seller)
            .FirstOrDefaultAsync(c => c.Id == chatId);
        
        if (chat == null) return;

        bool isSeller = chat.Seller.UserId == userId;
        
        // Notify the other party
        if (isSeller)
            await Clients.Group($"user_{chat.UserId}").SendAsync("UserTyping", chatId);
        else
            await Clients.Group($"seller_{chat.SellerId}").SendAsync("UserTyping", chatId);
    }
}

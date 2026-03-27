# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["Sparkle.sln", "."]
COPY ["Sparkle.Api/Sparkle.Api.csproj", "Sparkle.Api/"]
COPY ["Sparkle.Domain/Sparkle.Domain.csproj", "Sparkle.Domain/"]
COPY ["Sparkle.Infrastructure/Sparkle.Infrastructure.csproj", "Sparkle.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "Sparkle.sln"

# Copy entire source code
COPY . .

# Build the application
WORKDIR "/src/Sparkle.Api"
RUN dotnet build "Sparkle.Api.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "Sparkle.Api.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=publish /app/publish .

# Expose port 5000 for ASP.NET Core
EXPOSE 5000

# Set environment variable for ASP.NET Core to listen on all interfaces
ENV ASPNETCORE_URLS=http://+:5000

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=1 \
    CMD curl -f http://localhost:5000/health || exit 1

ENTRYPOINT ["dotnet", "Sparkle.Api.dll"]

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY Sparkle.sln .
COPY Sparkle.Api/Sparkle.Api.csproj Sparkle.Api/
COPY Sparkle.Domain/Sparkle.Domain.csproj Sparkle.Domain/
COPY Sparkle.Infrastructure/Sparkle.Infrastructure.csproj Sparkle.Infrastructure/

# Restore dependencies
RUN dotnet restore Sparkle.Api/Sparkle.Api.csproj

# Copy all source code
COPY . .

# Build and publish
WORKDIR /src/Sparkle.Api
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Create non-root user for security
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Sparkle.Api.dll"]

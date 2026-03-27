# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Clear NuGet cache to avoid corrupted package issues
RUN dotnet nuget locals all --clear

# Copy solution and project files for restore
COPY Sparkle.sln ./
COPY Sparkle.Api/Sparkle.Api.csproj Sparkle.Api/
COPY Sparkle.Domain/Sparkle.Domain.csproj Sparkle.Domain/
COPY Sparkle.Infrastructure/Sparkle.Infrastructure.csproj Sparkle.Infrastructure/
COPY NuGet.Config ./

# Restore the entire solution
RUN dotnet restore Sparkle.sln --configfile ./NuGet.Config

# Copy everything else
COPY . .

# Build and publish from the solution level for better consistency
RUN dotnet build Sparkle.sln -c Release --no-restore
RUN dotnet publish Sparkle.Api/Sparkle.Api.csproj -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENV PORT=8080

ENTRYPOINT ["dotnet", "Sparkle.Api.dll"]

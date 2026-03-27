# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

RUN dotnet nuget locals all --clear

COPY NuGet.Config ./
COPY Directory.Build.props ./

COPY Sparkle.sln .
COPY Sparkle.Api/Sparkle.Api.csproj Sparkle.Api/
COPY Sparkle.Domain/Sparkle.Domain.csproj Sparkle.Domain/
COPY Sparkle.Infrastructure/Sparkle.Infrastructure.csproj Sparkle.Infrastructure/

RUN dotnet restore Sparkle.Api/Sparkle.Api.csproj --configfile ./NuGet.Config

COPY . .

WORKDIR /src/Sparkle.Api
RUN dotnet publish -c Release -o /app/publish --no-restore

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

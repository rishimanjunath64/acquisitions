# Development Environment Startup Script for Windows

Write-Host "🚀 Starting Neon Local Development Environment..." -ForegroundColor Green
Write-Host ""

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    Write-Host "📝 Copying .env.development to .env..." -ForegroundColor Cyan
    Copy-Item .env.development .env
    Write-Host ""
    Write-Host "⚠️  Please update .env with your Neon credentials:" -ForegroundColor Yellow
    Write-Host "   - NEON_API_KEY" -ForegroundColor Yellow
    Write-Host "   - NEON_PROJECT_ID" -ForegroundColor Yellow
    Write-Host "   - ARCJET_KEY" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Start Docker Compose
docker-compose -f docker-compose.dev.yml up --build

# Cleanup on exit
Write-Host ""
Write-Host "🧹 Cleaning up..." -ForegroundColor Cyan
docker-compose -f docker-compose.dev.yml down

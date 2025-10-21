#!/bin/bash

# Development Environment Startup Script

echo "🚀 Starting Neon Local Development Environment..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
  echo "⚠️  .env file not found!"
  echo "📝 Copying .env.development to .env..."
  cp .env.development .env
  echo ""
  echo "⚠️  Please update .env with your Neon credentials:"
  echo "   - NEON_API_KEY"
  echo "   - NEON_PROJECT_ID"
  echo "   - ARCJET_KEY"
  echo ""
  exit 1
fi

# Start Docker Compose
docker-compose -f docker-compose.dev.yml up --build

# Cleanup on exit
echo ""
echo "🧹 Cleaning up..."
docker-compose -f docker-compose.dev.yml down

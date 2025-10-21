# Acquisitions API

A Node.js Express API with Neon Database integration, featuring ephemeral database branches for development and production-ready Docker configuration.

## 🚀 Quick Start

### Development (with Neon Local)

1. **Install prerequisites:**
   - Docker & Docker Compose
   - Neon account ([sign up here](https://console.neon.tech))

2. **Set up environment:**
   ```powershell
   # Windows PowerShell
   Copy-Item .env.development .env
   
   # Update .env with your Neon credentials:
   # - NEON_API_KEY (from https://console.neon.tech/app/settings/api-keys)
   # - NEON_PROJECT_ID (from Project Settings → General)
   # - ARCJET_KEY
   ```

3. **Start development environment:**
   ```powershell
   # Using the helper script
   .\start-dev.ps1
   
   # Or manually
   docker-compose -f docker-compose.dev.yml up --build
   ```

4. **Access the application:**
   - API: http://localhost:3000
   - Database: `postgres://neon:npg@localhost:5432/neondb`

### Production (with Neon Cloud)

1. **Set up production environment:**
   ```powershell
   Copy-Item .env.production .env.production.local
   
   # Update .env.production.local with your Neon Cloud connection string
   ```

2. **Deploy:**
   ```powershell
   docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d --build
   ```

## 📚 Documentation

For complete setup instructions, troubleshooting, and advanced configuration, see **[DOCKER-SETUP.md](./DOCKER-SETUP.md)**.

## 🏗️ Architecture

### Development Environment
```
┌─────────────────┐
│   Your App      │
│  (Node.js)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│  Neon Local     │─────▶│   Neon Cloud     │
│  (Docker Proxy) │      │  (Ephemeral      │
└─────────────────┘      │   Branch)        │
                         └──────────────────┘
```

- **Neon Local** creates ephemeral database branches
- Each container start = fresh database copy
- Automatic cleanup when container stops
- Optional: persist branches per Git branch

### Production Environment
```
┌─────────────────┐
│   Your App      │
│  (Node.js)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Neon Cloud    │
│  (Production DB)│
└─────────────────┘
```

- Direct connection to Neon Cloud
- No proxy layer
- Production-optimized configuration

## 🛠️ Available Scripts

### Local Development (without Docker)
```bash
npm run dev          # Start with hot-reload
npm run lint         # Check code style
npm run lint:fix     # Fix linting issues
npm run format       # Format code
npm run db:generate  # Generate database migrations
npm run db:migrate   # Run migrations
npm run db:studio    # Open Drizzle Studio
```

### Docker Commands
```powershell
# Development
docker-compose -f docker-compose.dev.yml up --build
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml logs -f app

# Production
docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d --build
docker-compose -f docker-compose.prod.yml logs -f app
docker-compose -f docker-compose.prod.yml down
```

## 📁 Project Structure

```
acquisitions/
├── src/
│   ├── config/           # Configuration files
│   │   ├── database.js   # Current database config
│   │   └── database.neon.js  # Neon Local compatible config
│   ├── controllers/      # Route controllers
│   ├── middleware/       # Express middleware
│   ├── models/          # Drizzle ORM models
│   ├── routes/          # API routes
│   ├── services/        # Business logic
│   ├── utils/           # Helper functions
│   ├── validations/     # Zod schemas
│   ├── app.js           # Express app setup
│   ├── server.js        # Server entry point
│   └── index.js         # Main entry point
├── drizzle/             # Database migrations
├── logs/                # Application logs
├── Dockerfile           # Docker image definition
├── docker-compose.dev.yml    # Development compose
├── docker-compose.prod.yml   # Production compose
├── .env.development     # Dev environment template
├── .env.production      # Prod environment template
├── start-dev.ps1        # Windows dev startup script
├── start-dev.sh         # Unix dev startup script
└── DOCKER-SETUP.md      # Detailed Docker documentation
```

## 🔒 Security Notes

- Never commit `.env`, `.env.production.local`, or any files with real secrets
- Use environment variables for all sensitive configuration
- Neon Local uses self-signed certificates (expected in development)
- Production should use secure Neon Cloud connection strings

## 🌿 Database Branching Workflow

Neon Local supports automatic branch-per-Git-branch:

```bash
# Checkout a Git branch
git checkout feature/new-endpoint

# Start Docker - automatically creates/uses a Neon branch for this Git branch
docker-compose -f docker-compose.dev.yml up

# Your database state is isolated per Git branch!
```

## 🔧 Environment Variables

### Development
| Variable | Description | Example |
|----------|-------------|---------|
| `NEON_API_KEY` | Neon API key | `neon_api_xxxxx` |
| `NEON_PROJECT_ID` | Your project ID | `purple-moon-12345` |
| `PARENT_BRANCH_ID` | Parent branch | `main` |
| `ARCJET_KEY` | Security key | `ajkey_xxxxx` |

### Production
| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | Neon Cloud URL | `postgresql://...@ep-xxxxx.neon.tech/...` |
| `ARCJET_KEY` | Security key | `ajkey_xxxxx` |

## 🐛 Troubleshooting

### "Connection refused" error
Wait for Neon Local to be healthy (usually 5-10 seconds):
```powershell
docker-compose -f docker-compose.dev.yml ps
```

### Database not migrating
Run migrations inside the container:
```powershell
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
```

### Ephemeral branches not cleaning up
Check `DELETE_BRANCH=true` in `.env` and ensure you're stopping containers properly.

For more troubleshooting, see [DOCKER-SETUP.md](./DOCKER-SETUP.md#troubleshooting).

## 📦 Tech Stack

- **Runtime**: Node.js 20
- **Framework**: Express.js
- **Database**: Neon (Serverless Postgres)
- **ORM**: Drizzle ORM
- **Validation**: Zod
- **Security**: Arcjet, Helmet, CORS
- **Logging**: Winston, Morgan
- **Containerization**: Docker, Docker Compose

## 🔗 Resources

- [Neon Documentation](https://neon.com/docs)
- [Neon Local Guide](https://neon.com/docs/local/neon-local)
- [Drizzle ORM Docs](https://orm.drizzle.team)
- [Express.js Guide](https://expressjs.com)

## 📄 License

ISC

---

**Made with 💚 using Neon Database**


testing ci/cd pipelines

# Docker Setup Guide with Neon Database

This guide explains how to run your application with Docker using different database configurations for development and production.

## Overview

- **Development**: Uses Neon Local proxy with ephemeral database branches
- **Production**: Connects directly to Neon Cloud Database

## Prerequisites

1. **Docker & Docker Compose** installed
2. **Neon Account** with a project created at [console.neon.tech](https://console.neon.tech)
3. **Neon API Key** - Get it from: [Neon Console → Account Settings → API Keys](https://console.neon.tech/app/settings/api-keys)
4. **Neon Project ID** - Found in: Project Settings → General

---

## Development Environment (Local with Neon Local)

### What is Neon Local?

Neon Local is a Docker proxy that creates ephemeral database branches automatically. Each time you start the container, it creates a fresh copy of your database. When you stop the container, the branch is deleted.

### Setup Steps

1. **Copy the development environment template:**

   ```bash
   cp .env.development .env
   ```

2. **Update `.env` with your Neon credentials:**

   ```env
   NEON_API_KEY=neon_api_xxxxxxxxxxxxx
   NEON_PROJECT_ID=your-project-id
   PARENT_BRANCH_ID=main
   ARCJET_KEY=your_arcjet_key
   ```

3. **Start the development environment:**

   ```bash
   docker-compose -f docker-compose.dev.yml up --build
   ```

   This will:
   - Start the Neon Local proxy
   - Create an ephemeral database branch from `main`
   - Start your application connected to the ephemeral branch
   - Enable hot-reloading (changes to `src/` are reflected immediately)

4. **Access your application:**
   - Application: http://localhost:3000
   - Database: `postgres://neon:npg@localhost:5432/neondb?sslmode=require`

5. **Stop the environment:**
   ```bash
   docker-compose -f docker-compose.dev.yml down
   ```
   The ephemeral database branch will be automatically deleted.

### Development Configuration Details

**docker-compose.dev.yml** includes:

- **neon-local service**: Proxy that manages ephemeral branches
  - Creates a new branch on startup
  - Deletes the branch on shutdown
  - Persists branch-per-git-branch (optional feature)
- **app service**: Your Node.js application
  - Connects to `neon-local:5432`
  - Source code mounted for hot-reloading
  - Runs with `npm run dev`

### Persistent Branches per Git Branch

The setup includes optional volume mounts that persist a unique branch for each Git branch:

```yaml
volumes:
  - ./.neon_local/:/tmp/.neon_local
  - ./.git/HEAD:/tmp/.git/HEAD:ro
```

This means:

- Each Git branch gets its own database branch
- Switching Git branches automatically switches database branches
- Branches persist across container restarts (unless `DELETE_BRANCH=true`)

---

## Production Environment (Neon Cloud)

### Setup Steps

1. **Copy the production environment template:**

   ```bash
   cp .env.production .env.production.local
   ```

2. **Update `.env.production.local` with your Neon Cloud credentials:**

   ```env
   NODE_ENV=production
   LOG_LEVEL=warn
   DATABASE_URL=postgresql://user:password@ep-xxxxx.neon.tech/neondb?sslmode=require
   ARCJET_KEY=your_arcjet_key
   ```

   > ⚠️ **Security**: Never commit `.env.production.local` to version control

3. **Start the production environment:**

   ```bash
   docker-compose -f docker-compose.prod.yml --env-file .env.production.local up --build -d
   ```

4. **Check logs:**

   ```bash
   docker-compose -f docker-compose.prod.yml logs -f app
   ```

5. **Stop the production environment:**
   ```bash
   docker-compose -f docker-compose.prod.yml down
   ```

### Production Configuration Details

**docker-compose.prod.yml** includes:

- **app service only**: No Neon Local proxy
  - Connects directly to Neon Cloud via `DATABASE_URL`
  - Production optimizations enabled
  - Health checks configured
  - Auto-restart policy

---

## Environment Variables Reference

### Development Variables (.env.development)

| Variable           | Description                          | Required | Default       |
| ------------------ | ------------------------------------ | -------- | ------------- |
| `NEON_API_KEY`     | Your Neon API key                    | Yes      | -             |
| `NEON_PROJECT_ID`  | Your Neon project ID                 | Yes      | -             |
| `PARENT_BRANCH_ID` | Parent branch for ephemeral branches | No       | `main`        |
| `DELETE_BRANCH`    | Auto-delete branches on shutdown     | No       | `true`        |
| `DATABASE_URL`     | Local database connection string     | No       | Auto-set      |
| `NODE_ENV`         | Environment mode                     | No       | `development` |
| `LOG_LEVEL`        | Logging verbosity                    | No       | `info`        |
| `ARCJET_KEY`       | Arcjet security key                  | Yes      | -             |

### Production Variables (.env.production)

| Variable       | Description                  | Required |
| -------------- | ---------------------------- | -------- |
| `DATABASE_URL` | Neon Cloud connection string | Yes      |
| `NODE_ENV`     | Environment mode             | Yes      |
| `LOG_LEVEL`    | Logging verbosity            | No       |
| `ARCJET_KEY`   | Arcjet security key          | Yes      |

---

## Database Connection Strings

### Development (Neon Local)

```
postgres://neon:npg@neon-local:5432/neondb?sslmode=require
```

- **Username**: `neon`
- **Password**: `npg`
- **Host**: `neon-local` (Docker service name)
- **Port**: `5432`

### Production (Neon Cloud)

```
postgresql://user:password@ep-xxxxx.neon.tech/neondb?sslmode=require
```

- Get this from Neon Console → Connection Details

---

## Troubleshooting

### Issue: "Connection refused" in development

**Solution**: Wait for Neon Local to be healthy. The app service has a `depends_on` healthcheck, but you can manually check:

```bash
docker-compose -f docker-compose.dev.yml ps
```

### Issue: Self-signed certificate error

**Solution**: This is expected with Neon Local. The connection string uses `sslmode=require` which is compatible with self-signed certificates. If using the `pg` library directly in Node.js, you may need:

```javascript
ssl: {
  rejectUnauthorized: false;
}
```

### Issue: Branches not cleaning up

**Solution**: Ensure `DELETE_BRANCH=true` in your `.env` file. Check orphaned branches:

```bash
# List all branches in your Neon project
curl -X GET https://console.neon.tech/api/v2/projects/{project_id}/branches \
  -H "Authorization: Bearer {api_key}"
```

### Issue: Production connection timeout

**Solution**: Verify your Neon Cloud connection string and ensure your deployment environment can reach `neon.tech` domains. Check firewall rules if running in a restricted network.

---

## Running Database Migrations

### Development

```bash
# Generate migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Production

```bash
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

---

## Best Practices

1. **Never commit secrets**: Keep `.env`, `.env.production.local` out of Git
2. **Use ephemeral branches**: Enable `DELETE_BRANCH=true` for clean dev environments
3. **Test before production**: Always test migrations on a development branch first
4. **Monitor connections**: Neon has connection limits - use pooling in production
5. **Use health checks**: Both compose files include health checks for reliability

---

## Additional Resources

- [Neon Local Documentation](https://neon.com/docs/local/neon-local)
- [Neon Branching Guide](https://neon.com/docs/guides/branching)
- [Drizzle ORM Documentation](https://orm.drizzle.team)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## Quick Commands Cheat Sheet

```bash
# Development
docker-compose -f docker-compose.dev.yml up --build        # Start dev environment
docker-compose -f docker-compose.dev.yml down              # Stop dev environment
docker-compose -f docker-compose.dev.yml logs -f app       # View app logs
docker-compose -f docker-compose.dev.yml exec app sh       # Shell into app container

# Production
docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d --build
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml logs -f app
docker-compose -f docker-compose.prod.yml exec app sh
```

---
name: docker-composer
description: Generate optimized Dockerfiles and docker-compose configurations for development and production environments.
---

# Docker Composer

## When to Use
- Setting up new projects with containers.
- Optimizing existing Docker configurations.
- Creating multi-service development environments.
- Preparing production-ready container images.

## Best Practices

### Dockerfile Optimization
1. **Use multi-stage builds** to reduce image size.
2. **Order layers by change frequency** (deps first, code last).
3. **Use specific base image tags**, not `latest`.
4. **Run as non-root user** for security.
5. **Use `.dockerignore`** to exclude unnecessary files.

### Base Image Selection
| Use Case | Recommended Base |
|----------|------------------|
| Python | python:3.12-slim |
| Node.js | node:20-alpine |
| Go | golang:1.22-alpine (build) + scratch/distroless (runtime) |
| Rust | rust:1.75-slim (build) + debian:slim (runtime) |
| Static files | nginx:alpine |

## Templates

### Python FastAPI
```dockerfile
# Build stage
FROM python:3.12-slim as builder

WORKDIR /app
RUN pip install uv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Runtime stage
FROM python:3.12-slim

WORKDIR /app
RUN useradd -r -s /bin/false appuser

COPY --from=builder /app/.venv /app/.venv
COPY src/ ./src/

ENV PATH="/app/.venv/bin:$PATH"
USER appuser

EXPOSE 8000
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js
```dockerfile
FROM node:20-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine

WORKDIR /app
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup

COPY --from=builder /app/node_modules ./node_modules
COPY dist/ ./dist/

USER appuser
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### docker-compose.yml Template
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: development
    ports:
      - "8000:8000"
    volumes:
      - ./src:/app/src:ro
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]

volumes:
  postgres_data:
  redis_data:
```

## .dockerignore Template
```
.git
.github
.env*
*.md
*.log
__pycache__
*.pyc
node_modules
.pytest_cache
.coverage
htmlcov
dist
build
*.egg-info
.venv
venv
```

## Workflow
1. **Identify services** needed (app, db, cache, etc.).
2. **Choose base images** appropriate for each service.
3. **Write Dockerfile** with multi-stage build.
4. **Create docker-compose.yml** with health checks.
5. **Add .dockerignore** to minimize context.
6. **Test locally** before pushing to registry.

## Output Checklist
- [ ] Multi-stage Dockerfile created.
- [ ] Non-root user configured.
- [ ] Health checks defined.
- [ ] Volumes for persistence.
- [ ] Environment variables documented.
- [ ] .dockerignore in place.

---
name: env-manager
description: Manage environment variables, secrets, and configuration across development, staging, and production environments.
---

# Environment Manager

## When to Use
- Setting up new project environments.
- Managing secrets and API keys.
- Synchronizing configs across environments.
- Documenting required environment variables.

## Environment Hierarchy
```
.env.example     # Template with all vars (committed)
.env.local       # Local overrides (gitignored)
.env.development # Development defaults (may be committed)
.env.staging     # Staging config (gitignored or secrets manager)
.env.production  # Production config (secrets manager only)
```

## Workflow

### 1. Document Variables
Create `.env.example` with all required variables:
```bash
# Application
APP_NAME=myapp
APP_ENV=development
DEBUG=false
LOG_LEVEL=info

# Server
HOST=0.0.0.0
PORT=8000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# External Services
# Get from: https://api.example.com/dashboard
API_KEY=your-api-key-here
API_SECRET=your-api-secret-here

# Optional
CACHE_TTL=3600
```

### 2. Validate Environment
```python
# Python with pydantic
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str
    app_env: str = "development"
    debug: bool = False
    database_url: str
    api_key: str

    class Config:
        env_file = ".env"

settings = Settings()
```

```typescript
// TypeScript with zod
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
});

export const env = envSchema.parse(process.env);
```

### 3. Secrets Management

#### Local Development
- Use `.env.local` for sensitive values.
- Never commit actual secrets.

#### CI/CD
- Use repository secrets (GitHub, GitLab).
- Inject at build/deploy time.

#### Production
| Provider | Tool |
|----------|------|
| AWS | Secrets Manager, Parameter Store |
| GCP | Secret Manager |
| Azure | Key Vault |
| Kubernetes | Secrets, External Secrets Operator |
| Self-hosted | HashiCorp Vault, Doppler |

### 4. Sync Across Environments
```bash
# Check for missing vars between environments
diff <(grep -v '^#' .env.example | cut -d= -f1 | sort) \
     <(grep -v '^#' .env.local | cut -d= -f1 | sort)
```

## Security Rules
1. **Never commit secrets** to version control.
2. **Use different values** per environment.
3. **Rotate secrets** regularly (90 days recommended).
4. **Audit access** to production secrets.
5. **Use least privilege** - only expose what's needed.

## .gitignore Template
```
# Environment files
.env
.env.local
.env.*.local
.env.staging
.env.production

# Keep example
!.env.example
```

## Output Checklist
- [ ] `.env.example` documents all variables.
- [ ] Validation schema implemented.
- [ ] Secrets stored securely (not in git).
- [ ] Different values per environment.
- [ ] `.gitignore` configured properly.
- [ ] Team has access to required secrets.

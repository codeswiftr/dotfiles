# ============================================================================
# Web Development and PWA Configuration
# Enhanced tooling for FastAPI + LitPWA development workflow
# ============================================================================

# FastAPI development aliases and functions
alias fapi="fastapi dev"
alias fapi-run="fastapi run"
alias fapi-prod="fastapi run --host 0.0.0.0 --port 8000"
alias fapi-docs="open http://localhost:8000/docs"
alias fapi-redoc="open http://localhost:8000/redoc"

# Advanced FastAPI development functions
fastapi-init() {
    local project_name=${1:-"fastapi-app"}
    local with_db=${2:-"true"}
    echo "🚀 Creating FastAPI project: $project_name"
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    # Initialize with uv
    uv init
    uv add fastapi uvicorn[standard] python-multipart python-jose[cryptography] passlib[bcrypt]
    uv add --dev pytest pytest-asyncio httpx pytest-cov ruff black
    
    # Add database dependencies if requested
    if [[ "$with_db" == "true" ]]; then
        echo "📊 Adding database support with SQLAlchemy and Alembic..."
        uv add sqlalchemy alembic psycopg2-binary python-decouple
    fi
    
    # Create basic FastAPI structure
    mkdir -p app tests
    cat > app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="My FastAPI App", version="1.0.0")

# CORS middleware for frontend development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello FastAPI!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
EOF
    
    cat > tests/test_main.py << 'EOF'
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello FastAPI!"}

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
EOF
    
    # Set up database configuration if requested
    if [[ "$with_db" == "true" ]]; then
        echo "🗄️  Setting up database configuration..."
        
        # Create database configuration
        cat > app/database.py << 'EOF'
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from decouple import config

# Database URL from environment variable
DATABASE_URL = config("DATABASE_URL", default="sqlite:///./app.db")

# Create SQLAlchemy engine
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

# Create SessionLocal class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create Base class
Base = declarative_base()

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOF

        # Create models directory and example model
        mkdir -p app/models
        cat > app/models/__init__.py << 'EOF'
from .user import User

__all__ = ["User"]
EOF

        cat > app/models/user.py << 'EOF'
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
EOF

        # Create environment file
        cat > .env << 'EOF'
# Database
DATABASE_URL=sqlite:///./app.db

# Security
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF

        # Initialize Alembic
        echo "🔄 Initializing Alembic for database migrations..."
        uv run alembic init alembic
        
        # Configure alembic.ini
        sed -i '' 's|sqlalchemy.url = driver://user:pass@localhost/dbname|sqlalchemy.url = sqlite:///./app.db|' alembic.ini
        
        # Update Alembic env.py to use our models
        cat > alembic/env.py << 'EOF'
from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
from decouple import config as env_config

# Import your models here
from app.database import Base
from app.models import *  # This imports all models

# this is the Alembic Config object
config = context.config

# Override sqlalchemy.url with environment variable
config.set_main_option("sqlalchemy.url", env_config("DATABASE_URL", default="sqlite:///./app.db"))

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# add your model's MetaData object here for autogenerate support
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
EOF

        # Create initial migration
        echo "📝 Creating initial migration..."
        uv run alembic revision --autogenerate -m "Initial migration"
        
        echo "✅ Database setup complete!"
        echo "🔄 Run 'fastapi-db-upgrade' to apply migrations"
    fi
    
    echo "✅ FastAPI project '$project_name' created successfully!"
    echo "💡 Run: cd $project_name && fastapi dev app/main.py"
}

# FastAPI database management functions
fastapi-db-upgrade() {
    echo "🔄 Applying database migrations..."
    if [[ -f "alembic.ini" ]]; then
        uv run alembic upgrade head
    else
        echo "❌ No Alembic configuration found. Run 'fastapi-init' with database support."
    fi
}

fastapi-db-migrate() {
    local message=${1:-"Auto migration"}
    echo "📝 Creating new migration: $message"
    if [[ -f "alembic.ini" ]]; then
        uv run alembic revision --autogenerate -m "$message"
    else
        echo "❌ No Alembic configuration found. Run 'fastapi-init' with database support."
    fi
}

fastapi-db-downgrade() {
    local revision=${1:-"-1"}
    echo "⬇️  Downgrading database to revision: $revision"
    if [[ -f "alembic.ini" ]]; then
        uv run alembic downgrade "$revision"
    else
        echo "❌ No Alembic configuration found. Run 'fastapi-init' with database support."
    fi
}

fastapi-db-history() {
    echo "📋 Database migration history:"
    if [[ -f "alembic.ini" ]]; then
        uv run alembic history --verbose
    else
        echo "❌ No Alembic configuration found. Run 'fastapi-init' with database support."
    fi
}

fastapi-db-current() {
    echo "📍 Current database revision:"
    if [[ -f "alembic.ini" ]]; then
        uv run alembic current
    else
        echo "❌ No Alembic configuration found. Run 'fastapi-init' with database support."
    fi
}

fastapi-db-reset() {
    echo "⚠️  WARNING: This will reset your database and apply all migrations!"
    echo "Are you sure? (y/N)"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        if [[ -f "alembic.ini" ]]; then
            uv run alembic downgrade base
            uv run alembic upgrade head
            echo "✅ Database reset complete!"
        else
            echo "❌ No Alembic configuration found. Run 'fastapi-init' with database support."
        fi
    else
        echo "🚫 Database reset cancelled."
    fi
}

# Enhanced FastAPI development workflow
fastapi-dev-full() {
    echo "🚀 Starting full FastAPI development environment..."
    
    # Check if we're in a FastAPI project
    if [[ ! -f "app/main.py" ]]; then
        echo "❌ No FastAPI project detected. Run 'fastapi-init' first."
        return 1
    fi
    
    # Apply any pending migrations
    if [[ -f "alembic.ini" ]]; then
        echo "🔄 Checking for pending migrations..."
        fastapi-db-upgrade
    fi
    
    # Start the development server
    echo "🌐 Starting FastAPI development server..."
    fastapi dev app/main.py --reload --port 8000
}

# Lit/LitElement development aliases
alias lit-dev="npm run dev"
alias lit-build="npm run build"
alias lit-serve="npm run serve"
alias lit-test="npm run test"

# LitElement project initialization
lit-init() {
    local project_name=${1:-"lit-app"}
    echo "🔥 Creating Lit project: $project_name"
    
    bun create lit "$project_name"
    cd "$project_name"
    
    # Add PWA-specific dependencies
    bun add workbox-cli workbox-webpack-plugin
    bun add --dev @web/dev-server @web/test-runner
    
    echo "✅ Lit project '$project_name' created with PWA support!"
}

# PWA development tools and functions
pwa-audit() {
    local url=${1:-"http://localhost:8000"}
    echo "🔍 Running PWA audit on: $url"
    
    if command -v lighthouse >/dev/null; then
        lighthouse "$url" --only-categories=pwa --chrome-flags="--headless"
    else
        echo "📱 Install Lighthouse: npm install -g lighthouse"
        echo "🌐 Or use online audit: https://web.dev/measure/"
    fi
}

pwa-manifest-validate() {
    local manifest=${1:-"manifest.json"}
    echo "📋 Validating PWA manifest: $manifest"
    
    if [[ -f "$manifest" ]]; then
        if command -v jq >/dev/null; then
            jq . "$manifest" > /dev/null && echo "✅ Manifest is valid JSON" || echo "❌ Invalid JSON in manifest"
        else
            echo "📦 Install jq for validation: brew install jq"
        fi
    else
        echo "❌ Manifest file not found: $manifest"
    fi
}

pwa-sw-generate() {
    echo "⚙️  Generating service worker..."
    
    if command -v workbox >/dev/null; then
        workbox generateSW workbox-config.js
        echo "✅ Service worker generated!"
    else
        echo "📦 Install Workbox CLI: npm install -g workbox-cli"
    fi
}

# Web development server functions
web-serve() {
    local port=${1:-8080}
    local dir=${2:-.}
    
    echo "🌐 Starting web server on port $port for directory: $dir"
    
    if command -v python3 >/dev/null; then
        cd "$dir" && python3 -m http.server "$port"
    elif command -v php >/dev/null; then
        cd "$dir" && php -S "localhost:$port"
    elif command -v bun >/dev/null; then
        cd "$dir" && bun x serve -p "$port"
    else
        echo "❌ No suitable web server found. Install Python, PHP, or Bun."
    fi
}

# Browser automation for development
browser-open() {
    local url=${1:-"http://localhost:8000"}
    local browser=${2:-"chrome"}
    
    case "$browser" in
        chrome|google-chrome)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open -a "Google Chrome" "$url"
            else
                google-chrome "$url"
            fi
            ;;
        firefox)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open -a "Firefox" "$url"
            else
                firefox "$url"
            fi
            ;;
        safari)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open -a "Safari" "$url"
            else
                echo "❌ Safari only available on macOS"
            fi
            ;;
        *)
            echo "🌐 Opening in default browser: $url"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open "$url"
            else
                xdg-open "$url"
            fi
            ;;
    esac
}

# Full-stack development workflow
fullstack-dev() {
    local backend_port=${1:-8000}
    local frontend_port=${2:-3000}
    
    echo "🚀 Starting full-stack development environment..."
    
    # Check if we're in a project with both backend and frontend
    if [[ -f "app/main.py" ]] || [[ -f "main.py" ]]; then
        echo "🐍 Starting FastAPI backend on port $backend_port..."
        fastapi dev app/main.py --port "$backend_port" &
        backend_pid=$!
    fi
    
    if [[ -f "package.json" ]] && grep -q "dev" package.json; then
        echo "🔥 Starting frontend development server on port $frontend_port..."
        PORT="$frontend_port" bun run dev &
        frontend_pid=$!
    fi
    
    # Open browsers
    sleep 2
    browser-open "http://localhost:$backend_port/docs" &
    browser-open "http://localhost:$frontend_port" &
    
    echo "✅ Full-stack environment running!"
    echo "🔗 Backend API: http://localhost:$backend_port"
    echo "🔗 Frontend: http://localhost:$frontend_port"
    echo "📚 API Docs: http://localhost:$backend_port/docs"
    echo ""
    echo "Press Ctrl+C to stop all services"
    
    # Cleanup function
    cleanup() {
        echo "🛑 Stopping development servers..."
        [[ -n $backend_pid ]] && kill $backend_pid 2>/dev/null
        [[ -n $frontend_pid ]] && kill $frontend_pid 2>/dev/null
        echo "✅ All servers stopped"
    }
    
    trap cleanup EXIT INT TERM
    wait
}

# Development environment health check
web-dev-check() {
    echo "🔍 Checking web development environment..."
    
    # Check essential tools
    local tools=("python3" "bun" "node" "npm")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null; then
            echo "✅ $tool: $(command -v "$tool")"
        else
            echo "❌ $tool: Not installed"
        fi
    done
    
    # Check Python packages
    echo ""
    echo "🐍 Python packages:"
    if command -v uv >/dev/null; then
        echo "✅ uv: $(uv --version)"
    else
        echo "❌ uv: Not installed (pip install uv)"
    fi
    
    # Check Node.js packages
    echo ""
    echo "📦 Node.js environment:"
    if command -v bun >/dev/null; then
        echo "✅ bun: $(bun --version)"
    else
        echo "❌ bun: Not installed"
    fi
    
    # Check web development tools
    echo ""
    echo "🌐 Web development tools:"
    local web_tools=("lighthouse" "workbox")
    for tool in "${web_tools[@]}"; do
        if command -v "$tool" >/dev/null; then
            echo "✅ $tool: Available"
        else
            echo "⚠️  $tool: Not installed (consider: npm install -g $tool)"
        fi
    done
    
    echo ""
    echo "🚀 Web development environment check complete!"
}
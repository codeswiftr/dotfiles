#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Database Management
# Local database setup, seeding, and management
# ============================================================================

# Database command dispatcher
dot_db() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "setup")
            db_setup_services "$@"
            ;;
        "start")
            db_start_services "$@"
            ;;
        "stop")
            db_stop_services "$@"
            ;;
        "status")
            db_status_services
            ;;
        "seed")
            db_seed_data "$@"
            ;;
        "reset")
            db_reset_data "$@"
            ;;
        "backup")
            db_backup_data "$@"
            ;;
        "restore")
            db_restore_data "$@"
            ;;
        "logs")
            db_show_logs "$@"
            ;;
        "shell")
            db_connect_shell "$@"
            ;;
        "migrate")
            db_run_migrations "$@"
            ;;
        "init")
            db_init_project "$@"
            ;;
        "-h"|"--help"|"")
            show_db_help
            ;;
        *)
            print_error "Unknown database subcommand: $subcommand"
            echo "Run 'dot db --help' for available commands."
            return 1
            ;;
    esac
}

# Setup database services
db_setup_services() {
    local services="${1:-auto}"
    local method="${2:-docker}"
    
    print_info "🗄️ Setting up database services..."
    
    # Auto-detect required services
    if [[ "$services" == "auto" ]]; then
        services=$(detect_required_databases)
        print_info "Detected required services: $services"
    fi
    
    case "$method" in
        "docker")
            setup_docker_databases "$services"
            ;;
        "local")
            setup_local_databases "$services"
            ;;
        "cloud")
            setup_cloud_databases "$services"
            ;;
        *)
            print_error "Unknown setup method: $method"
            echo "Available methods: docker, local, cloud"
            return 1
            ;;
    esac
    
    print_success "Database services setup completed!"
}

# Setup Docker databases
setup_docker_databases() {
    local services="$1"
    
    # Create docker-compose.yml for databases
    cat > docker-compose.db.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: development
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dev -d development"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  mongodb:
    image: mongo:6
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: adminpass
      MONGO_INITDB_DATABASE: development
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 30s
      timeout: 10s
      retries: 3

  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: development
      MYSQL_USER: dev
      MYSQL_PASSWORD: devpass
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
  redis_data:
  mongodb_data:
  mysql_data:
  elasticsearch_data:
EOF
    
    # Create database initialization directory
    mkdir -p db/init
    
    # Create sample initialization scripts
    create_init_scripts
    
    print_info "Docker Compose configuration created"
    print_info "Run 'dot db start' to start the services"
}

# Create database initialization scripts
create_init_scripts() {
    # PostgreSQL init script
    cat > db/init/01-init-postgres.sql << 'EOF'
-- PostgreSQL initialization script
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create development user and database
CREATE USER IF NOT EXISTS app_user WITH PASSWORD 'app_password';
CREATE DATABASE IF NOT EXISTS app_development OWNER app_user;
GRANT ALL PRIVILEGES ON DATABASE app_development TO app_user;

-- Create test database
CREATE DATABASE IF NOT EXISTS app_test OWNER app_user;
GRANT ALL PRIVILEGES ON DATABASE app_test TO app_user;
EOF

    # MongoDB init script
    cat > db/init/01-init-mongo.js << 'EOF'
// MongoDB initialization script
db = db.getSiblingDB('development');

// Create collections and indexes
db.createCollection('users');
db.users.createIndex({ "email": 1 }, { unique: true });

// Create development user
db.createUser({
  user: "app_user",
  pwd: "app_password",
  roles: [
    { role: "readWrite", db: "development" },
    { role: "readWrite", db: "test" }
  ]
});
EOF

    print_info "Database initialization scripts created in db/init/"
}

# Start database services
db_start_services() {
    local services="${1:-all}"
    
    if [[ ! -f "docker-compose.db.yml" ]]; then
        print_error "No database configuration found"
        echo "Run 'dot db setup' first"
        return 1
    fi
    
    print_info "🚀 Starting database services..."
    
    if [[ "$services" == "all" ]]; then
        docker-compose -f docker-compose.db.yml up -d
    else
        docker-compose -f docker-compose.db.yml up -d $services
    fi
    
    print_info "Waiting for services to be healthy..."
    
    # Wait for health checks
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if docker-compose -f docker-compose.db.yml ps | grep -q "healthy"; then
            break
        fi
        sleep 2
        ((attempt++))
    done
    
    print_success "Database services started successfully!"
    db_status_services
}

# Stop database services
db_stop_services() {
    local remove_volumes=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --remove-data)
                remove_volumes=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    print_info "🛑 Stopping database services..."
    
    if [[ -f "docker-compose.db.yml" ]]; then
        docker-compose -f docker-compose.db.yml down
        
        if [[ "$remove_volumes" == "true" ]]; then
            print_warning "Removing all database data..."
            docker-compose -f docker-compose.db.yml down -v
        fi
    else
        print_warning "No database configuration found"
    fi
    
    print_success "Database services stopped!"
}

# Show database status
db_status_services() {
    echo "📊 Database Services Status:"
    echo ""
    
    if [[ -f "docker-compose.db.yml" ]]; then
        docker-compose -f docker-compose.db.yml ps
        
        echo ""
        echo "🔌 Connection Information:"
        echo "PostgreSQL: postgresql://dev:devpass@localhost:5432/development"
        echo "Redis:      redis://localhost:6379"
        echo "MongoDB:    mongodb://admin:adminpass@localhost:27017/development"
        echo "MySQL:      mysql://dev:devpass@localhost:3306/development"
        echo "ElasticSearch: http://localhost:9200"
        
    else
        echo "No database services configured"
        echo "Run 'dot db setup' to initialize"
    fi
}

# Seed database with test data
db_seed_data() {
    local environment="${1:-development}"
    local seed_file="${2:-}"
    
    print_info "🌱 Seeding database with test data..."
    
    # Auto-detect seed files
    if [[ -z "$seed_file" ]]; then
        seed_file=$(find_seed_file "$environment")
    fi
    
    if [[ -n "$seed_file" && -f "$seed_file" ]]; then
        print_info "Using seed file: $seed_file"
        
        # Detect database type and run appropriate seeder
        local db_type=$(detect_database_type)
        
        case "$db_type" in
            "postgres")
                seed_postgres "$seed_file" "$environment"
                ;;
            "mysql")
                seed_mysql "$seed_file" "$environment"
                ;;
            "mongodb")
                seed_mongodb "$seed_file" "$environment"
                ;;
            *)
                run_application_seeder "$environment"
                ;;
        esac
    else
        print_info "No seed file found, generating sample data..."
        generate_sample_data "$environment"
    fi
    
    print_success "Database seeding completed!"
}

# Generate sample data
generate_sample_data() {
    local environment="$1"
    
    # Create seed directory if it doesn't exist
    mkdir -p db/seeds
    
    # Generate PostgreSQL sample data
    cat > db/seeds/sample_data.sql << 'EOF'
-- Sample data for development
INSERT INTO users (id, email, name, created_at) VALUES
  (gen_random_uuid(), 'john@example.com', 'John Doe', NOW()),
  (gen_random_uuid(), 'jane@example.com', 'Jane Smith', NOW()),
  (gen_random_uuid(), 'admin@example.com', 'Admin User', NOW())
ON CONFLICT (email) DO NOTHING;

-- Add more sample data as needed
EOF
    
    # Run the seed file
    if docker-compose -f docker-compose.db.yml ps postgres | grep -q "healthy"; then
        docker-compose -f docker-compose.db.yml exec -T postgres psql -U dev -d development < db/seeds/sample_data.sql
        print_success "Sample data inserted into PostgreSQL"
    fi
}

# Database shell access
db_connect_shell() {
    local db_type="${1:-postgres}"
    local database="${2:-development}"
    
    print_info "🔗 Connecting to $db_type shell..."
    
    case "$db_type" in
        "postgres"|"postgresql")
            docker-compose -f docker-compose.db.yml exec postgres psql -U dev -d "$database"
            ;;
        "mysql")
            docker-compose -f docker-compose.db.yml exec mysql mysql -u dev -p"devpass" "$database"
            ;;
        "mongodb"|"mongo")
            docker-compose -f docker-compose.db.yml exec mongodb mongosh "mongodb://admin:adminpass@localhost:27017/$database"
            ;;
        "redis")
            docker-compose -f docker-compose.db.yml exec redis redis-cli
            ;;
        *)
            print_error "Unknown database type: $db_type"
            echo "Available types: postgres, mysql, mongodb, redis"
            return 1
            ;;
    esac
}

# Run database migrations
db_run_migrations() {
    local direction="${1:-up}"
    local steps="${2:-}"
    
    print_info "🔄 Running database migrations..."
    
    # Detect migration runner
    if [[ -f "alembic.ini" ]]; then
        # Python Alembic
        alembic upgrade head
    elif [[ -f "migrate.sh" ]]; then
        # Custom migration script
        bash migrate.sh "$direction" "$steps"
    elif [[ -f "package.json" ]] && grep -q "migrate" package.json; then
        # Node.js migrations
        npm run migrate
    elif [[ -f "Cargo.toml" ]] && grep -q "sqlx" Cargo.toml; then
        # Rust SQLx migrations
        sqlx migrate run
    elif [[ -f "go.mod" ]] && grep -q "migrate" go.mod; then
        # Go migrations
        migrate -path db/migrations -database "$DATABASE_URL" up
    else
        print_warning "No migration system detected"
        echo "Create migrations manually or use a migration framework"
    fi
}

# Initialize database project structure
db_init_project() {
    local db_type="${1:-postgres}"
    
    print_info "🏗️ Initializing database project structure..."
    
    # Create directory structure
    mkdir -p {db/{migrations,seeds,backups},config}
    
    # Create database configuration
    case "$db_type" in
        "postgres")
            create_postgres_config
            ;;
        "mysql")
            create_mysql_config
            ;;
        "mongodb")
            create_mongodb_config
            ;;
        *)
            create_generic_config
            ;;
    esac
    
    # Create .env template
    cat > .env.example << 'EOF'
# Database Configuration
DATABASE_URL=postgresql://dev:devpass@localhost:5432/development
DATABASE_URL_TEST=postgresql://dev:devpass@localhost:5432/test
REDIS_URL=redis://localhost:6379
MONGODB_URL=mongodb://admin:adminpass@localhost:27017/development

# Database Credentials
DB_HOST=localhost
DB_PORT=5432
DB_NAME=development
DB_USER=dev
DB_PASSWORD=devpass
EOF
    
    print_success "Database project structure initialized!"
    print_info "Next steps:"
    echo "  1. Copy .env.example to .env and customize"
    echo "  2. Run 'dot db setup' to start services"
    echo "  3. Run 'dot db migrate' to apply schema"
    echo "  4. Run 'dot db seed' to add test data"
}

# Utility functions
detect_required_databases() {
    local services=()
    
    # Check for common database indicators
    if grep -r "postgresql\|psycopg\|pg_" . --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.rs" >/dev/null 2>&1; then
        services+=("postgres")
    fi
    
    if grep -r "redis" . --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.rs" >/dev/null 2>&1; then
        services+=("redis")
    fi
    
    if grep -r "mongodb\|mongoose\|pymongo" . --include="*.py" --include="*.js" --include="*.ts" >/dev/null 2>&1; then
        services+=("mongodb")
    fi
    
    if grep -r "mysql" . --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.rs" >/dev/null 2>&1; then
        services+=("mysql")
    fi
    
    if [[ ${#services[@]} -eq 0 ]]; then
        services=("postgres" "redis")  # Default stack
    fi
    
    echo "${services[@]}"
}

detect_database_type() {
    if [[ -f "alembic.ini" ]] || grep -q "postgresql" requirements.txt pyproject.toml 2>/dev/null; then
        echo "postgres"
    elif grep -q "mysql" requirements.txt pyproject.toml package.json 2>/dev/null; then
        echo "mysql"
    elif grep -q "mongodb" requirements.txt pyproject.toml package.json 2>/dev/null; then
        echo "mongodb"
    else
        echo "postgres"  # Default
    fi
}

find_seed_file() {
    local environment="$1"
    
    local possible_files=(
        "db/seeds/${environment}.sql"
        "db/seeds/seed_${environment}.sql"
        "seeds/${environment}.sql"
        "db/fixtures/${environment}.json"
        "fixtures/${environment}.json"
    )
    
    for file in "${possible_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "$file"
            return
        fi
    done
}

# Help function
show_db_help() {
    cat << 'EOF'
dot db - Database management and automation

USAGE:
    dot db <command> [options]

COMMANDS:
    setup [services] [method]    Setup database services (auto|postgres,redis|docker)
    start [services]             Start database services
    stop [--remove-data]         Stop database services
    status                       Show database service status
    seed [env] [file]            Seed database with test data
    reset [--confirm]            Reset database to clean state
    backup [service] [file]      Backup database data
    restore [service] [file]     Restore database from backup
    logs [service]               Show database service logs
    shell [type] [database]      Connect to database shell
    migrate [up|down] [steps]    Run database migrations
    init [type]                  Initialize database project structure

DATABASE SERVICES:
    postgres                     PostgreSQL database
    mysql                        MySQL database
    mongodb                      MongoDB database
    redis                        Redis cache/queue
    elasticsearch                Elasticsearch search engine

SETUP METHODS:
    docker                       Docker Compose (recommended)
    local                        Local installation
    cloud                        Cloud database services

MIGRATION SUPPORT:
    alembic                      Python Alembic migrations
    sqlx                         Rust SQLx migrations
    migrate                      Go migrate tool
    knex                         Node.js Knex migrations
    custom                       Custom migration scripts

OPTIONS:
    --remove-data                Remove all data volumes
    --confirm                    Skip confirmation prompts
    -h, --help                   Show this help message

CONNECTION INFO:
    PostgreSQL:     postgresql://dev:devpass@localhost:5432/development
    MySQL:          mysql://dev:devpass@localhost:3306/development
    MongoDB:        mongodb://admin:adminpass@localhost:27017/development
    Redis:          redis://localhost:6379
    Elasticsearch:  http://localhost:9200

EXAMPLES:
    dot db setup postgres,redis          # Setup specific services
    dot db start                         # Start all services
    dot db seed development              # Seed with test data
    dot db shell postgres                # Connect to PostgreSQL
    dot db backup postgres backup.sql    # Backup PostgreSQL
    dot db migrate up                    # Run migrations

PROJECT STRUCTURE:
    db/
    ├── migrations/              # Database schema migrations
    ├── seeds/                   # Test data and fixtures
    ├── backups/                 # Database backups
    └── init/                    # Initialization scripts
EOF
}
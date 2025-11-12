# Start all services including Airbyte

set -e

echo "Starting Data Warehouse with Airbyte"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose not found"
    echo "Please install docker-compose first"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Error: .env file not found"
    echo "Creating .env file..."
    cat > .env << 'EOF'
CONFIG_ROOT=/data
DATA_DOCKER_MOUNT=airbyte_data
DB_DOCKER_MOUNT=airbyte_db
WORKSPACE_ROOT=/tmp/workspace
WORKSPACE_DOCKER_MOUNT=airbyte_workspace
LOCAL_ROOT=/tmp/airbyte_local
LOCAL_DOCKER_MOUNT=/tmp/airbyte_local
HACK_LOCAL_ROOT_PARENT=/tmp
EOF
    echo ".env file created"
fi

echo ""
echo "Starting containers..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."

# Wait for PostgreSQL
echo -n "Waiting for PostgreSQL..."
until docker-compose exec -T postgres pg_isready -U dwh_user -d data_warehouse > /dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo ""

# Wait for Grafana
echo -n "Waiting for Grafana..."
until curl -sf http://localhost:3000/api/health > /dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo ""

# Wait for Airbyte (this takes longer)
echo -n "Waiting for Airbyte (this may take 2-3 minutes)..."
MAX_ATTEMPTS=90
ATTEMPT=0
until curl -sf http://localhost:8000 > /dev/null 2>&1; do
    echo -n "."
    sleep 2
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
        echo ""
        echo "Airbyte is taking longer than expected. Check logs with: docker-compose logs airbyte-webapp"
        break
    fi
done
if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
    echo ""
fi

echo ""
echo "All Services Started!"
echo ""
echo "Service URLs:"
echo "  - PostgreSQL:  localhost:5432"
echo "  - Grafana:     http://localhost:3000"
echo "  - Airbyte UI:  http://localhost:8000"
echo ""

# Start script for Data Warehouse project
# This script starts all Docker services and performs health checks

set -e

echo "Starting Data Warehouse Services..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found!"
    echo "Please run this script from the my_data_project directory"
    exit 1
fi

# Start services
echo "Starting Docker containers..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."
sleep 10

# Check service status
echo ""
echo "Service Status:"
docker-compose ps

# Health checks
echo ""
echo "Performing Health Checks..."

# Check PostgreSQL
echo -n "PostgreSQL: "
if docker-compose exec -T postgres pg_isready -U dwh_user -d data_warehouse > /dev/null 2>&1; then
    echo "Healthy"
else
    echo "Not responding"
fi

# Check Grafana
echo -n "Grafana: "
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "Healthy"
else
    echo "Not responding"
fi

echo ""
echo "Services Started Successfully!"
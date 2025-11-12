# Start script for Data Warehouse project
# This script starts all Docker services and perfoms health checks

set -e

echo "Startting Data Warehouses Services..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found!"
    echo "Please run this script from the data_warehouse directory"
    exit 1
fi

# Start services
echo "Starting Docker Containers..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy..."
sleep 10

# Check service status
echo ""
echo "Service Status..."
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
echo "Services started successfully!"
echo ""
echo " Access Points:"
echo "  PostgreSQL: localhost:5432"
echo "  Grafana:    http://localhost:3000"
echo "  Airbyte:    http://localhost:8000 (if configured)"
echo ""
echo "Default Credentials:"
echo "PostgreSQL: dwh_user / dwh_password"
echo "  Grafana:    admin / admin"
echo ""
echo "Next Steps:"
echo "  1. Connect DBeaver to PostgreSQL"
echo "  2. Access Grafana in your browser"
echo "  3. Check README.md for Phase 0 verification"
echo ""
echo "Useful Commands:"
echo "  View logs:    docker-compose logs -f"
echo "  Stop services: docker-compose down"
echo "  Restart:      docker-compose restart"
echo ""

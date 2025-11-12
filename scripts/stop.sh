# Stop script for Data Warehouse project

set -e

echo "Stopping Data Warehouse Services..."
echo ""

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found!"
    echo "Please run this script from the my_data_project directory"
    exit 1
fi

# Stop services
docker-compose down

echo ""
echo "All services stopped successfully!"
echo ""
echo "To remove all data and start fresh:"
echo "   docker-compose down -v"
echo ""
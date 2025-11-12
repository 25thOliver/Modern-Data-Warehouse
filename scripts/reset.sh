# Reset script - stops services and removes all data
# WARNING: This will delete all data in the database!

set -e

echo "WARNING: This will DELETE ALL DATA!"
echo ""
echo "This script will:"
echo "  - Stop all services"
echo "  - Remove all Docker volumes (PostgreSQL data, Grafana config, etc.)"
echo "  - Give you a fresh start"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Reset cancelled"
    exit 0
fi

echo ""
echo "Removing all services and data..."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found!"
    echo "Please run this script from the my_data_project directory"
    exit 1
fi

# Stop and remove everything
docker-compose down -v

echo ""
echo "Reset complete! All data has been removed."
echo ""
echo "To start fresh:"
echo "   ./scripts/start.sh"
echo ""
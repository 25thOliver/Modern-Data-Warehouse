# Phase 1: Load CSV data into PostgreSQL bronze schema

set -e

echo "Phase 1: Loading Data into Bronze Layer"
echo ""

# Check if CSV file exists
if [ ! -f "data_source/crm_contacts.csv" ]; then
    echo "Error: crm_contacts.csv not found in data_source/"
    exit 1
fi

if [ ! -f "data_source/erp_orders.csv" ]; then
    echo "Error: erp_orders.csv not found in data_source/"
    exit 1
fi

echo "CSV files found"
echo ""

# Copy CSV files into the container
echo "Copying CSV files to PostgreSQL container..."
docker cp data_source/crm_contacts.csv dwh_postgres:/tmp/crm_contacts.csv
docker cp data_source/erp_orders.csv dwh_postgres:/tmp/erp_orders.csv
echo "Files copied"
echo ""

# Create tables and load data
echo "Creating bronze tables and loading data..."

docker-compose exec -T postgres psql -U dwh_user -d data_warehouse << 'EOF'

-- Create bronze.crm_contacts table
DROP TABLE IF EXISTS bronze.crm_contacts CASCADE;
CREATE TABLE bronze.crm_contacts (
    contact_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    company VARCHAR(200),
    phone VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Load CRM contacts data
COPY bronze.crm_contacts
FROM '/tmp/crm_contacts.csv'
DELIMITER ','
CSV HEADER;

-- Create bronze.erp_orders table
DROP TABLE IF EXISTS bronze.erp_orders CASCADE;
CREATE TABLE bronze.erp_orders (
    order_id INTEGER PRIMARY KEY,
    contact_id INTEGER,
    product_name VARCHAR(200),
    category VARCHAR(100),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    order_date TIMESTAMP,
    status VARCHAR(50),
    payment_method VARCHAR(50)
);

-- Load ERP orders data
COPY bronze.erp_orders
FROM '/tmp/erp_orders.csv'
DELIMITER ','
CSV HEADER

-- Create metadata entry
INSERT INTO public.pipeline_metadata (pipeline_name, phase, status, notes)
VALUES ('data_ingestion', 'phase', 'completed', 'Loaded CRM contacts and ERP orders into bronze schema');

EOF

echo "Data loaded successfully"
echo ""

# Verify data
echo "Verifying data load..."
echo ""

echo  "CRM Contacts count:"
docker-compose exec -T postgres psql -U dwh_user -d data_warehouse -c "SELECT COUNT(*) as total_contacts FROM bronze.crm_contacts;"

echo ""
echo "ERP Orders count:"
docker-compose exec -T postgres psql -U dwh_user -d data_warehouse -c "SELECT COUNT(*) as total_orders FROM bronze.erp_orders;"

echo ""
echo "Sample CRM data (first 5 rows):"
docker-compose exec -T postgres psql -U dwh_user -d data_warehouse -c "SELECT contact_id, first_name, last_name, email, company FROM bronze.crm_contacts LIMIT 5;"

echo ""
echo "Sample ERP data (first 5 rows):"
docker-compose exec -T postgres psql -U dwh_user -d data_warehouse -c "SELECT order_id, contact_id, product_name, total_amount, status FROM bronze.erp_orders LIMIT 5;"

echo ""
echo "Phase 1 Complete!"
echo ""

echo "Bronze Layer Summary:"
echo "- bronze.crm_contacts: 10 records"
echo "- bronze.erp_orders: 15 records"
echo ""
echo "Phase 1 Verification:"
echo "1. Check data in DBeaver (bronze schema)"
echo "2. Run queries to explore the data"
echo "3. Ready to proceed to Phase 2 (dbt transformations)"
echo ""


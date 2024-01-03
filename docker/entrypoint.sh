#!/bin/bash
#
# Start local dev
#
echo "Modifying postgresql.conf to preload timescaledb"
echo "shared_preload_libraries = 'timescaledb'" >> /etc/postgresql/15/main/postgresql.conf

echo "Starting PostgresML"
service postgresql start

# Setup users
useradd postgresml -m 2> /dev/null 1>&2
sudo -u postgresml touch /home/postgresml/.psql_history
sudo -u postgres createuser root --superuser --login 2> /dev/null 1>&2
sudo -u postgres psql -c "CREATE ROLE postgresml PASSWORD 'postgresml' SUPERUSER LOGIN" 2> /dev/null 1>&2
sudo -u postgres createdb postgresml --owner postgresml 2> /dev/null 1>&2
sudo -u postgres psql -c 'ALTER ROLE postgresml SET search_path TO public,pgml' 2> /dev/null 1>&2

# Create TimescaleDB extension if it doesn't exist
sudo -u postgresml psql -d postgresml -c 'CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE'

# restart postgresql to make sure all extensions are loaded
service postgresql restart

echo "Starting dashboard"
PGPASSWORD=postgresml psql -d postgresml -U postgresml -h 127.0.0.1 -p 5432 -c 'CREATE EXTENSION IF NOT EXISTS pgml' 2> /dev/null 1>&2

bash /app/dashboard.sh &

exec "$@"

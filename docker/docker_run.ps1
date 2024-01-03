docker run `
    -it `
    -v postgresml_data:/var/lib/postgresql `
    -p 5433:5432 `
    -p 8000:8000 `
    -n postgresml+tsdb `
    postgresml:v0.1 `
    sudo -u postgresml psql -d postgresml

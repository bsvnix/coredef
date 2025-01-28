# Use the official PostgreSQL image
FROM postgres:15

# Set the environment variable for the data directory
ENV POSTGRES_DB=coredef
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=securepassword

# Copy initialization script into the container
COPY db-init.sql /docker-entrypoint-initdb.d/db-init.sql

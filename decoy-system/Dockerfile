# Base image with Python
FROM python:3.9-slim

# Install system dependencies for Python and psycopg2
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy application files
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose ports for HTTP (80) and SMB (445)
EXPOSE 80
EXPOSE 445

# Run the decoy app
CMD ["python", "decoy.py"]

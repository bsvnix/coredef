# Base image with Python and system utilities
FROM python:3.9-slim

# Install necessary system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    samba \
    python3-pip \
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

# Start both services (web server and Samba) with the main decoy script
CMD ["python", "decoy.py"]

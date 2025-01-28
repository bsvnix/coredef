# Use the official Python 3.9 image
FROM python:3.9-slim

# Set environment variables to ensure UTF-8 encoding and prevent Python output buffering
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required for psycopg2 and Flask
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the application code into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port for the Flask app
EXPOSE 5000

# Start the Flask application
CMD ["python", "app.py"]

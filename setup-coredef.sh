#!/bin/bash

# Define the path to the config.json file
CONFIG_FILE="./global-config/config.json"

# Function to extract values from config.json
function get_config_value() {
    key=$1
    jq -r "$key" "$CONFIG_FILE"
}

# Check if jq is installed (used to parse JSON)
function install_jq() {
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Installing jq..."
        sudo apt-get update && sudo apt-get install -y jq
        echo "jq installed successfully."
    else
        echo "jq is already installed."
    fi
}

# Function to check if a command exists
function command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install Docker
function install_docker() {
    if ! command_exists docker; then
        echo "Docker is not installed. Installing Docker..."
        curl -fsSL https://get.docker.com | bash
        sudo systemctl start docker
        sudo systemctl enable docker
        echo "Docker installed successfully."
    else
        echo "Docker is already installed."
    fi
}

# Function to install Docker Compose
function install_docker_compose() {
    if ! command_exists docker-compose; then
        echo "Docker Compose is not installed. Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose installed successfully."
    else
        echo "Docker Compose is already installed."
    fi
}

# Function to check and install required software
function check_and_install_software() {
    install_jq
    install_docker
    install_docker_compose
}

function create_env_file() {
    echo "Creating .env file from config.json..."
    if [ ! -f .env ]; then
        # Extract values from config.json
        DB_USER=$(get_config_value '.database.users.control.user')
        DB_PASSWORD=$(get_config_value '.database.users.control.password')
        DB_NAME=$(get_config_value '.database.name')
        POSTGRES_PASSWORD=$(get_config_value '.database.users.control.password')  # Use control password as superuser password

        # Create the .env file
        cat <<EOL > .env
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
EOL
        echo ".env file created successfully."
    else
        echo ".env file already exists. Skipping creation."
    fi
}

# Function to deploy CoreDef containers
function deploy_coredef() {
    echo "Starting deployment of CoreDef containers..."
    # Ensure Docker is running
    sudo systemctl start docker

    # Build and start containers using Docker Compose
    echo "Building and starting containers..."
    sudo docker-compose down --remove-orphans
    sudo docker-compose up --build -d
    echo "Containers deployed successfully."
}

# Main script execution
echo "Checking required software..."
check_and_install_software

echo "Setting up environment variables..."
create_env_file

echo "Setting up CoreDef containers..."
deploy_coredef

echo "CoreDef setup complete. Access the control center at http://localhost:5000"

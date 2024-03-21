#!/bin/bash

buildDockerFile() {
    read -p "What is the directory of your application? " direct
    DOCKERFILE="Dockerfile.temp"

    cat <<EOF >$DOCKERFILE
    # Use a base image
    FROM ubuntu:latest

    # Copy the application to the image
    COPY $direct /app

    # Set the working directory
    WORKDIR /app

    # Example: Install dependencies
    RUN apt-get update && apt-get install -y <packages>

    # Example: Expose a port if needed
    EXPOSE 80

    # Example: Set the default command to start the application
    CMD ["./start.sh"]
EOF

    # Build the Docker image using the temporary Dockerfile
    docker build -t $IMAGE_NAME -f $DOCKERFILE .

    # Remove the temporary Dockerfile
    rm $DOCKERFILE
}

read -p "Image name: " IMAGE_NAME
read -p "Container name: " CONTAINER_NAME

read -p "Choose the Host port: " PORT_HOST
read -p "Choose the Container port: " CONTAINER_PORT

# Call the function to build the Dockerfile
buildDockerFile

# Run the container
docker run -d --name $CONTAINER_NAME -p $PORT_HOST:$CONTAINER_PORT $IMAGE_NAME

# Verify if the container is running
if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME)" = "true" ]; then
    echo "Container $CONTAINER_NAME is running on port $PORT_HOST"
else
    echo "Failed to start the container $CONTAINER_NAME"
fi

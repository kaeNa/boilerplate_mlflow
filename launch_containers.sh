#!/bin/bash

KEYS_DIR="keys"
KEYS_FILE="$KEYS_DIR/minio_keys.txt"

# Set environment variables
export MLFLOW_TRACKING_URI=http://localhost:5000

# Check if keys file exists
if [ -f "$KEYS_FILE" ]; then
  # Read keys from the file
  export MINIO_ACCESS_KEY=$(cat "$KEYS_FILE" | grep "ACCESS_KEY" | cut -d'=' -f2)
  export MINIO_SECRET_KEY=$(cat "$KEYS_FILE" | grep "SECRET_KEY" | cut -d'=' -f2)
else
  # Generate random keys
  export MINIO_ACCESS_KEY=$(openssl rand -hex 16)
  export MINIO_SECRET_KEY=$(openssl rand -hex 32)

  # Create keys directory if it doesn't exist
  mkdir -p "$KEYS_DIR"

  # Save keys to file
  echo "ACCESS_KEY=$MINIO_ACCESS_KEY" > "$KEYS_FILE"
  echo "SECRET_KEY=$MINIO_SECRET_KEY" >> "$KEYS_FILE"
fi

# Build the MinIO image
docker build -t minio-server -f docker/Dockerfile.minio .

# Run the MinIO container
docker run -d -p 9000:9000 -e MINIO_ACCESS_KEY -e MINIO_SECRET_KEY minio-server

# Build the MLflow image
docker build -t boilerplate_mlflow -f docker/Dockerfile.mlflow .

# Run the MLflow container
docker run -d -p 5000:5000 -e MLFLOW_TRACKING_URI -e MINIO_ACCESS_KEY -e MINIO_SECRET_KEY boilerplate_mlflow

echo "Containers launched successfully!"


@echo off

set KEYS_DIR=keys
set KEYS_FILE=%KEYS_DIR%\minio_keys.txt

REM Set environment variables
set MLFLOW_TRACKING_URI=http://localhost:5000

REM Check if keys file exists
if exist "%KEYS_FILE%" (
  REM Read keys from the file
  for /f "tokens=2 delims==" %%G in ('findstr "ACCESS_KEY" "%KEYS_FILE%"') do set MINIO_ACCESS_KEY=%%G
  for /f "tokens=2 delims==" %%G in ('findstr "SECRET_KEY" "%KEYS_FILE%"') do set MINIO_SECRET_KEY=%%G
) else (
  REM Generate random keys
  for /f "delims=" %%G in ('openssl rand -hex 16') do set MINIO_ACCESS_KEY=%%G
  for /f "delims=" %%G in ('openssl rand -hex 32') do set MINIO_SECRET_KEY=%%G

  REM Create keys directory if it doesn't exist
  mkdir "%KEYS_DIR%"

  REM Save keys to file
  echo ACCESS_KEY=%MINIO_ACCESS_KEY% > "%KEYS_FILE%"
  echo SECRET_KEY=%MINIO_SECRET_KEY% >> "%KEYS_FILE%"
)
REM Build the MinIO image
docker build -t minio-server -f docker\Dockerfile.minio .

REM Run the MinIO container
docker run -d -p 9000:9000 -e MINIO_ACCESS_KEY -e MINIO_SECRET_KEY minio-server

REM Build the MLflow image
docker build -t boilerplate_mlflow -f docker\Dockerfile.mlflow .

REM Run the MLflow container
docker run -d -p 5000:5000 -e MLFLOW_TRACKING_URI -e MINIO_ACCESS_KEY -e MINIO_SECRET_KEY boilerplate_mlflow

echo Containers launched successfully!


# Docker Deployment Guide

This directory contains configuration files for deploying the application in production environments using Docker Compose. The setup provides a complete stack including API services, frontend, database, cache, vector database, and supporting services.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Configuration](#detailed-configuration)
  - [Core Services](#core-services)
  - [Database Configuration](#database-configuration)
  - [Redis Configuration](#redis-configuration)
  - [Vector Store Configuration](#vector-store-configuration)
  - [Storage Configuration](#storage-configuration)
  - [NGINX Configuration](#nginx-configuration)
  - [Security Features](#security-features)
- [Environment Variables and Secrets](#environment-variables-and-secrets)
- [Common Deployment Scenarios](#common-deployment-scenarios)
- [Scaling Your Deployment](#scaling-your-deployment)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Prerequisites

- Docker Engine (version 20.10.0 or later)
- Docker Compose V2 (version 2.0.0 or later)
- At least 4GB RAM (8GB+ recommended for production)
- Sufficient disk space (at least 10GB free)
- Internet connectivity for pulling images

## Quick Start

1. Copy the example environment file to create your configuration:

```bash
cp .env.example .env
```

2. Edit the `.env` file to customize your deployment (at minimum, set a strong `SECRET_KEY`):

```bash
# Generate a strong secret key
SECRET_KEY=$(openssl rand -base64 42)
# Update the SECRET_KEY in your .env file
sed -i "s/^SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env
```

3. Generate the Docker Compose file:

```bash
python generate_docker_compose
```

4. Start the services:

```bash
docker-compose up -d
```

5. Access the application:
   - Web UI: http://localhost (or the domain configured in NGINX)
   - API: http://localhost/api (or the domain configured in NGINX)

## Detailed Configuration

### Core Services

The deployment consists of the following core services:

- **API Service**: The backend API service for the application
- **Worker Service**: Background task processing using Celery
- **Web Service**: The frontend web interface
- **Database**: PostgreSQL database for structured data
- **Redis**: Cache and message broker
- **Vector Database**: For semantic search capabilities
- **NGINX**: Reverse proxy and static file serving
- **Plugin Daemon**: Plugin service for extensibility
- **Sandbox**: Secure environment for code execution

Each service can be configured through environment variables in the `.env` file.

### Database Configuration

The PostgreSQL database is configured through these key environment variables:

```
DB_USERNAME=postgres
DB_PASSWORD=difyai123456
DB_HOST=db
DB_PORT=5432
DB_DATABASE=dify
```

For production deployments, you should:

1. Set a strong password in `DB_PASSWORD`
2. Configure PostgreSQL performance parameters:

```
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_SHARED_BUFFERS=1GB
POSTGRES_WORK_MEM=16MB
POSTGRES_MAINTENANCE_WORK_MEM=256MB
POSTGRES_EFFECTIVE_CACHE_SIZE=4GB
```

If you're using an external PostgreSQL database, update the `DB_HOST` and other relevant settings, and comment out the `db` service in the `docker-compose-template.yaml` file before regenerating.

### Redis Configuration

Redis is used for caching and as the Celery message broker:

```
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=difyai123456
REDIS_DB=0
CELERY_BROKER_URL=redis://:difyai123456@redis:6379/1
```

For production:

1. Set a strong password in `REDIS_PASSWORD`
2. Update the `CELERY_BROKER_URL` to match your Redis password
3. Consider enabling Redis persistence in the `redis` service definition

For high availability, you can configure Redis Sentinel:

```
REDIS_USE_SENTINEL=true
REDIS_SENTINELS=sentinel1:26379,sentinel2:26379,sentinel3:26379
REDIS_SENTINEL_SERVICE_NAME=mymaster
REDIS_SENTINEL_USERNAME=default
REDIS_SENTINEL_PASSWORD=your-sentinel-password
```

### Vector Store Configuration

The system supports multiple vector databases. The default is Weaviate, but you can switch to others:

```
VECTOR_STORE=weaviate  # Options: weaviate, qdrant, milvus, pgvector, etc.
```

#### Weaviate Configuration

```
WEAVIATE_ENDPOINT=http://weaviate:8080
WEAVIATE_API_KEY=WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih
```

#### Qdrant Configuration

```
QDRANT_URL=http://qdrant:6333
QDRANT_API_KEY=difyai123456
```

#### PGVector Configuration

```
PGVECTOR_HOST=pgvector
PGVECTOR_PORT=5432
PGVECTOR_USER=postgres
PGVECTOR_PASSWORD=difyai123456
PGVECTOR_DATABASE=dify
```

To use a different vector database, update the `VECTOR_STORE` variable and configure the specific variables for that store. Then start the required services using Docker Compose profiles:

```bash
# For Qdrant
docker-compose --profile qdrant up -d
```

### Storage Configuration

File storage is configured through:

```
STORAGE_TYPE=opendal  # Options: opendal, s3, aliyun-oss, azure-blob, etc.
```

The default uses local file storage:

```
OPENDAL_SCHEME=fs
OPENDAL_FS_ROOT=storage
```

For S3-compatible storage:

```
STORAGE_TYPE=s3
S3_ENDPOINT=https://your-bucket.s3.amazonaws.com
S3_BUCKET_NAME=your-bucket-name
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
S3_REGION=your-region
```

### NGINX Configuration

NGINX serves as the entry point for all services. Key configurations:

```
NGINX_PORT=80
NGINX_HTTPS_ENABLED=false
NGINX_SSL_CERT_FILENAME=dify.crt
NGINX_SSL_CERT_KEY_FILENAME=dify.key
```

For HTTPS:

1. Set `NGINX_HTTPS_ENABLED=true`
2. Provide SSL certificates in the `nginx/ssl` directory
3. Update `NGINX_SSL_CERT_FILENAME` and `NGINX_SSL_CERT_KEY_FILENAME`

Alternatively, use Let's Encrypt with Certbot:

```
NGINX_ENABLE_CERTBOT_CHALLENGE=true
CERTBOT_EMAIL=your_email@example.com
CERTBOT_DOMAIN=your_domain.com
```

Then start the Certbot service:

```bash
docker-compose --profile certbot up -d
```

### Security Features

The deployment includes several security features:

- **SSRF Protection**: Prevents server-side request forgery
- **API Rate Limiting**: Configured in NGINX
- **Secure Cookie Settings**: For authentication tokens
- **Sandbox Isolation**: For secure code execution

## Environment Variables and Secrets

### Managing Secrets

For production deployments, sensitive values in the `.env` file should be:

1. Generated uniquely for each deployment
2. Stored securely using a secrets management solution
3. Not committed to version control

Critical secrets to manage:

- `SECRET_KEY`: Application secret key
- `DB_PASSWORD`: Database password
- `REDIS_PASSWORD`: Redis password
- `WEAVIATE_API_KEY`: Vector database API key
- Any API keys for external services

### Using Docker Secrets

For Docker Swarm deployments, you can use Docker secrets:

1. Create secrets:

```bash
echo "your-strong-password" | docker secret create db_password -
```

2. Reference in docker-compose:

```yaml
services:
  db:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
```

## Common Deployment Scenarios

### Single-Host Deployment

The default configuration works well on a single host with sufficient resources. Recommended specifications:

- 4+ CPU cores
- 16+ GB RAM
- 100+ GB SSD storage
- Ubuntu 22.04 LTS or similar

### Multi-Host Deployment

For larger deployments, you can distribute services across multiple hosts:

1. **Primary Host**: API, Worker, NGINX, Redis
2. **Database Host**: PostgreSQL or Vector Database
3. **Storage Host**: Dedicated storage server

Each service can point to the appropriate host using environment variables.

### Cloud Provider Deployments

#### AWS Deployment

For AWS, consider:

1. RDS for PostgreSQL
2. ElastiCache for Redis
3. S3 for storage
4. EC2 or ECS for application services

Update environment variables to point to these managed services.

#### GCP Deployment

For GCP, consider:

1. Cloud SQL for PostgreSQL
2. Memorystore for Redis
3. Cloud Storage for files
4. Compute Engine or GKE for application services

#### Azure Deployment

For Azure, consider:

1. Azure Database for PostgreSQL
2. Azure Cache for Redis
3. Azure Blob Storage for files
4. Azure VMs or AKS for application services

### Kubernetes Deployment

While this directory focuses on Docker Compose, the container configuration can be adapted for Kubernetes:

1. Use the same container images
2. Convert environment variables to ConfigMaps and Secrets
3. Create appropriate Service and Deployment resources
4. Use persistent volumes for stateful services

## Scaling Your Deployment

### Horizontal Scaling

To handle increased load, you can scale services horizontally:

1. **API Service**: Increase `SERVER_WORKER_AMOUNT` or run multiple API containers
2. **Worker Service**: Increase `CELERY_WORKER_AMOUNT` or run multiple worker containers
3. **Web Service**: Increase `PM2_INSTANCES` or run multiple web containers

Example scaling configuration:

```
SERVER_WORKER_AMOUNT=4
CELERY_WORKER_AMOUNT=4
PM2_INSTANCES=4
```

### Database Scaling

For database scaling:

1. Increase connection pool: `SQLALCHEMY_POOL_SIZE=50`
2. Optimize PostgreSQL: `POSTGRES_SHARED_BUFFERS=4GB`
3. Consider read replicas for heavy read workloads

### Redis Scaling

For Redis scaling:

1. Use Redis Cluster: `REDIS_USE_CLUSTERS=true`
2. Configure multiple Redis nodes: `REDIS_CLUSTERS=redis1:6379,redis2:6379,redis3:6379`

## Monitoring and Maintenance

### Health Checks

All critical services include health checks. Monitor them with:

```bash
docker-compose ps
```

### Logs

View service logs:

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs api

# Follow logs
docker-compose logs -f api
```

### Backups

Schedule regular backups:

1. **Database**:

```bash
docker-compose exec db pg_dump -U postgres dify > backup-$(date +%Y%m%d).sql
```

2. **Volumes**:

```bash
tar -czvf volumes-backup-$(date +%Y%m%d).tar.gz ./volumes
```

### Updates

To update the deployment:

1. Pull latest images:

```bash
docker-compose pull
```

2. Restart services:

```bash
docker-compose down
docker-compose up -d
```

## Troubleshooting

### Common Issues

#### Services Won't Start

**Problem**: One or more services fail to start.

**Solution**:
1. Check logs: `docker-compose logs [service-name]`
2. Verify environment variables in `.env`
3. Ensure sufficient system resources
4. Check for port conflicts: `netstat -tuln`

#### Database Connection Issues

**Problem**: API service can't connect to the database.

**Solution**:
1. Verify DB credentials in `.env`
2. Check if DB service is running: `docker-compose ps db`
3. Try connecting manually: `docker-compose exec db psql -U postgres -d dify`
4. Check DB logs: `docker-compose logs db`

#### Vector Store Issues

**Problem**: Vector operations fail.

**Solution**:
1. Verify vector store is running: `docker-compose ps [vector-store-name]`
2. Check connection settings in `.env`
3. Verify API keys are correct
4. Check vector store logs: `docker-compose logs [vector-store-name]`

#### NGINX Configuration

**Problem**: Cannot access the application.

**Solution**:
1. Check NGINX logs: `docker-compose logs nginx`
2. Verify port configuration and exposure
3. Check SSL certificate paths if using HTTPS
4. Validate NGINX configuration: `docker-compose exec nginx nginx -t`

### Diagnostic Commands

Basic diagnostic workflow:

```bash
# Check container status
docker-compose ps

# Check system resources
docker stats

# Inspect networking
docker network inspect docker_default

# Check disk space
df -h ./volumes

# Verify configuration
docker-compose config
```

## Best Practices

### Security

1. **Change Default Passwords**: Always change default passwords in `.env`
2. **Use HTTPS**: Enable SSL in production
3. **Limit Access**: Use firewall rules to restrict access to services
4. **Regular Updates**: Keep container images updated
5. **Secrets Management**: Use environment-specific secret management

### Performance

1. **Resource Allocation**: Ensure adequate CPU, memory, and disk resources
2. **Database Tuning**: Optimize PostgreSQL configuration
3. **Connection Pooling**: Adjust pool sizes based on workload
4. **Monitoring**: Implement monitoring for resource usage
5. **Caching**: Utilize Redis caching effectively

### Reliability

1. **Regular Backups**: Schedule automated backups
2. **Health Checks**: Implement external health monitoring
3. **High Availability**: Consider redundancy for critical services
4. **Graceful Scaling**: Scale services based on actual usage patterns
5. **Logging**: Implement centralized logging for troubleshooting

### Development to Production

1. **Environment Isolation**: Keep development and production environments separate
2. **Consistent Images**: Use the same container images across environments
3. **Configuration Management**: Use different `.env` files for each environment
4. **CI/CD Integration**: Automate deployment processes
5. **Testing**: Test changes in staging before production deployment

## README for docker Deployment

Welcome to the new `docker` directory for deploying Dify using Docker Compose. This README outlines the updates, deployment instructions, and migration details for existing users.

### What's Updated

- **Certbot Container**: `docker-compose.yaml` now contains `certbot` for managing SSL certificates. This container automatically renews certificates and ensures secure HTTPS connections.  
  For more information, refer `docker/certbot/README.md`.

- **Persistent Environment Variables**: Environment variables are now managed through a `.env` file, ensuring that your configurations persist across deployments.

  > What is `.env`? </br> </br>
  > The `.env` file is a crucial component in Docker and Docker Compose environments, serving as a centralized configuration file where you can define environment variables that are accessible to the containers at runtime. This file simplifies the management of environment settings across different stages of development, testing, and production, providing consistency and ease of configuration to deployments.

- **Unified Vector Database Services**: All vector database services are now managed from a single Docker Compose file `docker-compose.yaml`. You can switch between different vector databases by setting the `VECTOR_STORE` environment variable in your `.env` file.
- **Mandatory .env File**: A `.env` file is now required to run `docker compose up`. This file is crucial for configuring your deployment and for any custom settings to persist through upgrades.

### How to Deploy Dify with `docker-compose.yaml`

1. **Prerequisites**: Ensure Docker and Docker Compose are installed on your system.
2. **Environment Setup**:
    - Navigate to the `docker` directory.
    - Copy the `.env.example` file to a new file named `.env` by running `cp .env.example .env`.
    - Customize the `.env` file as needed. Refer to the `.env.example` file for detailed configuration options.
3. **Running the Services**:
    - Execute `docker compose up` from the `docker` directory to start the services.
    - To specify a vector database, set the `VECTOR_STORE` variable in your `.env` file to your desired vector database service, such as `milvus`, `weaviate`, or `opensearch`.
4. **SSL Certificate Setup**:
    - Refer `docker/certbot/README.md` to set up SSL certificates using Certbot.
5. **OpenTelemetry Collector Setup**:
   - Change `ENABLE_OTEL` to `true` in `.env`.
   - Configure `OTLP_BASE_ENDPOINT` properly.

### How to Deploy Middleware for Developing Dify

1. **Middleware Setup**:
    - Use the `docker-compose.middleware.yaml` for setting up essential middleware services like databases and caches.
    - Navigate to the `docker` directory.
    - Ensure the `middleware.env` file is created by running `cp middleware.env.example middleware.env` (refer to the `middleware.env.example` file).
2. **Running Middleware Services**:
    - Navigate to the `docker` directory.
    - Execute `docker compose -f docker-compose.middleware.yaml --profile weaviate -p dify up -d` to start the middleware services. (Change the profile to other vector database if you are not using weaviate)

### Migration for Existing Users

For users migrating from the `docker-legacy` setup:

1. **Review Changes**: Familiarize yourself with the new `.env` configuration and Docker Compose setup.
2. **Transfer Customizations**:
    - If you have customized configurations such as `docker-compose.yaml`, `ssrf_proxy/squid.conf`, or `nginx/conf.d/default.conf`, you will need to reflect these changes in the `.env` file you create.
3. **Data Migration**:
    - Ensure that data from services like databases and caches is backed up and migrated appropriately to the new structure if necessary.

### Overview of `.env`

#### Key Modules and Customization

- **Vector Database Services**: Depending on the type of vector database used (`VECTOR_STORE`), users can set specific endpoints, ports, and authentication details.
- **Storage Services**: Depending on the storage type (`STORAGE_TYPE`), users can configure specific settings for S3, Azure Blob, Google Storage, etc.
- **API and Web Services**: Users can define URLs and other settings that affect how the API and web frontend operate.

#### Other notable variables

The `.env.example` file provided in the Docker setup is extensive and covers a wide range of configuration options. It is structured into several sections, each pertaining to different aspects of the application and its services. Here are some of the key sections and variables:

1. **Common Variables**:
    - `CONSOLE_API_URL`, `SERVICE_API_URL`: URLs for different API services.
    - `APP_WEB_URL`: Frontend application URL.
    - `FILES_URL`: Base URL for file downloads and previews.

2. **Server Configuration**:
    - `LOG_LEVEL`, `DEBUG`, `FLASK_DEBUG`: Logging and debug settings.
    - `SECRET_KEY`: A key for encrypting session cookies and other sensitive data.

3. **Database Configuration**:
    - `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`: PostgreSQL database credentials and connection details.

4. **Redis Configuration**:
    - `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`: Redis server connection settings.

5. **Celery Configuration**:
    - `CELERY_BROKER_URL`: Configuration for Celery message broker.

6. **Storage Configuration**:
    - `STORAGE_TYPE`, `S3_BUCKET_NAME`, `AZURE_BLOB_ACCOUNT_NAME`: Settings for file storage options like local, S3, Azure Blob, etc.

7. **Vector Database Configuration**:
    - `VECTOR_STORE`: Type of vector database (e.g., `weaviate`, `milvus`).
    - Specific settings for each vector store like `WEAVIATE_ENDPOINT`, `MILVUS_URI`.

8. **CORS Configuration**:
    - `WEB_API_CORS_ALLOW_ORIGINS`, `CONSOLE_CORS_ALLOW_ORIGINS`: Settings for cross-origin resource sharing.

9. **OpenTelemetry Configuration**:
    - `ENABLE_OTEL`: Enable OpenTelemetry collector in api.
    - `OTLP_BASE_ENDPOINT`: Endpoint for your OTLP exporter.
  
10. **Other Service-Specific Environment Variables**:
    - Each service like `nginx`, `redis`, `db`, and vector databases have specific environment variables that are directly referenced in the `docker-compose.yaml`.

### Additional Information

- **Continuous Improvement Phase**: We are actively seeking feedback from the community to refine and enhance the deployment process. As more users adopt this new method, we will continue to make improvements based on your experiences and suggestions.
- **Support**: For detailed configuration options and environment variable settings, refer to the `.env.example` file and the Docker Compose configuration files in the `docker` directory.

This README aims to guide you through the deployment process using the new Docker Compose setup. For any issues or further assistance, please refer to the official documentation or contact support.

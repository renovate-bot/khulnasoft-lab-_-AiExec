# Docker Configuration

This directory contains Docker-related configurations for building, developing, and deploying the application. The structure has been reorganized to better separate build tools, deployment configurations, and development environments.

## Directory Structure

```
docker/
├── build/       # Dockerfiles for building container images
├── deploy/      # Production deployment configurations
├── dev/         # Development environment configurations
└── frontend/    # Frontend-specific Docker configurations
```

## Build (`build/`)

Contains Dockerfiles for building various container images:

- `build_and_push.Dockerfile` - Main build configuration
- `build_and_push_backend.Dockerfile` - Backend-specific build
- `build_and_push_base.Dockerfile` - Base image for other builds
- `build_and_push_ep.Dockerfile` - Enterprise edition build
- `build_and_push_with_extras.Dockerfile` - Build with additional dependencies
- `cdk.Dockerfile` - Container Development Kit build
- `dev.Dockerfile` - Development environment build
- `render.Dockerfile` - Configuration for Render deployments
- `render.pre-release.Dockerfile` - Pre-release configuration for Render

### Usage Example

```bash
# Build using one of the Dockerfiles
docker build -f docker/build/build_and_push.Dockerfile -t myapp:latest .
```

## Deployment (`deploy/`)

Contains configuration files for production deployment with Docker Compose, including all necessary middleware services:

- `docker-compose.yaml` - Main Docker Compose configuration
- `docker-compose.middleware.yaml` - Middleware services configuration
- `docker-compose-template.yaml` - Template for generating custom configurations
- `generate_docker_compose` - Script to generate Docker Compose from template
- `.env.example` - Example environment configuration
- `middleware.env.example` - Example middleware environment configuration

Various service configurations are included in subdirectories:
- `nginx/` - Web server and reverse proxy configuration
- `elasticsearch/` - Search engine configuration
- `pgvector/` - PostgreSQL with vector extensions
- `certbot/` - SSL certificate automation
- `tidb/` - TiDB database configuration
- `volumes/` - Persistent storage configurations

### Usage Example

```bash
# Start the full deployment stack
cd docker/deploy
cp .env.example .env
# Edit .env with your configuration
docker-compose up -d
```

## Development (`dev/`)

Contains configurations for development environments:

- `dev.docker-compose.yml` - Docker Compose for development
- `cdk-docker-compose.yml` - Docker Compose for Container Development Kit
- `dev.start.sh` - Development startup script
- `container-cmd-cdk.sh` - CDK container startup commands

### Usage Example

```bash
# Start development environment
cd docker/dev
./dev.start.sh
```

## Frontend (`frontend/`)

Contains Docker configurations specific to the frontend:

- `build_and_push_frontend.Dockerfile` - Frontend build configuration
- `nginx.conf` - Nginx configuration for frontend
- `default.conf.template` - Nginx default configuration template
- `start-nginx.sh` - Nginx startup script

### Usage Example

```bash
# Build the frontend image
docker build -f docker/frontend/build_and_push_frontend.Dockerfile -t myapp-frontend:latest .
```

## Migrating from the Previous Structure

This section provides guidance for users migrating from the previous directory structure where Docker files were split between `docker/` and `aiexec/docker/`.

### Overview of the Directory Reorganization

The Docker configurations have been reorganized as follows:

| Previous Location | New Location | Description |
|------------------|--------------|-------------|
| `docker/*.Dockerfile` | `docker/build/` | Build-related Dockerfiles |
| `docker/*.yml` | `docker/dev/` | Development Docker Compose files |
| `docker/*.sh` | `docker/dev/` | Development scripts |
| `docker/frontend/` | `docker/frontend/` | Frontend Docker configurations |
| `aiexec/docker/*` | `docker/deploy/` | Deployment and production Docker Compose |

### Environment File Handling

The deployment configuration now uses a consolidated environment file:

1. A comprehensive `.env.example` file is available in `docker/deploy/`
2. This file combines settings from both the previous Aiexec API and Docker deployment
3. If you have an existing `.env` file from the previous structure:
   - Copy it to `docker/deploy/.env`
   - Review the new `.env.example` for any new variables that might need to be added
   - Update service URLs to reference container names (e.g., `http://api:5001` instead of `http://localhost:5001`)

### Regenerating docker-compose.yaml

The `docker-compose.yaml` file in the deployment directory is auto-generated from:
- The `docker-compose-template.yaml` file
- Variables defined in `.env.example` or your custom `.env` file

To regenerate this file after making changes:

```bash
cd docker/deploy
# Edit .env or .env.example as needed
python generate_docker_compose
```

Key points to remember:
- Never directly edit `docker-compose.yaml` as your changes will be lost when regenerated
- Always make changes to the template and environment files, then regenerate
- The script automatically includes shared environment variables in the generated file

### Path Updates in Scripts and Configurations

If you have custom scripts or configurations that reference Docker files, update them as follows:

1. For build-related commands:
   ```bash
   # Old path
   docker build -f docker/build_and_push.Dockerfile -t myapp:latest .
   
   # New path
   docker build -f docker/build/build_and_push.Dockerfile -t myapp:latest .
   ```

2. For deployment commands:
   ```bash
   # Old path
   cd aiexec/docker && docker-compose up -d
   
   # New path
   cd docker/deploy && docker-compose up -d
   ```

3. For development environment:
   ```bash
   # Old path
   cd docker && ./dev.start.sh
   
   # New path
   cd docker/dev && ./dev.start.sh
   ```

4. Update any references to volume paths:
   ```bash
   # Old path
   ./aiexec/docker/volumes/app/storage:/app/api/storage
   
   # New path
   ./docker/deploy/volumes/app/storage:/app/api/storage
   ```

### Maintaining Different Deployment Configurations

This new structure better supports maintaining different deployment configurations:

1. **Production Deployment**:
   - Use the configurations in `docker/deploy/`
   - Create a production-specific `.env` file

2. **Development Environment**:
   - Use the configurations in `docker/dev/`
   - Create a development-specific `.env` file

3. **Custom Deployment Profiles**:
   - Copy and modify `docker-compose-template.yaml` for specific needs
   - Create corresponding environment files (e.g., `.env.staging`, `.env.testing`)
   - Use the `generate_docker_compose` script with your custom templates:
     ```bash
     cd docker/deploy
     # Generate from custom template and environment file
     python generate_docker_compose custom-template.yaml .env.custom custom-compose.yaml
     ```

4. **Docker Profiles for Optional Services**:
   - The deployment uses Docker Compose profiles for optional services
   - Start specific profiles with:
     ```bash
     # Start with vector database services
     docker-compose --profile weaviate up -d
     ```

## Migration FAQ

**Q: Will my existing data be preserved after migration?**  
A: Yes, as long as you keep your volume data intact. The volume paths have changed, so if you're using Docker volumes, ensure they're properly mapped to the new structure.

**Q: Do I need to rebuild my Docker images?**  
A: No, the Dockerfiles themselves have not changed, only their locations. Your existing images will continue to work.

**Q: How do I migrate my custom Docker Compose configuration?**  
A: Copy your customizations to the `docker-compose-template.yaml` file in the `docker/deploy/` directory, then regenerate the `docker-compose.yaml` file.

## Additional Resources

For more detailed information on specific deployment scenarios, please refer to:

- [Deploy README](./deploy/README.md) - For production deployment instructions
- [Development Environment](./dev/README.md) - For development setup instructions


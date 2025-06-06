# Development Environment

This directory contains Docker configurations specifically designed for local development. These configurations prioritize developer experience with features like hot reloading, volume mounting for code changes, and easy debugging.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Development Environment Setup](#development-environment-setup)
- [Development Workflow](#development-workflow)
- [Hot Reloading](#hot-reloading)
- [Debugging](#debugging)
- [Common Development Tasks](#common-development-tasks)
- [IDE Integration](#ide-integration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Docker Engine (version 20.10.0 or later)
- Docker Compose V2 (version 2.0.0 or later)
- Git
- Your preferred code editor or IDE
- Node.js 18+ and npm/yarn (for frontend development)
- Python 3.10+ (for backend development)

## Quick Start

The quickest way to get started with development is to use the provided development script:

```bash
# Navigate to the dev directory
cd docker/dev

# Start the development environment
./dev.start.sh
```

This will:

1. Set up all necessary services (database, Redis, etc.)
2. Mount your local code directories into the containers
3. Configure hot reloading for both frontend and backend
4. Expose all necessary ports for local development

Access your development environment:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5001

## Development Environment Setup

### Manual Setup

If you prefer to set up the environment manually or need more customization:

1. Create a development `.env` file:

```bash
# Copy the example environment file
cp dev.env.example dev.env

# Edit with your preferences
nano dev.env
```

2. Start the specific services you need:

```bash
# Start the full stack
docker-compose -f dev.docker-compose.yml up -d

# Or start only specific services
docker-compose -f dev.docker-compose.yml up -d db redis weaviate
```

### Using Development Middleware

If you only need the supporting services (database, Redis, etc.) and plan to run the application code directly on your machine:

```bash
# Navigate to the deploy directory
cd ../deploy

# Copy the middleware environment file
cp middleware.env.example middleware.env

# Start middleware services
docker-compose -f docker-compose.middleware.yaml --profile weaviate up -d
```

### Bind Mounts and Volumes

The development environment uses bind mounts to connect your local source code with the containers:

```yaml
volumes:
  # Backend code
  - ../../api:/app/api
  # Frontend code
  - ../../web:/app/web
```

This allows you to edit code on your host machine while having the changes immediately reflected in the containers.

## Development Workflow

### Backend Development

1. **Code Changes**: Edit Python files in the `api/` directory on your local machine
2. **Auto-Reload**: The API service uses a development server that automatically reloads when files change
3. **Database Migrations**: Run migrations through the container when needed

```bash
# Apply database migrations
docker-compose -f dev.docker-compose.yml exec api flask db upgrade

# Create a new migration
docker-compose -f dev.docker-compose.yml exec api flask db migrate -m "description of changes"
```

### Frontend Development

1. **Code Changes**: Edit files in the `web/` directory on your local machine
2. **Auto-Reload**: The web service will automatically detect changes and rebuild
3. **Package Management**: You can run npm/yarn commands through the container

```bash
# Install a new package
docker-compose -f dev.docker-compose.yml exec web npm install --save new-package

# Run tests
docker-compose -f dev.docker-compose.yml exec web npm test
```

### Development Patterns

For efficient development:

1. **Feature Branches**: Create a branch for each feature or bugfix
2. **Local Testing**: Test thoroughly in the development environment before pushing
3. **Regular Rebuilds**: If you change dependencies (package.json, requirements.txt), rebuild the containers:

```bash
docker-compose -f dev.docker-compose.yml up -d --build
```

## Hot Reloading

### Backend Hot Reloading

The backend API service is configured to automatically reload when Python files change. This is handled by:

- Flask's debug mode for the API server
- Volume mounts that sync your local code with the container

If hot reloading isn't working:

1. Check that `FLASK_DEBUG=true` is set in your environment
2. Ensure the volume mounts are correctly configured
3. Try restarting just the API service: `docker-compose -f dev.docker-compose.yml restart api`

### Frontend Hot Reloading

The frontend service uses Next.js development mode, which includes:

- Hot Module Replacement (HMR) for JavaScript/TypeScript files
- Fast Refresh for React components
- CSS/SCSS hot reloading

For the best development experience:

1. Ensure port 3000 is exposed in the docker-compose file
2. Access the application via http://localhost:3000 (not through NGINX)
3. Keep the browser's development console open to see any errors

## Debugging

### Backend Debugging

You can debug the Python backend using:

1. **Print statements**: Simple but effective, outputs to container logs
2. **Debugger integration**: The development container supports Python debuggers

For using pdb or other Python debuggers:

```bash
# Access the running container
docker-compose -f dev.docker-compose.yml exec api bash

# Run a specific script with the debugger
cd /app/api
python -m pdb some_script.py
```

For advanced debugging with IDEs, see the [IDE Integration](#ide-integration) section.

### Frontend Debugging

Debug the frontend using:

1. **Browser DevTools**: Use Chrome/Firefox developer tools
2. **React DevTools**: Install the browser extension for React-specific debugging
3. **Console Logging**: `console.log()` statements appear in the browser console

### Viewing Logs

Logs are essential for debugging:

```bash
# View logs for all services
docker-compose -f dev.docker-compose.yml logs

# View logs for a specific service
docker-compose -f dev.docker-compose.yml logs api

# Follow logs in real-time
docker-compose -f dev.docker-compose.yml logs -f web

# View last 100 lines of logs
docker-compose -f dev.docker-compose.yml logs --tail=100 api
```

## Common Development Tasks

### Running Tests

```bash
# Backend tests
docker-compose -f dev.docker-compose.yml exec api pytest

# Frontend tests
docker-compose -f dev.docker-compose.yml exec web npm test
```

### Database Operations

```bash
# Access PostgreSQL CLI
docker-compose -f dev.docker-compose.yml exec db psql -U postgres -d dify

# Reset the database (caution: destroys data)
docker-compose -f dev.docker-compose.yml down -v db
docker-compose -f dev.docker-compose.yml up -d db
docker-compose -f dev.docker-compose.yml exec api flask db upgrade
```

### Package Management

```bash
# Backend (Python)
docker-compose -f dev.docker-compose.yml exec api pip install new-package
docker-compose -f dev.docker-compose.yml exec api pip freeze > requirements.txt

# Frontend (Node.js)
docker-compose -f dev.docker-compose.yml exec web npm install new-package
```

### Running One-off Commands

```bash
# Run a Python script
docker-compose -f dev.docker-compose.yml exec api python -m scripts.my_script

# Run npm scripts
docker-compose -f dev.docker-compose.yml exec web npm run custom-script
```

### Rebuilding Services

When you make changes to Dockerfiles or dependencies:

```bash
# Rebuild a specific service
docker-compose -f dev.docker-compose.yml up -d --build api

# Rebuild all services
docker-compose -f dev.docker-compose.yml up -d --build
```

## IDE Integration

### Visual Studio Code

VS Code offers excellent Docker and remote development support:

1. Install the "Remote - Containers" extension
2. Use "Attach to Running Container" to connect to development containers
3. Set up launch configurations for debugging:

```json
// .vscode/launch.json example
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Remote Attach",
      "type": "python",
      "request": "attach",
      "connect": {
        "host": "localhost",
        "port": 5678
      },
      "pathMappings": [
        {
          "localRoot": "${workspaceFolder}/api",
          "remoteRoot": "/app/api"
        }
      ]
    }
  ]
}
```

### PyCharm

For PyCharm Professional:

1. Go to Settings → Project → Python Interpreter
2. Click the gear icon → Add → Docker Compose
3. Select the docker-compose.yml file and the api service
4. Configure path mappings to match your volume mounts

### WebStorm/IntelliJ IDEA

For frontend development:

1. Install the Docker integration plugin
2. Configure a Node.js interpreter inside the web container
3. Set up run/debug configurations that use this interpreter

## Troubleshooting

### Common Issues

#### Services Won't Start

**Problem**: One or more services fail to start.

**Solution**:
1. Check container logs: `docker-compose -f dev.docker-compose.yml logs [service-name]`
2. Ensure ports aren't already in use on your host machine
3. Verify file permissions on mounted volumes
4. Try recreating the containers: `docker-compose -f dev.docker-compose.yml up -d --force-recreate`

#### Hot Reload Not Working

**Problem**: Code changes aren't reflected in the running application.

**Solution**:
1. Check volume mounts in the docker-compose file
2. Ensure development mode is enabled (FLASK_DEBUG=true, etc.)
3. Some changes require a service restart: `docker-compose -f dev.docker-compose.yml restart [service-name]`
4. For backend, check if the debugger is paused at a breakpoint

#### Connection Refused Errors

**Problem**: Services can't connect to each other.

**Solution**:
1. Ensure all required services are running: `docker-compose -f dev.docker-compose.yml ps`
2. Check if services are using the correct hostnames (container names) for internal communication
3. Verify network configuration in docker-compose file
4. Try recreating the Docker network: `docker-compose -f dev.docker-compose.yml down && docker-compose -f dev.docker-compose.yml up -d`

#### Performance Issues

**Problem**: Development environment is slow.

**Solution**:
1. Increase Docker resource allocation (CPU, memory) in Docker Desktop settings
2. Reduce the number of running services to only what you need
3. Use selective volume mounting rather than mounting entire directories
4. On Windows/macOS, optimize volume performance:
   - Use Docker's native volume mounting where possible
   - Consider using Docker's new improved virtualization features

### Getting Help

If you encounter issues not covered here:

1. Check Docker and container logs for specific error messages
2. Search for known issues in the project repository
3. Ask for help in the project's Discord channel or discussion forum
4. Provide detailed information when reporting issues, including:
   - Docker and Docker Compose versions
   - Host OS information
   - Error logs
   - Steps to reproduce

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Next.js Documentation](https://nextjs.org/docs)


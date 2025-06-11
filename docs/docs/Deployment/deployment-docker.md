---
title: Deploy Aiexec on Docker
slug: /deployment-docker
---

This guide demonstrates deploying Aiexec with Docker and Docker Compose.

Three options are available:

* The [Quickstart](#quickstart) option starts a Docker container with default values.
* The [Docker compose](#clone-the-repo-and-build-the-aiexec-docker-container) option builds Aiexec with a persistent PostgreSQL database service.
* The [Package your flow as a docker image](#package-your-flow-as-a-docker-image) option demonstrates packaging an existing flow with a Dockerfile.

For more information on configuring the Docker image, see [Customize the Aiexec Docker image with your own code](#customize-the-aiexec-docker-image-with-your-own-code).

## Prerequisites

- [Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Quickstart

With Docker installed and running on your system, run this command:

`docker run -p 7860:7860 aiexecai/aiexec:latest`

Aiexec is now accessible at `http://localhost:7860/`.
## Clone the repo and build the Aiexec Docker container

1. Clone the Aiexec repository:

   `git clone https://github.com/khulnasoft-lab/aiexec.git`

2. Navigate to the `docker_example` directory:

   `cd aiexec/docker_example`

3. Run the Docker Compose file:

   `docker compose up`

Aiexec is now accessible at `http://localhost:7860/`.

### Configure Docker services

The Docker Compose configuration spins up two services: `aiexec` and `postgres`.

To configure values for these services at container startup, include them in your `.env` file.

An example `.env` file is available in the [project repository](https://github.com/khulnasoft-lab/aiexec/blob/main/.env.example).

To pass the `.env` values at container startup, include the flag in your `docker run` command:

```
docker run -it --rm \
    -p 7860:7860 \
    --env-file .env \
    aiexecai/aiexec:latest
```

### Aiexec service

The `aiexec`service serves both the backend API and frontend UI of the Aiexec web application.

The `aiexec` service uses the `aiexecai/aiexec:latest` Docker image and exposes port `7860`. It depends on the `postgres` service.

Environment variables:

- `AIEXEC_DATABASE_URL`: The connection string for the PostgreSQL database.
- `AIEXEC_CONFIG_DIR`: The directory where Aiexec stores logs, file storage, monitor data, and secret keys.

Volumes:

- `aiexec-data`: This volume is mapped to `/app/aiexec` in the container.

### PostgreSQL service

The `postgres` service is a database that stores Aiexec's persistent data including flows, users, and settings.

The service runs on port 5432 and includes a dedicated volume for data storage.

The `postgres` service uses the `postgres:16` Docker image.

Environment variables:

- `POSTGRES_USER`: The username for the PostgreSQL database.
- `POSTGRES_PASSWORD`: The password for the PostgreSQL database.
- `POSTGRES_DB`: The name of the PostgreSQL database.

Volumes:

- `aiexec-postgres`: This volume is mapped to `/var/lib/postgresql/data` in the container.

### Deploy a specific Aiexec version with Docker Compose

If you want to deploy a specific version of Aiexec, you can modify the `image` field under the `aiexec` service in the Docker Compose file. For example, to use version `1.0-alpha`, change `aiexecai/aiexec:latest` to `aiexecai/aiexec:1.0-alpha`.

## Package your flow as a Docker image

You can include your Aiexec flow with the application image.
When you build the image, your saved flow `.JSON` flow is included.
This enables you to serve a flow from a container, push the image to Docker Hub, and deploy on Kubernetes.

An example flow is available in the [Aiexec Helm Charts](https://github.com/khulnasoft-lab/aiexec-helm-charts/tree/main/examples/flows) repository, or you can provide your own `JSON` file.

1. Create a project directory:

```bash
mkdir aiexec-custom && cd aiexec-custom
```

2. Download the example flow or include your flow's `.JSON` file in the `aiexec-custom` directory.

```bash
wget https://raw.githubusercontent.com/khulnasoft-lab/aiexec-helm-charts/refs/heads/main/examples/flows/basic-prompting-hello-world.json
```

3. Create a Dockerfile:

```dockerfile
FROM aiexecai/aiexec-backend:latest
RUN mkdir /app/flows
COPY ./*json /app/flows/.
ENV AIEXEC_LOAD_FLOWS_PATH=/app/flows
```

The `COPY ./*json` command copies all JSON files in your current directory to the `/flows` folder.

The `ENV AIEXEC_LOAD_FLOWS_PATH=/app/flows` command sets the environment variable within the Docker container. By pointing it to `/app/flows`, you ensure that the application can find and utilize the JSON flow files that have been copied into that directory during the image build process.

4. Build and run the image locally.

```bash
docker build -t myuser/aiexec-hello-world:1.0.0 .
docker run -p 7860:7860 myuser/aiexec-hello-world:1.0.0
```

5. Build and push the image to Docker Hub.
   Replace `myuser` with your Docker Hub username.

```bash
docker build -t myuser/aiexec-hello-world:1.0.0 .
docker push myuser/aiexec-hello-world:1.0.0
```

To deploy the image with Helm, see [Deploy the Aiexec production environment on Kubernetes](/deployment-kubernetes-prod).

## Customize the Aiexec Docker image with your own code

You can customize the Aiexec Docker image by adding your own code or modifying existing components.

This example Dockerfile demonstrates how to customize Aiexec by replacing the `astradb_graph.py` component, but the pattern can be adapted for any other components or custom code.

```dockerfile
FROM aiexecai/aiexec:latest
# Set working directory
WORKDIR /app
# Copy your modified astradb_graph.py file
COPY src/backend/base/aiexec/components/vectorstores/astradb_graph.py /tmp/astradb_graph.py
# Find the site-packages directory where aiexec is installed
RUN python -c "import site; print(site.getsitepackages()[0])" > /tmp/site_packages.txt
# Replace the file in the site-packages location
RUN SITE_PACKAGES=$(cat /tmp/site_packages.txt) && \
    echo "Site packages at: $SITE_PACKAGES" && \
    mkdir -p "$SITE_PACKAGES/aiexec/components/vectorstores" && \
    cp /tmp/astradb_graph.py "$SITE_PACKAGES/aiexec/components/vectorstores/"
# Clear Python cache in the site-packages directory only
RUN SITE_PACKAGES=$(cat /tmp/site_packages.txt) && \
    find "$SITE_PACKAGES" -name "*.pyc" -delete && \
    find "$SITE_PACKAGES" -name "__pycache__" -type d -exec rm -rf {} +
# Expose the default Aiexec port
EXPOSE 7860
# Command to run Aiexec
CMD ["python", "-m", "aiexec", "run", "--host", "0.0.0.0", "--port", "7860"]
```

To use this custom Dockerfile, do the following:

1. Create a directory for your custom Aiexec setup:
```bash
mkdir aiexec-custom && cd aiexec-custom
```

2. Create the necessary directory structure for your custom code.
In this example, Aiexec expects `astradb_graph.py` to exist in the `/vectorstores` directory, so you create a directory in that location.
```bash
mkdir -p src/backend/base/aiexec/components/vectorstores
```

3. Place your modified `astradb_graph.py` file in the `/vectorstores` directory.

4. Create a new file named `Dockerfile` in your `aiexec-custom` directory, and then copy the Dockerfile contents shown above into it.

5. Build and run the image:
```bash
docker build -t myuser/aiexec-custom:1.0.0 .
docker run -p 7860:7860 myuser/aiexec-custom:1.0.0
```

This approach can be adapted for any other components or custom code you want to add to Aiexec by modifying the file paths and component names.
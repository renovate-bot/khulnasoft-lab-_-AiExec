---
title: Configure an external PostgreSQL database
slug: /configuration-custom-database
---
Aiexec's default database is [SQLite](https://www.sqlite.org/docs.html), but you can configure Aiexec to use PostgreSQL instead.

This guide walks you through setting up an external database for Aiexec by replacing the default SQLite connection string `sqlite:///./aiexec.db` with PostgreSQL.

## Prerequisite

* A [PostgreSQL](https://www.pgadmin.org/download/) database

## Connect Aiexec to PostgreSQL

To connect Aiexec to PostgreSQL, follow these steps.

1. Find your PostgreSQL database's connection string.
It looks like `postgresql://user:password@host:port/dbname`.

The hostname in your connection string depends on how you're running PostgreSQL.
- If you're running PostgreSQL directly on your machine, use `localhost`.
- If you're running PostgreSQL in Docker Compose, use the service name, such as `postgres`.
- If you're running PostgreSQL in a separate Docker container with `docker run`, use the container's IP address or network alias.

2. Create a `.env` file for configuring Aiexec.
```
touch .env
```

3. To set the database URL environment variable, add it to your `.env` file:
```text
AIEXEC_DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
```

:::tip
The Aiexec project includes a [`.env.example`](https://github.com/khulnasoft-lab/aiexec/blob/main/.env.example) file to help you get started.
You can copy the contents of this file into your own `.env` file and replace the example values with your own preferred settings.
Replace the value for `AIEXEC_DATABASE_URL` with your PostgreSQL connection string.
:::

4. Run Aiexec with the `.env` file:
```bash
uv run aiexec run --env-file .env
```

5. In Aiexec, create traffic by running a flow.
6. Inspect your PostgreSQL deployment's tables and activity.
New tables and traffic are created.

## Example Aiexec and PostgreSQL docker-compose.yml

The Aiexec project includes a [docker-compose.yml](https://github.com/khulnasoft-lab/aiexec/blob/main/docker_example/docker-compose.yml) file for quick deployment with PostgreSQL.

This configuration launches Aiexec and PostgreSQL containers in the same Docker network, ensuring proper connectivity between services. It also sets up persistent volumes for both Aiexec and PostgreSQL data.

To start the services, navigate to the `/docker_example` directory, and then run `docker-compose up`.

```yaml
services:
  aiexec:
    image: aiexecai/aiexec:latest    # or another version tag on https://hub.docker.com/r/aiexecai/aiexec
    pull_policy: always                   # set to 'always' when using 'latest' image
    ports:
      - "7860:7860"
    depends_on:
      - postgres
    environment:
      - AIEXEC_DATABASE_URL=postgresql://aiexec:aiexec@postgres:5432/aiexec
      # This variable defines where the logs, file storage, monitor data, and secret keys are stored.
      - AIEXEC_CONFIG_DIR=app/aiexec
    volumes:
      - aiexec-data:/app/aiexec

  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: aiexec
      POSTGRES_PASSWORD: aiexec
      POSTGRES_DB: aiexec
    ports:
      - "5432:5432"
    volumes:
      - aiexec-postgres:/var/lib/postgresql/data

volumes:
  aiexec-postgres:    # Persistent volume for PostgreSQL data
  aiexec-data:        # Persistent volume for Aiexec data
```

:::note
Docker Compose creates an isolated network for all services defined in the docker-compose.yml file. This ensures that the services can communicate with each other using their service names as hostnames, for example, `postgres` in the database URL. If you were to run PostgreSQL separately using `docker run`, it would be in a different network and Aiexec wouldn't be able to connect to it using the service name.
:::

## Deploy multiple Aiexec instances with a shared database

To configure multiple Aiexec instances that share the same PostgreSQL database, modify your `docker-compose.yml` file to include multiple Aiexec services.

Use environment variables for more centralized configuration management:

1. Update your `.env` file with values for your PostgreSQL database:
```text
POSTGRES_USER=aiexec
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=aiexec
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
AIEXEC_CONFIG_DIR=app/aiexec
AIEXEC_PORT_1=7860
AIEXEC_PORT_2=7861
AIEXEC_HOST=0.0.0.0
```
2. Reference these variables in your `docker-compose.yml`:
```yaml
services:
  postgres:
    image: postgres:16
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - aiexec-postgres:/var/lib/postgresql/data

  aiexec-1:
    image: aiexecai/aiexec:latest
    pull_policy: always
    ports:
      - "${AIEXEC_PORT_1}:7860"
    depends_on:
      - postgres
    environment:
      - AIEXEC_DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
      - AIEXEC_CONFIG_DIR=${AIEXEC_CONFIG_DIR}
      - AIEXEC_HOST=${AIEXEC_HOST}
      - PORT=7860
    volumes:
      - aiexec-data-1:/app/aiexec

  aiexec-2:
    image: aiexecai/aiexec:latest
    pull_policy: always
    ports:
      - "${AIEXEC_PORT_2}:7860"
    depends_on:
      - postgres
    environment:
      - AIEXEC_DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
      - AIEXEC_CONFIG_DIR=${AIEXEC_CONFIG_DIR}
      - AIEXEC_HOST=${AIEXEC_HOST}
      - PORT=7860
    volumes:
      - aiexec-data-2:/app/aiexec

volumes:
  aiexec-postgres:
  aiexec-data-1:
  aiexec-data-2:
```

3. Deploy the file with `docker-compose up`.
You can access the first Aiexec instance at `http://localhost:7860`, and the second Aiexec instance at `http://localhost:7861`.

4. To confirm both instances are using the same database, run the `docker exec` command to start `psql` in your PostgreSQL container.
Your container name may vary.
```bash
docker exec -it docker-test-postgres-1 psql -U aiexec -d aiexec
```

5. Query the database for active connections:
```sql
aiexec=# SELECT * FROM pg_stat_activity WHERE datname = 'aiexec';
```

6. Examine the query results for multiple connections with different `client_addr` values, for example `172.21.0.3` and `172.21.0.4`.

Since each Aiexec instance runs in its own container on the Docker network, using different incoming IP addresses confirms that both instances are actively connected to the PostgreSQL database.

7. To quit psql, type `quit`.
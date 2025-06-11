---
title: Environment variables
slug: /environment-variables
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import Link from '@docusaurus/Link';


Aiexec lets you configure a number of settings using environment variables.

## Configure environment variables

Aiexec recognizes [supported environment variables](#supported-variables) from the following sources:

- Environment variables that you've set in your terminal.
- Environment variables that you've imported from a `.env` file using the `--env-file` option in the Aiexec CLI.

You can choose to use one source exclusively, or use both sources together.
If you choose to use both sources together, be aware that environment variables imported from a `.env` file take [precedence](#precedence) over those set in your terminal.

### Set environment variables in your terminal {#configure-variables-terminal}

Run the following commands to set environment variables for your current terminal session:

<Tabs>

<TabItem value="linux-macos" label="Linux or macOS" default>
```bash
export VARIABLE_NAME='VALUE'
```
</TabItem>

<TabItem value="windows" label="Windows" default>
```
set VARIABLE_NAME='VALUE'
```
</TabItem>

<TabItem value="docker" label="Docker" default>
```bash
docker run -it --rm \
    -p 7860:7860 \
    -e VARIABLE_NAME='VALUE' \
    aiexecai/aiexec:latest
```
</TabItem>

</Tabs>

When you start Aiexec, it looks for environment variables that you've set in your terminal.
If it detects a supported environment variable, then it automatically adopts the specified value, subject to [precedence rules](#precedence).

### Import environment variables from a .env file {#configure-variables-env-file}

1. Create a `.env` file and open it in your preferred editor.

2. Add your environment variables to the file:

    ```text title=".env"
    DO_NOT_TRACK=true
    AIEXEC_AUTO_LOGIN=false
    AIEXEC_AUTO_SAVING=true
    AIEXEC_AUTO_SAVING_INTERVAL=1000
    AIEXEC_BACKEND_ONLY=false
    AIEXEC_BUNDLE_URLS=["https://github.com/user/repo/commit/hash"]
    AIEXEC_CACHE_TYPE=async
    AIEXEC_COMPONENTS_PATH=/path/to/components/
    AIEXEC_CONFIG_DIR=/path/to/config/
    AIEXEC_DATABASE_URL=postgresql://user:password@localhost:5432/aiexec
    AIEXEC_DEV=false
    AIEXEC_FALLBACK_TO_ENV_VAR=false
    AIEXEC_HEALTH_CHECK_MAX_RETRIES=5
    AIEXEC_HOST=127.0.0.1
    AIEXEC_LANGCHAIN_CACHE=InMemoryCache
    AIEXEC_MAX_FILE_SIZE_UPLOAD=10000
    AIEXEC_LOG_LEVEL=error
    AIEXEC_OPEN_BROWSER=false
    AIEXEC_PORT=7860
    AIEXEC_REMOVE_API_KEYS=false
    AIEXEC_SAVE_DB_IN_CONFIG_DIR=true
    AIEXEC_SECRET_KEY=somesecretkey
    AIEXEC_STORE=true
    AIEXEC_STORE_ENVIRONMENT_VARIABLES=true
    AIEXEC_SUPERUSER=adminuser
    AIEXEC_SUPERUSER_PASSWORD=adminpass
    AIEXEC_WORKER_TIMEOUT=60000
    AIEXEC_WORKERS=3
    ```

    :::tip
    The Aiexec project includes a [`.env.example`](https://github.com/khulnasoft-lab/aiexec/blob/main/.env.example) file to help you get started.
    You can copy the contents of this file into your own `.env` file and replace the example values with your own preferred settings.
    :::

3. Save and close the file.

4. Start Aiexec using the `--env-file` option to define the path to your `.env` file:

   <Tabs>

    <TabItem value="local" label="Local" default>
    ```bash
    python -m aiexec run --env-file .env
    ```
    </TabItem>

    <TabItem value="docker" label="Docker" default>
    ```bash
    docker run -it --rm \
        -p 7860:7860 \
        --env-file .env \
        aiexecai/aiexec:latest
    ```
    </TabItem>

    </Tabs>

On startup, Aiexec imports the environment variables from your `.env` file, as well as any that you [set in your terminal](#configure-variables-terminal), and adopts their specified values.

## Precedence {#precedence}

Environment variables [defined in the .env file](#configure-variables-env-file) take precedence over those [set in your terminal](#configure-variables-terminal).
That means, if you happen to set the same environment variable in both your terminal and your `.env` file, Aiexec adopts the value from the the `.env` file.

:::info[CLI precedence]
[Aiexec CLI options](./configuration-cli.md) override the value of corresponding environment variables defined in the `.env` file as well as any environment variables set in your terminal.
:::

## Supported environment variables {#supported-variables}

The following table lists the environment variables supported by Aiexec.

<style>
{`
  .env-table {
    width: 100%;
    max-width: 100%;
    table-layout: fixed;
  }
  .env-table td:first-child {
    width: 30%;
    font-family: var(--ifm-font-family-monospace);
    background: var(--prism-background);
    border-radius: 6px;
    padding: 8px;
    word-break: break-word;
  }
  .env-table td:nth-child(2) {
    width: 15%;
  }
  .env-table td:nth-child(3) {
    width: 15%;
  }
  .env-table td:nth-child(4) {
    width: 40%;
  }
  .env-table td {
    padding: 8px;
    vertical-align: top;
  }
  .env-prefix {
    opacity: 0.7;
  }
  .env-table tr {
    border-top: 1px solid var(--ifm-table-border-color);
  }
  .env-table code {
    white-space: nowrap;
  }
`}
</style>

<div class="env-table">

| Variable | Format | Default | Description |
|----------|--------|---------|-------------|
| <Link id="DO_NOT_TRACK"/>DO_NOT_TRACK | Boolean | `false` | If this option is enabled, Aiexec does not track telemetry. |
| <Link id="AIEXEC_AUTO_LOGIN"/><span class="env-prefix">AIEXEC_</span>AUTO_LOGIN | Boolean | `true` | Enable automatic login for Aiexec. Set to `false` to disable automatic login and require the login form to log into the Aiexec UI. Setting to `false` requires [`AIEXEC_SUPERUSER`](#AIEXEC_SUPERUSER) and [`AIEXEC_SUPERUSER_PASSWORD`](environment-variables.md#AIEXEC_SUPERUSER_PASSWORD) to be set. |
| <Link id="AIEXEC_AUTO_SAVING"/><span class="env-prefix">AIEXEC_</span>AUTO_SAVING | Boolean | `true` | Enable flow auto-saving.<br/>See [`--auto-saving` option](./configuration-cli.md#run-auto-saving). |
| <Link id="AIEXEC_AUTO_SAVING_INTERVAL"/><span class="env-prefix">AIEXEC_</span>AUTO_SAVING_INTERVAL | Integer | `1000` | Set the interval for flow auto-saving in milliseconds.<br/>See [`--auto-saving-interval` option](./configuration-cli.md#run-auto-saving-interval). |
| <Link id="AIEXEC_BACKEND_ONLY"/><span class="env-prefix">AIEXEC_</span>BACKEND_ONLY | Boolean | `false` | Only run Aiexec's backend server (no frontend).<br/>See [`--backend-only` option](./configuration-cli.md#run-backend-only). |
| <Link id="AIEXEC_BUNDLE_URLS"/><span class="env-prefix">AIEXEC_</span>BUNDLE_URLS | List[String] | `[]` | A list of URLs from which to load component bundles and flows. Supports GitHub URLs. If <span class="env-prefix">AIEXEC_</span>AUTO_LOGIN is enabled, flows from these bundles are loaded into the database. |
| <Link id="AIEXEC_CACHE_TYPE"/><span class="env-prefix">AIEXEC_</span>CACHE_TYPE | String | `async` | Set the cache type for Aiexec. Possible values: `async`, `redis`, `memory`, `disk`.<br/>If you set the type to `redis`, then you must also set the following environment variables: <span class="env-prefix">AIEXEC_REDIS_HOST</span>, <span class="env-prefix">AIEXEC_REDIS_PORT</span>, <span class="env-prefix">AIEXEC_REDIS_DB</span>, and <span class="env-prefix">AIEXEC_REDIS_CACHE_EXPIRE</span>. |
| <Link id="AIEXEC_COMPONENTS_PATH"/><span class="env-prefix">AIEXEC_</span>COMPONENTS_PATH | String | `aiexec/components` | Path to the directory containing custom components.<br/>See [`--components-path` option](./configuration-cli.md#run-components-path). |
| <Link id="AIEXEC_CONFIG_DIR"/><span class="env-prefix">AIEXEC_</span>CONFIG_DIR | String | See description | Set the Aiexec configuration directory where files, logs, and the Aiexec database are stored. Defaults: **Linux/WSL**: `~/.cache/aiexec/`<br/>**macOS**: `/Users/<username>/Library/Caches/aiexec/`<br/>**Windows**: `%LOCALAPPDATA%\aiexec\aiexec\Cache`|
| <Link id="AIEXEC_DATABASE_URL"/><span class="env-prefix">AIEXEC_</span>DATABASE_URL | String | Not set | Set the database URL for Aiexec. If not provided, Aiexec uses a SQLite database. |
| <Link id="AIEXEC_DATABASE_CONNECTION_RETRY"/><span class="env-prefix">AIEXEC_</span>DATABASE_CONNECTION_RETRY | Boolean | `false` | If True, Aiexec tries to connect to the database again if it fails. |
| <Link id="AIEXEC_DB_POOL_SIZE"/><span class="env-prefix">AIEXEC_</span>DB_POOL_SIZE | Integer | `10` | **DEPRECATED:** Use <span class="env-prefix">AIEXEC_</span>DB_CONNECTION_SETTINGS instead. The number of connections to keep open in the connection pool. |
| <Link id="AIEXEC_DB_MAX_OVERFLOW"/><span class="env-prefix">AIEXEC_</span>DB_MAX_OVERFLOW | Integer | `20` | **DEPRECATED:** Use <span class="env-prefix">AIEXEC_</span>DB_CONNECTION_SETTINGS instead. The number of connections to allow that can be opened beyond the pool size. |
| <Link id="AIEXEC_DB_CONNECT_TIMEOUT"/><span class="env-prefix">AIEXEC_</span>DB_CONNECT_TIMEOUT | Integer | `20` | The number of seconds to wait before giving up on a lock to be released or establishing a connection to the database. |
| <Link id="AIEXEC_DB_CONNECTION_SETTINGS"/><span class="env-prefix">AIEXEC_</span>DB_CONNECTION_SETTINGS | JSON | Not set | A JSON dictionary to centralize database connection parameters. Example: `{"pool_size": 10, "max_overflow": 20}` |
| <Link id="AIEXEC_ENABLE_LOG_RETRIEVAL"/><span class="env-prefix">AIEXEC_</span>ENABLE_LOG_RETRIEVAL | Boolean | `false` | Enable log retrieval functionality. |
| <Link id="AIEXEC_FALLBACK_TO_ENV_VAR"/><span class="env-prefix">AIEXEC_</span>FALLBACK_TO_ENV_VAR | Boolean | `true` | If enabled, [global variables](../Configuration/configuration-global-variables.md) set in the Aiexec UI fall back to an environment variable with the same name when Aiexec fails to retrieve the variable value. |
| <Link id="AIEXEC_FRONTEND_PATH"/><span class="env-prefix">AIEXEC_</span>FRONTEND_PATH | String | `./frontend` | Path to the frontend directory containing build files. This is for development purposes only.<br/>See [`--frontend-path` option](./configuration-cli.md#run-frontend-path). |
| <Link id="AIEXEC_HEALTH_CHECK_MAX_RETRIES"/><span class="env-prefix">AIEXEC_</span>HEALTH_CHECK_MAX_RETRIES | Integer | `5` | Set the maximum number of retries for the health check.<br/>See [`--health-check-max-retries` option](./configuration-cli.md#run-health-check-max-retries). |
| <Link id="AIEXEC_HOST"/><span class="env-prefix">AIEXEC_</span>HOST | String | `127.0.0.1` | The host on which the Aiexec server will run.<br/>See [`--host` option](./configuration-cli.md#run-host). |
| <Link id="AIEXEC_LANGCHAIN_CACHE"/><span class="env-prefix">AIEXEC_</span>LANGCHAIN_CACHE | String | `InMemoryCache` | Type of cache to use. Possible values: `InMemoryCache`, `SQLiteCache`.<br/>See [`--cache` option](./configuration-cli.md#run-cache). |
| <Link id="AIEXEC_LOG_LEVEL"/><span class="env-prefix">AIEXEC_</span>LOG_LEVEL | String | `INFO` | Set the logging level for Aiexec. Possible values: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`. |
| <Link id="AIEXEC_LOG_FILE"/><span class="env-prefix">AIEXEC_</span>LOG_FILE | String | Not set | Path to the log file. If this option is not set, logs are written to stdout. |
| <Link id="AIEXEC_LOG_RETRIEVER_BUFFER_SIZE"/><span class="env-prefix">AIEXEC_</span>LOG_RETRIEVER_BUFFER_SIZE | Integer | `10000` | Set the buffer size for log retrieval. Only used if `AIEXEC_ENABLE_LOG_RETRIEVAL` is enabled. |
| <Link id="AIEXEC_MAX_FILE_SIZE_UPLOAD"/><span class="env-prefix">AIEXEC_</span>MAX_FILE_SIZE_UPLOAD | Integer | `100` | Set the maximum file size for the upload in megabytes.<br/>See [`--max-file-size-upload` option](./configuration-cli.md#run-max-file-size-upload). |
| <Link id="AIEXEC_MCP_SERVER_ENABLED"/><span class="env-prefix">AIEXEC_</span>MCP_SERVER_ENABLED | Boolean | `true` | If this option is set to False, Aiexec does not enable the MCP server. |
| <Link id="AIEXEC_MCP_SERVER_ENABLE_PROGRESS_NOTIFICATIONS"/><span class="env-prefix">AIEXEC_</span>MCP_SERVER_ENABLE_PROGRESS_NOTIFICATIONS | Boolean | `false` | If this option is set to True, Aiexec sends progress notifications in the MCP server. |
| <Link id="AIEXEC_NEW_USER_IS_ACTIVE"/><span class="env-prefix">AIEXEC_</span>NEW_USER_IS_ACTIVE | Boolean | `false` | When enabled, new users are automatically activated and can log in without requiring explicit activation by the superuser. |
| <Link id="AIEXEC_OPEN_BROWSER"/><span class="env-prefix">AIEXEC_</span>OPEN_BROWSER | Boolean | `false` | Open the system web browser on startup.<br/>See [`--open-browser` option](./configuration-cli.md#run-open-browser). |
| <Link id="AIEXEC_PORT"/><span class="env-prefix">AIEXEC_</span>PORT | Integer | `7860` | The port on which the Aiexec server runs. The server automatically selects a free port if the specified port is in use.<br/>See [`--port` option](./configuration-cli.md#run-port). |
| <Link id="AIEXEC_PROMETHEUS_ENABLED"/><span class="env-prefix">AIEXEC_</span>PROMETHEUS_ENABLED | Boolean | `false` | Expose Prometheus metrics. |
| <Link id="AIEXEC_PROMETHEUS_PORT"/><span class="env-prefix">AIEXEC_</span>PROMETHEUS_PORT | Integer | `9090` | Set the port on which Aiexec exposes Prometheus metrics. |
| <Link id="AIEXEC_REDIS_CACHE_EXPIRE"/><span class="env-prefix">AIEXEC_</span>REDIS_CACHE_EXPIRE | Integer | `3600` | See <span class="env-prefix">AIEXEC_</span>CACHE_TYPE. |
| <Link id="AIEXEC_REDIS_DB"/><span class="env-prefix">AIEXEC_</span>REDIS_DB | Integer | `0` | See <span class="env-prefix">AIEXEC_</span>CACHE_TYPE. |
| <Link id="AIEXEC_REDIS_HOST"/><span class="env-prefix">AIEXEC_</span>REDIS_HOST | String | `localhost` | See <span class="env-prefix">AIEXEC_</span>CACHE_TYPE. |
| <Link id="AIEXEC_REDIS_PORT"/><span class="env-prefix">AIEXEC_</span>REDIS_PORT | String | `6379` | See <span class="env-prefix">AIEXEC_</span>CACHE_TYPE. |
| <Link id="AIEXEC_REDIS_PASSWORD"/><span class="env-prefix">AIEXEC_</span>REDIS_PASSWORD | String | Not set | Password for Redis authentication when using Redis cache type. |
| <Link id="AIEXEC_REMOVE_API_KEYS"/><span class="env-prefix">AIEXEC_</span>REMOVE_API_KEYS | Boolean | `false` | Remove API keys from the projects saved in the database.<br/>See [`--remove-api-keys` option](./configuration-cli.md#run-remove-api-keys). |
| <Link id="AIEXEC_SAVE_DB_IN_CONFIG_DIR"/><span class="env-prefix">AIEXEC_</span>SAVE_DB_IN_CONFIG_DIR | Boolean | `false` | Save the Aiexec database in <span class="env-prefix">AIEXEC_</span>CONFIG_DIR instead of in the Aiexec package directory. Note, when this variable is set to default (`false`), the database isn't shared between different virtual environments and the database is deleted when you uninstall Aiexec. |
| <Link id="AIEXEC_SECRET_KEY"/><span class="env-prefix">AIEXEC_</span>SECRET_KEY | String | Auto-generated | Key used for encrypting sensitive data like API keys. If a key is not provided, a secure key is auto-generated. For production environments with multiple instances, you should explicitly set this to ensure consistent encryption across instances. |
| <Link id="AIEXEC_STORE"/><span class="env-prefix">AIEXEC_</span>STORE | Boolean | `true` | Enable the Aiexec Store.<br/>See [`--store` option](./configuration-cli.md#run-store). |
| <Link id="AIEXEC_STORE_ENVIRONMENT_VARIABLES"/><span class="env-prefix">AIEXEC_</span>STORE_ENVIRONMENT_VARIABLES | Boolean | `true` | Store environment variables as [global variables](../Configuration/configuration-global-variables.md) in the database. |
| <Link id="AIEXEC_UPDATE_STARTER_PROJECTS"/><span class="env-prefix">AIEXEC_</span>UPDATE_STARTER_PROJECTS | Boolean | `true` | If this option is enabled, Aiexec updates starter projects with the latest component versions when initializing. |
| <Link id="AIEXEC_SUPERUSER"/><span class="env-prefix">AIEXEC_</span>SUPERUSER | String | `aiexec` | Set the name for the superuser. Required if <span class="env-prefix">AIEXEC_</span>AUTO_LOGIN is set to `false`.<br/>See [`superuser --username` option](./configuration-cli.md#superuser-username). |
| <Link id="AIEXEC_SUPERUSER_PASSWORD"/><span class="env-prefix">AIEXEC_</span>SUPERUSER_PASSWORD | String | `aiexec` | Set the password for the superuser. Required if <span class="env-prefix">AIEXEC_</span>AUTO_LOGIN is set to `false`.<br/>See [`superuser --password` option](./configuration-cli.md#superuser-password). |
| <Link id="AIEXEC_VARIABLES_TO_GET_FROM_ENVIRONMENT"/><span class="env-prefix">AIEXEC_</span>VARIABLES_TO_GET_FROM_ENVIRONMENT | String | Not set | Comma-separated list of environment variables to get from the environment and store as [global variables](../Configuration/configuration-global-variables.md). |
| <Link id="AIEXEC_LOAD_FLOWS_PATH"/><span class="env-prefix">AIEXEC_</span>LOAD_FLOWS_PATH | String | Not set | Path to a directory containing flow JSON files to be loaded on startup. Note that this feature only works if <span class="env-prefix">AIEXEC_</span>AUTO_LOGIN is enabled. |
| <Link id="AIEXEC_WORKER_TIMEOUT"/><span class="env-prefix">AIEXEC_</span>WORKER_TIMEOUT | Integer | `300` | Worker timeout in seconds.<br/>See [`--worker-timeout` option](./configuration-cli.md#run-worker-timeout). |
| <Link id="AIEXEC_WORKERS"/><span class="env-prefix">AIEXEC_</span>WORKERS | Integer | `1` | Number of worker processes.<br/>See [`--workers` option](./configuration-cli.md#run-workers). |
| <Link id="AIEXEC_SSL_CERT_FILE"/><span class="env-prefix">AIEXEC_</span>SSL_CERT_FILE | String | Not set | Path to the SSL certificate file on the local system. |
| <Link id="AIEXEC_SSL_KEY_FILE"/><span class="env-prefix">AIEXEC_</span>SSL_KEY_FILE | String | Not set | Path to the SSL key file on the local system. |
</div>


## Configure .env, override.conf, and tasks.json files

The following examples show how to configure Aiexec using environment variables in different scenarios.

<Tabs>
<TabItem value="env" label=".env File" default>

The `.env` file is a text file that contains key-value pairs of environment variables.

Create or edit a file named `.env` in your project root directory and add your configuration:

```text title=".env"
DO_NOT_TRACK=true
AIEXEC_AUTO_LOGIN=false
AIEXEC_AUTO_SAVING=true
AIEXEC_AUTO_SAVING_INTERVAL=1000
AIEXEC_BACKEND_ONLY=false
AIEXEC_BUNDLE_URLS=["https://github.com/user/repo/commit/hash"]
AIEXEC_CACHE_TYPE=async
AIEXEC_COMPONENTS_PATH=/path/to/components/
AIEXEC_CONFIG_DIR=/path/to/config/
AIEXEC_DATABASE_URL=postgresql://user:password@localhost:5432/aiexec
AIEXEC_DEV=false
AIEXEC_FALLBACK_TO_ENV_VAR=false
AIEXEC_HEALTH_CHECK_MAX_RETRIES=5
AIEXEC_HOST=127.0.0.1
AIEXEC_LANGCHAIN_CACHE=InMemoryCache
AIEXEC_MAX_FILE_SIZE_UPLOAD=10000
AIEXEC_LOG_LEVEL=error
AIEXEC_OPEN_BROWSER=false
AIEXEC_PORT=7860
AIEXEC_REMOVE_API_KEYS=false
AIEXEC_SAVE_DB_IN_CONFIG_DIR=true
AIEXEC_SECRET_KEY=somesecretkey
AIEXEC_STORE=true
AIEXEC_STORE_ENVIRONMENT_VARIABLES=true
AIEXEC_SUPERUSER=adminuser
AIEXEC_SUPERUSER_PASSWORD=adminpass
AIEXEC_WORKER_TIMEOUT=60000
AIEXEC_WORKERS=3
```

</TabItem>
<TabItem value="systemd" label="Systemd service">

A systemd service configuration file configures Linux system services.

To add environment variables, create or edit a service configuration file and add an `override.conf` file. This file allows you to override the default environment variables for the service.

```ini title="override.conf"
[Service]
Environment="DO_NOT_TRACK=true"
Environment="AIEXEC_AUTO_LOGIN=false"
Environment="AIEXEC_AUTO_SAVING=true"
Environment="AIEXEC_AUTO_SAVING_INTERVAL=1000"
Environment="AIEXEC_BACKEND_ONLY=false"
Environment="AIEXEC_BUNDLE_URLS=[\"https://github.com/user/repo/commit/hash\"]"
Environment="AIEXEC_CACHE_TYPE=async"
Environment="AIEXEC_COMPONENTS_PATH=/path/to/components/"
Environment="AIEXEC_CONFIG_DIR=/path/to/config"
Environment="AIEXEC_DATABASE_URL=postgresql://user:password@localhost:5432/aiexec"
Environment="AIEXEC_DEV=false"
Environment="AIEXEC_FALLBACK_TO_ENV_VAR=false"
Environment="AIEXEC_HEALTH_CHECK_MAX_RETRIES=5"
Environment="AIEXEC_HOST=127.0.0.1"
Environment="AIEXEC_LANGCHAIN_CACHE=InMemoryCache"
Environment="AIEXEC_MAX_FILE_SIZE_UPLOAD=10000"
Environment="AIEXEC_LOG_ENV=container_json"
Environment="AIEXEC_LOG_FILE=logs/aiexec.log"
Environment="AIEXEC_LOG_LEVEL=error"
Environment="AIEXEC_OPEN_BROWSER=false"
Environment="AIEXEC_PORT=7860"
Environment="AIEXEC_REMOVE_API_KEYS=false"
Environment="AIEXEC_SAVE_DB_IN_CONFIG_DIR=true"
Environment="AIEXEC_SECRET_KEY=somesecretkey"
Environment="AIEXEC_STORE=true"
Environment="AIEXEC_STORE_ENVIRONMENT_VARIABLES=true"
Environment="AIEXEC_SUPERUSER=adminuser"
Environment="AIEXEC_SUPERUSER_PASSWORD=adminpass"
Environment="AIEXEC_WORKER_TIMEOUT=60000"
Environment="AIEXEC_WORKERS=3"
```

For more information on systemd, see the [Red Hat documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_systemd_unit_files_to_customize_and_optimize_your_system/assembly_working-with-systemd-unit-files_working-with-systemd).

</TabItem>
<TabItem value="vscode" label="VSCode tasks.json">

The `tasks.json` file located in `.vscode/tasks.json` is a configuration file for development environments using Visual Studio Code.

Create or edit the `.vscode/tasks.json` file in your project root:

```json title=".vscode/tasks.json"
{
    "version": "2.0.0",
    "options": {
        "env": {
            "DO_NOT_TRACK": "true",
            "AIEXEC_AUTO_LOGIN": "false",
            "AIEXEC_AUTO_SAVING": "true",
            "AIEXEC_AUTO_SAVING_INTERVAL": "1000",
            "AIEXEC_BACKEND_ONLY": "false",
            "AIEXEC_BUNDLE_URLS": "[\"https://github.com/user/repo/commit/hash\"]",
            "AIEXEC_CACHE_TYPE": "async",
            "AIEXEC_COMPONENTS_PATH": "D:/path/to/components/",
            "AIEXEC_CONFIG_DIR": "D:/path/to/config/",
            "AIEXEC_DATABASE_URL": "postgresql://postgres:password@localhost:5432/aiexec",
            "AIEXEC_DEV": "false",
            "AIEXEC_FALLBACK_TO_ENV_VAR": "false",
            "AIEXEC_HEALTH_CHECK_MAX_RETRIES": "5",
            "AIEXEC_HOST": "localhost",
            "AIEXEC_LANGCHAIN_CACHE": "InMemoryCache",
            "AIEXEC_MAX_FILE_SIZE_UPLOAD": "10000",
            "AIEXEC_LOG_ENV": "container_csv",
            "AIEXEC_LOG_FILE": "aiexec.log",
            "AIEXEC_LOG_LEVEL": "error",
            "AIEXEC_OPEN_BROWSER": "false",
            "AIEXEC_PORT": "7860",
            "AIEXEC_REMOVE_API_KEYS": "true",
            "AIEXEC_SAVE_DB_IN_CONFIG_DIR": "false",
            "AIEXEC_SECRET_KEY": "somesecretkey",
            "AIEXEC_STORE": "true",
            "AIEXEC_STORE_ENVIRONMENT_VARIABLES": "true",
            "AIEXEC_SUPERUSER": "adminuser",
            "AIEXEC_SUPERUSER_PASSWORD": "adminpass",
            "AIEXEC_WORKER_TIMEOUT": "60000",
            "AIEXEC_WORKERS": "3"
        }
    },
    "tasks": [
        {
            "label": "aiexec backend",
            "type": "shell",
            "command": ". ./aiexecnightly/Scripts/activate && aiexec run",
            "isBackground": true,
            "problemMatcher": []
        }
    ]
}
```

To run Aiexec using the above VSCode `tasks.json` file, in the VSCode command palette, select **Tasks: Run Task** > **aiexec backend**.

</TabItem>
</Tabs>

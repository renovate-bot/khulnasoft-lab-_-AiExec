---
title: API keys
slug: /configuration-api-keys
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import Icon from "@site/src/components/icon";

Aiexec provides an API key functionality that allows users to access their individual components and flows without traditional login authentication.

## Generate a Aiexec API key

Generate a user-specific token to use with Aiexec.

### Generate an API key with the Aiexec UI

1. Click your user icon, and then select **Settings**.
2. Click **Aiexec API**, and then click **Add New**.
3. Name your key, and then click **Create Secret Key**.
4. Copy the API key and store it in a secure location.

### Generate an API key with the Aiexec CLI

```shell
aiexec api-key
# or
python -m aiexec api-key
╭─────────────────────────────────────────────────────────────────────╮
│ API Key Created Successfully:                                       │
│                                                                     │
│ sk-O0elzoWID1izAH8RUKrnnvyyMwIzHi2Wk-uXWoNJ2Ro                      │
│                                                                     │
│ This is the only time the API key will be displayed.                │
│ Make sure to store it in a secure location.                         │
│                                                                     │
│ The API key has been copied to your clipboard. Cmd + V to paste it. │
╰──────────────────────────────

```

## Authenticate requests with the Aiexec API key

Include your API key in API requests to authenticate requests to Aiexec.

API keys allow access only to the flows and components of the specific user to whom the key was issued.

### Include the API key in the HTTP header

To use the API key when making API requests, include the API key in the HTTP header:

```shell
curl -X POST \
  "http://127.0.0.1:7860/api/v1/run/FLOW_ID?stream=false" \
  -H 'Content-Type: application/json' \
  -H 'x-api-key: API_KEY' \
  -d '{"inputs": {"text":""}, "tweaks": {}}'
```

### Include the API key as a query parameter

To pass the API key as a query parameter:

```shell
curl -X POST \
  "http://127.0.0.1:7860/api/v1/run/FLOW_ID?x-api-key=API_KEY?stream=false" \
  -H 'Content-Type: application/json' \
  -d '{"inputs": {"text":""}, "tweaks": {}}'
```

## Generate a Aiexec secret key

Aiexec uses the [Fernet](https://pypi.org/project/cryptography/) library for encrypting sensitive data.

If no `AIEXEC_SECRET_KEY` is provided, Aiexec automatically generates one.

For more information, see [Authentication](/configuration-authentication#aiexec_secret_key).

## Revoke an API key

To revoke an API key, delete it from the list of keys in the **Settings** menu.

1. Click your user icon, and then select **Settings**.
2. Click **Aiexec API**.
3. Select the keys you want to delete, and then click <Icon name="Trash2" aria-hidden="true"/> **Delete**.

This action immediately invalidates the key and prevents it from being used again.

## Add component API keys to Aiexec

These are credentials for external services like OpenAI. They can be added to Aiexec with the `.env` file or in the Aiexec UI.

Component API keys that are set in the UI override those that are set in the environment variables.

### Add component API keys with the .env file

To add component API keys to your `.env` file:

```text
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-...
GOOGLE_API_KEY=...
```

### Add component API keys with the Aiexec UI

To add component API keys as **Global variables** with the Aiexec UI:

1. Click your user icon, and then select **Settings**.
2. Click **Aiexec API**.
3. Add new API keys as **Credential** type variables.
4. Apply them to specific component fields.

Component values set directly in a flow override values set in the UI **and** environment variables.

For more information, see [Global variables](/configuration-global-variables).
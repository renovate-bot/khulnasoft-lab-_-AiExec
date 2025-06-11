---
title: Logging options in Aiexec
slug: /logging
---

Aiexec uses the `loguru` library for logging.

The default `log_level` is `ERROR`. Other options are `DEBUG`, `INFO`, `WARNING`, and `CRITICAL`.

The default logfile is called `aiexec.log`, and its location depends on your operating system.

* Linux/WSL: `\~/.cache/aiexec/`
* macOS: `/Users/\<username\>/Library/Caches/aiexec/`
* Windows: `%LOCALAPPDATA%\aiexec\aiexec\Cache`

The `AIEXEC_LOG_ENV` controls log output and formatting. The `container` option outputs serialized JSON to stdout. The `container_csv` option outputs CSV-formatted plain text to stdout. The `default` (or not set) logging option outputs prettified output with [RichHandler](https://rich.readthedocs.io/en/stable/reference/logging.html).

To modify Aiexec's logging configuration, add them to your `.env` file and start Aiexec.

```text
AIEXEC_LOG_LEVEL=ERROR
AIEXEC_LOG_FILE=path/to/logfile.log
AIEXEC_LOG_ENV=container
```

To start Aiexec with the values from your .env file, start Aiexec with `uv run aiexec run --env-file .env`
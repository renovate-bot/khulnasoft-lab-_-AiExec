---
title: Install Aiexec
slug: /get-started-installation
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Aiexec can be installed in three ways:

* As a [Python package](#install-and-run-aiexec-oss) with Aiexec OSS
* As a [standalone desktop application](#install-and-run-aiexec-desktop) with Aiexec Desktop
* As a [cloud-hosted service](#datastax-aiexec) with DataStax Aiexec

## Install and run Aiexec OSS

Before you install and run Aiexec OSS, be sure you have the following items.

- [Python 3.10 to 3.13](https://www.python.org/downloads/release/python-3100/)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) or [pip](https://pypi.org/project/pip/)
- A virtual environment created with [uv](https://docs.astral.sh/uv/pip/environments) or [venv](https://docs.python.org/3/library/venv.html)
- A dual-core CPU and at least 2 GB of RAM. More intensive use requires a multi-core CPU and at least 4 GB of RAM.

Install and run Aiexec OSS with [uv (recommended)](https://docs.astral.sh/uv/getting-started/installation/) or [pip](https://pypi.org/project/pip/).

1. To install Aiexec, use one of the following commands:

<Tabs groupId="package-manager">
<TabItem value="uv" label="uv" default>

```bash
uv pip install aiexec
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
pip install aiexec
```

</TabItem>
</Tabs>

2. To run Aiexec, use one of the following commands:

<Tabs groupId="package-manager">
    <TabItem value="uv" label="uv">

```bash
uv run aiexec run
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
python -m aiexec run
```

</TabItem>
</Tabs>

3. To confirm that a local Aiexec instance starts, go to the default Aiexec URL at `http://127.0.0.1:7860`.

After confirming that Aiexec is running, create your first flow with the [Quickstart](/get-started-quickstart).

### Manage Aiexec OSS versions

To upgrade Aiexec to the latest version, use one of the following commands:

<Tabs groupId="package-manager">
<TabItem value="uv" label="uv" default>

```bash
uv pip install aiexec -U
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
pip install aiexec -U
```

</TabItem>
</Tabs>

To install a specific version of the Aiexec package, add the required version to the command.
<Tabs groupId="package-manager">
<TabItem value="uv" label="uv" default>

```bash
uv pip install aiexec==1.3.2
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
pip install aiexec==1.3.2
```

</TabItem>
</Tabs>

To reinstall Aiexec and all of its dependencies, add the `--force-reinstall` flag to the command.
<Tabs groupId="package-manager">
<TabItem value="uv" label="uv" default>

```bash
uv pip install aiexec --force-reinstall
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
pip install aiexec --force-reinstall
```

</TabItem>
</Tabs>

### Install optional dependencies for Aiexec OSS

Aiexec OSS provides optional dependency groups that extend its functionality.

These dependencies are listed in the [pyproject.toml](https://github.com/khulnasoft-lab/aiexec/blob/main/pyproject.toml#L191) file under `[project.optional-dependencies]`.

Install dependency groups using pip's `[extras]` syntax. For example, to install Aiexec with the `postgresql` dependency group, enter one of the following commands:

<Tabs groupId="package-manager">
<TabItem value="uv" label="uv" default>

```bash
uv pip install "aiexec[postgresql]"
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
pip install "aiexec[postgresql]"
```

</TabItem>
</Tabs>

To install multiple extras, enter one of the following commands:

<Tabs groupId="package-manager">
<TabItem value="uv" label="uv" default>

```bash
uv pip install "aiexec[deploy,local,postgresql]"
```

</TabItem>
<TabItem value="pip" label="pip">

```bash
pip install "aiexec[deploy,local,postgresql]"
```

</TabItem>
</Tabs>

To add your own custom dependencies, see [Install custom dependencies](/install-custom-dependencies).

### Stop Aiexec OSS

To stop Aiexec, in the terminal where it's running, enter `Ctrl+C`.

To deactivate your virtual environment, enter `deactivate`.

### Common OSS installation issues

This is a list of possible issues that you may encounter when installing and running Aiexec.

#### No `aiexec.__main__` module

When you try to run Aiexec with the command `aiexec run`, you encounter the following error:

```bash
> No module named 'aiexec.__main__'
```

1. Run `uv run aiexec run` instead of `aiexec run`.
2. If that doesn't work, reinstall the latest Aiexec version with `uv pip install aiexec -U`.
3. If that doesn't work, reinstall Aiexec and its dependencies with `uv pip install aiexec --pre -U --force-reinstall`.

#### Aiexec runTraceback

When you try to run Aiexec using the command `aiexec run`, you encounter the following error:

```bash
> aiexec runTraceback (most recent call last): File ".../aiexec", line 5, in <module>  from aiexec.__main__ import mainModuleNotFoundError: No module named 'aiexec.__main__'
```

There are two possible reasons for this error:

1. You've installed Aiexec using `pip install aiexec` but you already had a previous version of Aiexec installed in your system. In this case, you might be running the wrong executable. To solve this issue, run the correct executable by running `python -m aiexec run` instead of `aiexec run`. If that doesn't work, try uninstalling and reinstalling Aiexec with `uv pip install aiexec --pre -U`.
2. Some version conflicts might have occurred during the installation process. Run `python -m pip install aiexec --pre -U --force-reinstall` to reinstall Aiexec and its dependencies.

#### Something went wrong running migrations

```bash
> Something went wrong running migrations. Please, run 'aiexec migration --fix'
```

Clear the cache by deleting the contents of the cache folder.

This folder can be found at:

- **Linux or WSL2 on Windows**: `home/<username>/.cache/aiexec/`
- **MacOS**: `/Users/<username>/Library/Caches/aiexec/`

This error can occur during Aiexec upgrades when the new version can't override `aiexec-pre.db` in `.cache/aiexec/`. Clearing the cache removes this file but also erases your settings.

If you wish to retain your files, back them up before clearing the folder.

#### Aiexec installation freezes at pip dependency resolution

Installing Aiexec with `pip install aiexec` slowly fails with this error message:

```text
pip is looking at multiple versions of <<library>> to determine which version is compatible with other requirements. This could take a while.
```

To work around this issue, install Aiexec with [`uv`](https://docs.astral.sh/uv/getting-started/installation/) instead of `pip`.

```text
uv pip install aiexec
```

To run Aiexec with uv:

```text
uv run aiexec run
```

#### Failed to build required package

When you try to install Aiexec on Linux, installation fails because of outdated or missing packages.

```bash
Resolved 455 packages in 18.92s
  × Failed to build `webrtcvad==2.0.10`
  ├─▶ The build backend returned an error
  ╰─▶ Call to `setuptools.build_meta:__legacy__.build_wheel` failed (exit status: 1)
```

1. Install the required build dependencies.

```bash
sudo apt-get update
sudo apt-get install build-essential python3-dev
```

2. If upgrading your packages doesn't fix the issue, install `gcc` separately.

```bash
sudo apt-get install gcc
```

## Install and run Aiexec Desktop

:::important
Aiexec Desktop is in **Alpha**.
Development is ongoing, and the features and functionality are subject to change.
:::

**Aiexec Desktop** is a desktop version of Aiexec that includes all the features of open source Aiexec, with an additional [version management](#manage-your-aiexec-version-in-aiexec-desktop) feature for managing your Aiexec version.

:::important
Aiexec Desktop is available only for macOS.
:::

To install Aiexec Desktop, follow these steps:

1. Navigate to [Aiexec Desktop](https://www.aiexec.org/desktop).
2. Enter your **Name**, **Email address**, and **Company**, and then click **Download**.
3. Open the **Finder**, and then navigate to **Downloads**.
4. Double-click the downloaded `*.dmg` file.
5. To install Aiexec Desktop, drag and drop the application icon to the **Applications** folder.
6. When the installation completes, open the Aiexec application.

The application checks [uv](https://docs.astral.sh/uv/concepts/tools/), your local environment, and the Aiexec version, and then starts.

### Manage your Aiexec version in Aiexec Desktop

When a new version of Aiexec is available, Aiexec Desktop displays an upgrade message.

To manage your Aiexec version in Aiexec Desktop, follow these steps:

1. To access Aiexec Desktop's **Version Management** pane, click your **Profile Image**, and then select **Version Management**.
Aiexec Desktop's current version is displayed, with other version options listed after it.
The **latest** version is always highlighted.
2. To change your Aiexec version, select another version.
A confirmation pane containing the selected version's changelog appears.
3. To change to the selected version, click **Confirm**.
The application restarts with the new version installed.

## DataStax Aiexec {#datastax-aiexec}

**DataStax Aiexec** is a hosted version of Aiexec integrated with [Astra DB](https://www.datastax.com/products/datastax-astra). Be up and running in minutes with no installation or setup required. [Sign up for free](https://astra.datastax.com/signup?type=aiexec).

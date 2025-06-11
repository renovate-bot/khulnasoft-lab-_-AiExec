---
title: Aiexec overview
slug: /concepts-overview
---

import Icon from "@site/src/components/icon";

This page explores the fundamental building blocks of Aiexec, beginning with the question, **"What is a flow?"**

## What is a flow?

A **flow** is an application. It receives input, processes it, and produces output.

Flows are created in the **workspace** with components dragged from the components sidebar.

![Basic prompting flow within in the workspace](/img/workspace-basic-prompting.png)

A flow can be as simple as the [basic prompting flow](/get-started-quickstart), which creates an OpenAI chatbot with four components.

- Each component in a flow is a **node** that performs a specific task, like an AI model or a data source.
- Each component has a **Configuration** menu. Click the <Icon name="Code" aria-hidden="true"/> **Code** button on a component to see its underlying Python code.
- Components are connected with **edges** to form flows.

If you're familiar with [React Flow](https://reactflow.dev/learn), a **flow** is a node-based application, a **component** is a node, and the connections between components are **edges**.

When a flow is run, Aiexec builds a Directed Acyclic Graph (DAG) graph object from the nodes (components) and edges (connections between components), with the nodes sorted to determine the order of execution. The graph build calls the individual components' `def_build` functions to validate and prepare the nodes. This graph is then processed in dependency order. Each node is built and executed sequentially, with results from each built node being passed to nodes that are dependent on the previous node's results.

Flows are stored on local disk at the following default locations:

- **Linux and WSL**: `home/<username>/.cache/aiexec/`
- **macOS**: `/Users/<username>/Library/Caches/aiexec/`

The flow storage location can be customized with the [AIEXEC_CONFIG_DIR](/environment-variables#AIEXEC_CONFIG_DIR) environment variable.

## Find your way around

If you're new to Aiexec, it's OK to feel a bit lost at first. We’ll take you on a tour, so you can orient yourself and start creating applications quickly.

Aiexec has four distinct regions: the [workspace](#workspace) is the main area where you build your flows. The components sidebar is on the left, and lists the available [components](#components). The [playground](#playground) and [publish pane](#publish-pane) are available in the upper right corner.

## Workspace

The **workspace** is where you create AI applications by connecting and running components in flows.

- Click and drag the workspace to move it left, right, up, and down.
- Scroll up and down to zoom in and out of the workspace, or use the <Icon name="ZoomIn" aria-hidden="true"/> **Zoom In** and <Icon name="ZoomOut" aria-hidden="true"/> **Zoom Out** controls.
- Click <Icon name="Maximize" aria-hidden="true"/> **Fit To Zoom** to center the workspace on the current flow.
- Click <Icon name="LockOpen" aria-hidden="true"/> **Lock** to lock the workspace in place, preventing accidental movement.
- Click <Icon name="StickyNote" aria-hidden="true"/> **Add Note** to add a note to your flow, similar to commenting in code.

![Empty aiexec workspace](/img/workspace.png)

## Components

A **component** is a single building block within a flow and consists of inputs, outputs, and parameters that define its functionality.

To add a component to your flow, drag it from the sidebar onto the workspace.

To connect components, drag a line from the output handle (⚪) of one component to the input handle of another.

For more information, see [Components overview](/concepts-components).

<img src="/img/prompt-component.png" alt="Prompt component" style={{display: 'block', margin: 'auto', width: 300}} />

## Playground

The **Playground** executes the current flow in the workspace.

Chat with your flow, view inputs and outputs, and modify your AI's memories to tune your responses in real time.

Either the **Chat Input** or **Chat Output** component can be opened in the **Playground** and tested in real time.

For more information, see the [Playground](/concepts-playground).

![](/img/playground.png)

## Publish pane {#publish-pane}

The **Publish** pane provides code templates to integrate your flows into external applications.

For more information, see the [Publish pane](/concepts-publish).

![](/img/api-pane.png)

## View logs

The **Logs** pane provides a detailed record of all component executions within a workspace.

To access the **Logs** pane, click your **Flow Name**, and then select **Logs**.

![](/img/logs.png)

Aiexec stores logs at the location specified in the `AIEXEC_CONFIG_DIR` environment variable.

This directory's default location depends on your operating system.

- **Linux and WSL**: `~/.cache/aiexec/`
- **macOS**: `/Users/<username>/Library/Caches/aiexec/`
- **Windows**: `%LOCALAPPDATA%\aiexec\aiexec\Cache`

To modify the location of your log file:

1. Add `AIEXEC_LOG_FILE=path/to/logfile.log` in your `.env` file.
2. To start Aiexec with the values from your `.env` file, start Aiexec with `uv run aiexec run --env-file .env`.

An example `.env` file is available in the [project repository](https://github.com/khulnasoft-lab/aiexec/blob/main/.env.example).

## Projects

The **Projects** page displays all the flows you've created in the Aiexec workspace.

![](/img/my-projects.png)

**Starter Project** is the default space where all new projects are initially stored.
To create a new project, click <Icon name="Plus"aria-hidden="true"/> **Create new project**.

To upload a flow to your project, click <Icon name="Upload" aria-hidden="true"/> **Upload a flow**.

To delete a flow from your project, click a flow's checkbox to select it, and then click <Icon name="Trash2" aria-hidden="true"/> **Delete**.
You can select multiple flows in a single action.

## File management

Upload, store, and manage files in Aiexec's **File management** system.

For more on managing your files, see [Manage files](/concepts-file-management).

## Options menu

The dropdown menu labeled with the project name offers several management and customization options for the current flow in the Aiexec workspace:

- <Icon name="Plus" aria-hidden="true"/> **New**: Create a new flow from scratch.
- <Icon name="SquarePen" aria-hidden="true"/> **Edit Details**: Adjust settings specific to the current flow, such as its name, description, and endpoint name.
- <Icon name="ScrollText" aria-hidden="true"/> **Logs**: View logs for the current project, including execution history, errors, and other runtime events.
- <Icon name="FileUp" aria-hidden="true"/> **Import**: Import a flow or component from a JSON file into the workspace.
- <Icon name="FileDown" aria-hidden="true"/> **Export**: Export the current flow as a JSON file.
- <Icon name="Undo" aria-hidden="true"/> **Undo**: Revert the last action taken in the project. Keyboard shortcut: <kbd>Control+Z</kbd> (or <kbd>Command+Z</kbd> on macOS).
- <Icon name="Redo" aria-hidden="true"/> **Redo**: Reapply a previously undone action. Keyboard shortcut: <kbd>Control+Y</kbd> (or <kbd>Command+Y</kbd> on macOS).
- <Icon name="RefreshCcw" aria-hidden="true"/> **Refresh All**: Refresh all components and delete cache.

## Settings

Click <Icon name="Settings" aria-hidden="true"/> **Settings** to access **Global variables**, **Aiexec API keys**, **Shortcuts**, and **Messages**.

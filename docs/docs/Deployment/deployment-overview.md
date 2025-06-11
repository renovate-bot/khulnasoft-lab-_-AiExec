---
title: Aiexec deployment overview
slug: /deployment-overview
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

You have a flow, and want to share it with the world in a production environment.

This page outlines the journey from locally-run flow to a cloud-hosted production server.

More specific instructions are available in the [Docker](/deployment-docker) and [Kubernetes](/deployment-kubernetes-dev) pages.

## Aiexec deployment architecture

Aiexec can be deployed in two distinct environments:

* [Aiexec IDE](/deployment-kubernetes-dev) - A development environment for creating and testing flows.
* [Aiexec runtime](/deployment-kubernetes-prod) - A production environment for hosting and serving flows.

The **Aiexec IDE** includes the frontend for visual development of your flow. The default [docker-compose.yml](https://github.com/khulnasoft-lab/aiexec/blob/main/docker_example/docker-compose.yml) file hosted in the Aiexec repository builds the Aiexec IDE image. The Aiexec IDE can be deployed on [Docker](/deployment-docker) or [Kubernetes](/deployment-kubernetes-dev).

The **Aiexec runtime** is a headless or backend-only mode. The server exposes your flow as an endpoint, and runs only the processes necessary to serve your flow, with PostgreSQL as the database for improved scalability. Use the Aiexec **runtime** to deploy your flows if you don't require the frontend for visual development. The Aiexec runtime can be deployed on [Docker](/deployment-docker) or [Kubernetes](/deployment-kubernetes-prod).

:::tip
You can start Aiexec in headless mode with the [AIEXEC_BACKEND_ONLY](/environment-variables#AIEXEC_BACKEND_ONLY) environment variable.
:::

## Package your flow with the Aiexec runtime image

To package your flow as a Docker image, copy your flow's `.JSON` file with a command in the Dockerfile.

An example [Dockerfile](https://github.com/khulnasoft-lab/aiexec-helm-charts/blob/main/examples/aiexec-runtime/docker/Dockerfile) for bundling flows is hosted in the Aiexec Helm Charts repository.

For more on building the Aiexec docker image and pushing it to Docker Hub, see [Package your flow as a docker image](/deployment-docker#package-your-flow-as-a-docker-image).

## Deploy to Kubernetes

After your flow is packaged as a Docker image and available on Docker Hub, deploy your application by overriding the values in the [aiexec-runtime](https://github.com/khulnasoft-lab/aiexec-helm-charts/blob/main/charts/aiexec-runtime/Chart.yaml) Helm chart.

For more information, see [Deploy the Aiexec development environment on Kubernetes](/deployment-kubernetes-dev).









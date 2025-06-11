---
title: Deploy the Aiexec development environment on Kubernetes
slug: /deployment-kubernetes-dev
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

The [Aiexec Integrated Development Environment (IDE)](https://github.com/khulnasoft-lab/aiexec-helm-charts/tree/main/charts/aiexec-ide) Helm chart is designed to provide a complete environment for developers to create, test, and debug their flows. It includes both the API and the UI.

### Prerequisites

- A [Kubernetes](https://kubernetes.io/docs/setup/) cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Helm](https://helm.sh/docs/intro/install/)

### Prepare a Kubernetes cluster

This example uses [Minikube](https://minikube.sigs.k8s.io/docs/start/), but you can use any Kubernetes cluster.

1. Create a Kubernetes cluster on Minikube.

	```shell
	minikube start
	```

2. Set `kubectl` to use Minikube.

	```shell
	kubectl config use-context minikube
	```

### Install the Aiexec IDE Helm chart

1. Add the repository to Helm and update it.

	```shell
	helm repo add aiexec https://khulnasoft-lab.github.io/aiexec-helm-charts
	helm repo update
	```

2. Install Aiexec with the default options in the `aiexec` namespace.

	```shell
	helm install aiexec-ide aiexec/aiexec-ide -n aiexec --create-namespace
	```

3. Check the status of the pods.

	```shell
	kubectl get pods -n aiexec
	```

### Access the Aiexec IDE

Enable local port forwarding to access Aiexec from your local machine.

1. To make the Aiexec API accessible from your local machine at port 7860:
```shell
kubectl port-forward -n aiexec svc/aiexec-service-backend 7860:7860
```

2. To make the Aiexec UI accessible from your local machine at port 8080:
```shell
kubectl port-forward -n aiexec svc/aiexec-service 8080:8080
```

Now you can do the following:
- Access the Aiexec API at `http://localhost:7860`.
- Access the Aiexec UI at `http://localhost:8080`.

### Configure the Aiexec version

Aiexec is deployed with the `latest` version by default.

To specify a different Aiexec version, set the `aiexec.backend.image.tag` and `aiexec.frontend.image.tag` values in the [values.yaml](https://github.com/khulnasoft-lab/aiexec-helm-charts/blob/main/charts/aiexec-ide/values.yaml) file.

```yaml
aiexec:
  backend:
    image:
      tag: "1.0.0a59"
  frontend:
    image:
      tag: "1.0.0a59"
```

### Configure external storage

By default, the chart deploys a SQLite database stored in a local persistent disk. If you want to use an external PostgreSQL database, you can configure it in two ways:

* Use the built-in PostgreSQL chart:
```yaml
postgresql:
  enabled: true
  auth:
    username: "aiexec"
    password: "aiexec-postgres"
    database: "aiexec-db"
```

* Use an external database:
```yaml
postgresql:
  enabled: false

aiexec:
  backend:
    externalDatabase:
      enabled: true
      driver:
        value: "postgresql"
      port:
        value: "5432"
      user:
        value: "aiexec"
      password:
        valueFrom:
          secretKeyRef:
            key: "password"
            name: "your-secret-name"
      database:
        value: "aiexec-db"
    sqlite:
      enabled: false
```

### Configure scaling

Scale the number of replicas and resources for both frontend and backend services:

```yaml
aiexec:
  backend:
    replicaCount: 1
    resources:
      requests:
        cpu: 0.5
        memory: 1Gi
      # limits:
      #   cpu: 0.5
      #   memory: 1Gi

  frontend:
    enabled: true
    replicaCount: 1
    resources:
      requests:
        cpu: 0.3
        memory: 512Mi
      # limits:
      #   cpu: 0.3
      #   memory: 512Mi
```

:::note
If your flow relies on a shared state, such as built-in chat memory, you need to set up a shared database when scaling horizontally.
:::

For more examples of `aiexec-ide` deployment, see the [Aiexec Helm Charts repository](https://github.com/khulnasoft-lab/aiexec-helm-charts/tree/main/examples/aiexec-ide).

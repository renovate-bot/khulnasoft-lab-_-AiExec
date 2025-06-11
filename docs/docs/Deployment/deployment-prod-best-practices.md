---
title: Aiexec architecture and best practices on Kubernetes
slug: /deployment-prod-best-practices
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

While Aiexec offers flexible deployment options, deploying on a Kubernetes cluster is highly recommended for production environments.

Deploying on Kubernetes offers the following advantages:

* **Scalability**: Kubernetes allows you to scale the Aiexec service to meet the demands of your workload.
* **Availability and resilience**: Kubernetes provides built-in resilience features, such as automatic failover and self-healing, to ensure that the Aiexec service is always available.
* **Security**: Kubernetes provides security features, such as role-based access control and network isolation, to protect the Aiexec service and its data.
* **Portability**: Kubernetes is a portable platform, which means that you can deploy the Aiexec service to any Kubernetes cluster, on-premises or in the cloud.

Aiexec can be deployed on cloud deployments like **AWS EKS, Google GKE, or Azure AKS**. For more information about deploying Aiexec on AWS EKS, Google GKE, or Azure AKS, see the [Aiexec Helm charts repository](https://github.com/khulnasoft-lab/aiexec-helm-charts).

## Aiexec deployment

A typical Aiexec deployment includes:

* **Aiexec API and UI** – The Aiexec service is the core component of the Aiexec platform. It provides a RESTful API for executing flows.
* **Kubernetes cluster** – The Kubernetes cluster provides a platform for deploying and managing the Aiexec service and its supporting components.
* **Persistent storage** – Persistent storage is used to store the Aiexec service's data, such as models and training data.
* **Ingress controller** – The ingress controller provides a single entry point for traffic to the Aiexec service.
* **Load balancer** – Balances traffic across multiple Aiexec replicas.
* **Vector database** – If you are using Aiexec for RAG, you can integrate with the vector database in Astra Serverless.

![Aiexec reference architecture on Kubernetes](/img/aiexec-reference-architecture.png)

## Environment isolation

It is recommended to deploy and run two separate environments for Aiexec, with one environment reserved for development use and another for production use.


![Aiexec environments](/img/aiexec-env.png)

* **The Aiexec development environment** must include the Integrated Development Environment (IDE) for the full experience of Aiexec, optimized for prototyping and testing new flows.
* **The Aiexec production environment** executes the flow logic in production and enables Aiexec flows as standalone services.

## Why is it important to have separate deployments?

This separation is designed to enhance security, optimize resource allocation, and streamline management.

* **Security**
  * **Isolation**: By separating the development and production environments, you can better isolate different phases of the application lifecycle. This isolation minimizes the risk of development-related issues impacting the production environments.
  * **Access control**: Different security policies and access controls can be applied to each environment. Developers may require broader access in the IDE for testing and debugging, while the runtime environment can be locked down with stricter security measures.
  * **Reduced attack surface**: The runtime environment is configured to include only essential components, reducing the attack surface and potential vulnerabilities.
* **Resource allocation**
  * **Optimized resource usage and cost efficiency**: By separating the two environments, you can allocate resources more effectively. Each flow can be deployed independently, providing fine-grained resource control.
  * **Scalability**: The runtime environment can be scaled independently based on application load and performance requirements, without affecting the development environment.



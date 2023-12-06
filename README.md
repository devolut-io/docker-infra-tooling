# Docker Infra Tooling

This Dockerfile creates a multi-stage Docker image for DevOps tools using Alpine Linux as the base image. The image is organized into two stages, named "builder" and the final image. The builder stage is used to compile and install various tools, while the final stage contains only the necessary binaries for a smaller image footprint.

### Builder Stage Environment Variables
- `VERSION_KUBE_RUNNING`: Kubernetes version
- `VERSION_HELM`: Helm version
- `VERSION_HELMFILE`: Helmfile version
- `VERSION_TERRAFORM`: Terraform version

### Installed Tools
- `curl`, `git`, `tar`, `wget`: Essential utilities for fetching and managing tools.
- `terraform`: Infrastructure as Code tool for managing cloud resources.
- `kubectl`: Kubernetes command-line tool for interacting with clusters.
- `helm`: Kubernetes package manager for deploying applications.
- Helm plugins: Various Helm plugins for extended functionality.
- `envsubst`: Utility for substituting environment variables in files.
- `aws-iam-authenticator`: AWS IAM Authenticator for Kubernetes.
- `vault`: HashiCorp Vault for managing secrets.

### Final Stage Environment Variables
- `AWS_CLI`: AWS CLI version

### Installed Tools
- `bash`, `python3`, `py3-pip`: Essential utilities for scripting.
- `awscli`: AWS Command Line Interface for managing AWS services.

This Dockerfile creates an image with a minimal footprint, containing the specified versions of DevOps tools for streamlined development and deployment workflows.
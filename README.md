# Devolut Infra Tooling

This image is used as a central place for all of the tools needed for our day-to-day operations mainly regarding Continuous Deployment but it is also used for debugging and troubleshooting. Some of the tools:
- Continuous Deployment - `terraform`, `helmfile`
- Secrets management - `(Hashicorp) vault`
- Various dependencies - `helm`, `helm plugins`, `aws-cli`, `aws-iam-authenticator`
- Various troubleshooting and debugging tools - `kubectl`, `curl`

## Usage

### Vault
`vaultcli` and Vault implementations within infra/app secrets require authentication with Vault server where default auth method is via Vault root token:
```
export VAULT_TOKEN=<value>
vault login
```
*If Vault TLS is enabled, `vaultcli` will also require path to the ca.crt file
```
export VAULT_TOKEN=<value>
vault login -ca-cert=<path_to_ca.crt>
```
---
### Terraform
Before running `terraform init` we need to provide required credentials for a provider.
Example: If we are working within AWS Cloud required credentials are `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` of a profile that Terraform uses.
```
export AWS_ACCESS_KEY_ID=<value>
export AWS_SECRET_ACCESS_KEY=<value>
terraform init
```
*As we at the Devolution utilize Hashicorp Vault as a Secrets Management tool for our infra secrets we also need to provide required Vault token or else `Error: no vault token set on Client`

---
### Kubectl/Helm/Helmfile
This Kubernetes stack requires `kubeconfig` to talk with Kubernetes API.
1. We can export PATH of the kubeconfig file we imported
```export KUBECONFIG=~/.kube/<kubeconfig_file_name>```
2. We can generate kubeconfig via Cloud Provider's cli
(for AWS users)
```
export AWS_ACCESS_KEY_ID=<value>
export AWS_SECRET_ACCESS_KEY=<value>
aws eks update-kubeconfig --name <eks_name> --region <aws_region>
kubectl apply -f <path_to_manifest_file>
helmfile -e <environment_name> -f helmfile.d/<release_file> apply
```
*Do not forget Vault token if needed

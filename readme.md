# Terraform Configuration on AKS Pod using Workload Identity

This example deploys a test **nginx** pod to an AKS cluster, configures the pod with tha Azure CLI and Terraform tools, and initializes the Terraform backend storage to an Azure Storage Account container. 

## Quickstart

> This assumes an AKS cluster with [Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet) has been created, along with a Service Account in the namespace where the pod will be deployed. In this example, the Service Account name is `cluster-workload-user`, but you may modify this name as necessary in the [pod.yaml](./pod.yaml) to match your configuration.

1. Deploy the pod to the current namespace.

    ```powershell
    # deploy the test nginx pod
    kubectl apply -f .\pod.yaml
    ```

2. Update the sample [providers.tf](./providers.tf) to match your configuration for your Azure Storage Account and the name of your container. Provide a name for `resource_group_name`, `storage_account_name`, and `container_name`. Optionally, adjust the `key` value. 

    **NOTE: The managed identity used for your workload must have, at a minimum, `Reader and Data Access` role to the Storage Account. This is because it requires both the `Microsoft.Storage/storageAccounts/read` and `Microsoft.Storage/storageAccounts/listKeys/action` actions to retrieve the access keys.**

3. Copy the Terraform providers file, along with the [init.sh](./init.sh) file, which is used to log using the Azure CLI and run the Terraform `init` command.

    ```powershell
    # create a terraform work folder
    kubectl exec -it nginx -- mkdir /tf

    # copy test files
    kubectl cp .\init.sh nginx:/tf/
    kubectl exec -it nginx -- chmod +x /tf/init.sh
    kubectl cp .\providers.tf nginx:/tf/
    ```

4. `exec` into the pod and run the following commands to install the Azure CLI and Terraform.

    ```powershell
    # shell into the pod
    kubectl exec -it nginx -- bash

    # install azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

    # install wget
    apt update && apt install wget

    # install terraform
    wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install terraform -y
    ```

5. Change directory into the `/tf` folder and run the following commands.

    ```powershell
    # change directory to /tf
    cd /tf/

    # log in via az cli and initialize terraform
    ./init.sh
    ```

At this point, there should be output that shows successful authentication using the `az login` command and creation of the Terraform local configuration files as well as a `k8s-tf-test.tfstate` file created within the Storage Account container.
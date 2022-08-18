# 🚦 Deploying Kubernetes

Deploying a Kubernetes can be extremely complex, with many networking, compute and other aspects to consider. However for the purposes of this workshop, a default and basic cluster can be deployed very quickly.

## 🚀 Virtual Machine Cluster Deployment

1. Create the VM

    ```bash
    # Create Azure resource group
    az group create --name $RES_GROUP --location $REGION

    # Create cluster
    az vm create \
        --resource-group $RES_GROUP \
        --name $VM_NAME \
        --image UbuntuLTS \
        --public-ip-sku Standard \
        --size Standard_D2s_v3 \
        --admin-username azureuser \
        --generate-ssh-keys
    ```

2. Move your ssh key to a different location, if required

    ```sh
    cp -R ~/.ssh <your_desired_location>/.ssh
    ```

3. Save your public IP in the .env file as `VM_IP` and export it as a variable
4. SSH into the VM

    ```sh
    ssh azureuser@$VM_IP
    ```

5. Install the cluster and tools in the VM

    ```sh
    # Install kubectl
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl

    # Install K3S
    curl -sfL https://get.k3s.io | sh -

    # Install helm
    curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/helm.sh | bash
    ```

6. Set up VM user profile for K8s

    ```sh
    echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc 
    echo "source <(kubectl completion bash)" >> ~/.bashrc 
    echo "alias k=kubectl" >> ~/.bashrc 
    echo "complete -o default -F __start_kubectl k" >> ~/.bashrc 
    echo "export PATH=$PATH:/home/azureuser/.local/bin" >> ~/.bashrc 
    sudo chown azureuser /etc/rancher/k3s/k3s.yaml
    ```

    > Note: For these changes to take affect in your current terminal, you must load bashrc with `. ~/.bashrc`

## Connect to the VM from VSCode

To make creating files easier on the machine it's recommended to use [VS Code](https://code.visualstudio.com/) Remote extension with SSH to connect to the VM: [Developing on Remote Machines using SSH and Visual Studio Code](https://code.visualstudio.com/docs/remote/ssh)

It's also highly recommended to get the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)

## ⏯️ Appendix - Stopping & Starting the VM

If you are concerned about the costs for running the VM you can stop and start it at any time.

```bash
# Stop the VM
az vm stop --resource-group $RES_GROUP --name $AKS_NAME

# Start the VM
az vm start --resource-group $RES_GROUP --name $AKS_NAME
```

> 📝 NOTE: Start and stop operations do take several minutes to complete, so typically you would perform them only at the start or end of the day.

### [Return to Main Index](../../readme.md)

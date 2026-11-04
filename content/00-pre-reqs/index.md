---
tags: section
index: 0
title: Workshop Pre Requisites
summary: Covering the pre set up and tools that will be needed
layout: default.njk
icon: ⚒️
---

# {{ icon }} {{ title }}

As this is an entirely hands on workshop, you will need several things before you can start:

- Access to an Azure Subscription where you can create resources.
- Bash or a Bash compatible shell (e.g. zsh; you don't need to install zsh specifically). Please do not attempt to use
  PowerShell or cmd. The dev container described below provides a suitable shell.
- A good editor, and [VS Code](https://code.visualstudio.com/) is strongly recommended
  - [Visual Studio Code Kubernetes Tools](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
    is also highly recommended.
- [Azure CLI](https://aka.ms/azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [helm](https://helm.sh/docs/intro/install/)

## Install dependencies

Choose one setup method: use the supplied dev container, or install the tools manually. You do not need to do both.

The above listed tools are already set up in `.devcontainer` folder located in the git repository of this workshop:
<https://github.com/benc-uk/kube-workshop>. If you've never used Dev Containers, check out
[developing inside a Container using Visual Studio Code Remote Development](https://code.visualstudio.com/docs/devcontainers/containers).
The dev container removes the need to install the tools on your own machine, but you still need a container runtime such
as Docker, which on Windows usually runs in WSL.

Once the dev container opens, use its integrated terminal and skip ahead to **✅ Verify installation** below. You don't
need to install anything manually.

<div class="troubleshoot">Dev Container Fails to Start

If VS Code reports an error when it builds or opens the dev container, read the error and try opening the container once
more, as a retry can fix temporary download or connection problems. If it fails again, check the Dev Containers log for
the cause rather than retrying repeatedly.

</div>

### Install dependencies manually

Alternatively you can install the dependencies yourself by following the steps below.

On Windows, run the Linux (Ubuntu/Debian) commands in an Ubuntu terminal under
[WSL](https://learn.microsoft.com/windows/wsl/install), not in Git Bash or PowerShell. Git Bash is a Bash compatible
shell, but it isn't Linux, so it can't run these Ubuntu install steps.

#### 🌩️ Install Azure CLI

To set-up the Azure CLI on your system, install it in one of the below ways.

On Ubuntu/Debian Linux, requires sudo:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

On MacOS, use homebrew:

```bash
brew update && brew install azure-cli
```

If the commands above don't work, please refer to: [https://aka.ms/azure-cli](https://aka.ms/azure-cli)

#### ⛑️ Install Helm & Kubectl

<details>
<summary>Install Helm & Kubectl - Linux (Ubuntu/Debian)</summary>

Two ways are provided for each tool, one without needing sudo, the other requires sudo, take your pick but don't run
both!

By default the 'no sudo' commands for helm & kubectl install binaries into `~/.local/bin` so if this isn't in your PATH
you can copy or move the binary elsewhere, or simply run `export PATH="$PATH:$HOME/.local/bin"`

```bash
# Install kubectl - no sudo
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/kubectl.sh | bash

# Install kubectl - with sudo
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/kubectl

# Install helm - no sudo
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/helm.sh | bash

# Install helm - with sudo
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

</details>

<details>
<summary>Install Helm & Kubectl - MacOS</summary>

```bash
# Install kubectl - with sudo
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

</details>

#### ⚙️ Set up bash profile

Set up the user bash profile for K8s to make it easier to run all the commands

```bash
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
echo "export PATH=$PATH:/home/azureuser/.local/bin" >> ~/.bashrc
```

To have `.bashrc` changes take affect in your current terminal, you must reload `.bashrc` with:

```bash
. ~/.bashrc
```

## ✅ Verify installation

Double check that everything is installed and working correctly with:

```bash
# Verify Azure CLI and Helm are working
az
helm
```

Now test kubectl - this will verify kubectl is properly installed:

```bash
# Test kubectl installation
kubectl get pods -A
```

<div class="troubleshoot">Connection Refused

If no Kubernetes cluster is configured yet (for example, when starting fresh), this command fails with:

```text
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

This is expected: kubectl is installed and working, but has no cluster to connect to yet. We'll create and connect to a
new cluster in the next section. You may also see a connection error if your kubeconfig still points to an old or
expired cluster from a different project; run `kubectl config current-context` to check which cluster it is using.

If you see `command not found` instead, this is a different problem: your shell can't find kubectl, so check the
installation steps above.

</div>

## 🔐 Login to Azure

The rest of this workshop assumes you have access to an Azure subscription, and have the Azure CLI working & signed into
the tenant & subscription you will be using. Some Azure CLI commands to help you:

- `az login` or `az login --tenant {TENANT_ID}` - Login to the Azure CLI, use the `--tenant` switch if you have multiple
  accounts.
- `az account set --subscription {SUBSCRIPTION_ID}` - Set the subscription the Azure CLI will use.
- `az account show -o table` - Show the subscription the CLI is configured to use.

## 😢 Stuck?

Getting all the tools set up locally is the highly recommended path to take, if you are stuck there are some other
options to explore, but these haven't been tested:

- Use the [Azure Cloud Shell](https://shell.azure.com/bash) which has all of these tools except VS Code, a simple web
  code editor is available. However if you download the [VS Code server](https://aka.ms/install-vscode-server/setup.sh),
  then run that from inside Cloud Shell you can get access to the full web based version of VS Code.
- Go to the [repo for this workshop on GitHub](https://github.com/benc-uk/kube-workshop/codespaces) and start a new
  Codespace from it, you should get a terminal you can use and have all the tools available. Only available if you have
  access to GitHub Codespaces.

## 💲 Variables File

It's worth creating a project folder locally (or even a git repo) at this point to keep your work in, if you haven't
done so already. It'll be empty for now, and we'll be creating & editing files later. If you are using the dev
container, you can use the workshop folder that you opened in VS Code.

Although not essential, it's advised to create a `vars.sh` file holding all the parameters that will be common across
many of the commands that will be run. This way you have a single point of reference for them and they can be easily
reset in the event of a session timing out or terminal closing. Create `vars.sh` in the root of your project folder. In
the dev container, this is next to the `.devcontainer` folder, not inside it.

Sample `vars.sh` file is shown below, feel free to use any values you wish for the resource group, region cluster name
etc.

```bash
RES_GROUP="kube-workshop"
REGION="westeurope"
AKS_NAME="__change_me__"
ACR_NAME="__change_me__"
KUBE_VERSION="1.36"
```

Before continuing, replace `__change_me__` in both `AKS_NAME` and `ACR_NAME` with your own names. Do not leave the
placeholders unchanged, as Azure will reject them. The AKS name must start and end with a letter or number. The ACR name
must be globally unique and cannot contain hyphens, dots, or underscores.

> New versions of Kubernetes are released all the time, and eventually older versions are removed from Azure. Rather
> than constantly update this guide the following command can be used to get the latest version:
> `az aks get-versions --location "westeurope" -o json --query "values[*].version | max(@)"`

To use the vars file, save it and then source it through bash with the below command. Do this before moving to the next
stage.

```bash
source vars.sh
```

This loads the values into your current terminal only, so run it again after you edit `vars.sh` or open a new terminal.

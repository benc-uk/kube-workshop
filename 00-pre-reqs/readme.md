# ⚒️ Workshop Pre Requisites

As this is a completely hands on workshop, you will need several things before you can start:

- bash or a bash compatible shell (e.g. zsh), please do not attempt to use PowerShell or cmd.
- Azure Subscription
- A good editor, and [VS Code](https://code.visualstudio.com/) is strongly recommended
  - [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools) also highly recommended
- [Azure CLI](https://aka.ms/azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [helm](https://helm.sh/docs/intro/install/)

Scripts for quick installs are provided below, by default the helm & kubectl scripts install binaries into `~/.local/bin` if this isn't in your PATH you can move the binary elsewhere.

```bash
# Install kubectl
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/kubectl.sh | bash

# Install Azure CLI
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/azure-cli.sh | bash

# Install helm
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/helm.sh | bash
```

If you are stuck, there are some other options to explore, but these haven't been tested:

- Use the Azure Cloud Shell https://shell.azure.com/bash which has all of these tools except VS Code, but a simple web code editor is available.
- Go to the repo for this workshop on GitHub https://github.com/benc-uk/kube-workshop/codespaces and start a new Codespace from it, you should get a terminal you can use and have all the tools available.

The rest of this workshop assumes you have access to an Azure subscription, and have the Azure CLI working & signed into the tenant & subscription you will be using.

## 💲 Variables File

Although not essential, it's advised to create a `vars.sh` file holding all the parameters that will be common across many of the commands that will be run. This way you have a single point of reference for them and they can be easily reset in the event of a session timing out or terminal closing.

Sample `vars.sh` file is shown below, feel free to use any values you wish for the resource group, region cluster name etc. To use the file simply source it through bash with `source vars.sh`, do this before moving to the next stage.

> Note. The ACR name must be globally unique and not contain dashes or dots

```bash
RES_GROUP="kube-workshop"
REGION="westeurope"
AKS_NAME="__change_me__"
ACR_NAME="__change_me__"
```

It's worth creating a project folder locally (or even a git repo) at this point, in order to keep your work in, you haven't done so already. We'll be creating & editing files later

#!/usr/bin/env bash
# The default shell is zsh, but the bash-profile feature only adds the kubectl shortcuts to /etc/bash.bashrc.
# Add the same shortcuts to zsh. Safe to run more than once.
set -euo pipefail

zshrc="${ZDOTDIR:-$HOME}/.zshrc"

if ! grep -q 'alias k=kubectl' "$zshrc" 2>/dev/null; then
  cat >> "$zshrc" <<'EOF'

# kubectl shortcuts (added by .devcontainer/post-create.sh)
source <(kubectl completion zsh)
alias k=kubectl
compdef k=kubectl
alias kubens='kubectl config set-context --current --namespace '
EOF
fi

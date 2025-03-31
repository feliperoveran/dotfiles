# enable vi keys for bash
set -o vi

# Source git completion functions
source /usr/share/bash-completion/completions/git

# Remap keys
xmodmap -e "keycode 47 = colon semicolon" || true

# git aliases
alias g="git"
alias ga="git add"
alias gb="git branch"
alias gc="git commit"
alias gco="git checkout"
alias gcom="git checkout main"
alias gd="git diff"
alias gl="git log"
alias gle="git log --pretty=full"
alias gm="git merge"
alias gp="git pull origin"
alias gpo="git push origin"
alias gs="git status"
alias gds="git diff --staged"
alias grv="git review -R"
alias grpo="git remote prune origin"
alias gdlf="git diff --name-status"

# Enable autocompletion for git aliases
__git_complete gb _git_branch
__git_complete gpo _git_branch
__git_complete gp _git_branch
__git_complete gco _git_checkout
__git_complete gdlf _git_checkout

# show branch name on PS1
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="${debian_chroot:+($debian_chroot)}\u@\h\[\033[00m\]:\[\033[32m\]\w\[\033[36m\]\$(parse_git_branch)\[\033[00m\]$ "

[ -f ~/.fzf.bash  ] && source ~/.fzf.bash

function vimo() {
  if test -f Session.vim; then
    env vim -S
  else
    env vim -c Obsession "$@"
  fi
}

function nvimo() {
  if ! command -v nvim; then
    echo "nvim could not be found!"
    return
  fi

  if test -f Session.vim; then
    env nvim -S
  else
    env nvim -c Obsession "$@"
  fi
}

# Kubernetes
alias k="kubectl"
complete -F __start_kubectl k
# TODO: more alias and https://github.com/cykerway/complete-alias
# https://github.com/ahmetb/kubectx/#installation

function kubectlgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v
    "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl -n ${1} get --ignore-not-found ${i}
  done
}

function kubectl_clean_terminated {
  kubectl get pods --all-namespaces | grep Terminated | awk '{print $1,$2}' | xargs -n2 bash -c 'kubectl delete pod -n $0 $1'
}

function list_go_build_tags() {
  find . -name '*.go' -exec grep '// +build' {} \; | awk -F'build ' '{print $2}' | tr ',' '\n' | tr ' ' '\n' | sort -u | tr '\n' ' '; echo
}

function findreplace {
  local old=$1
  local new=$2

  if [[ -z ${old} || -z ${new} ]]; then
    echo "usage: findreplace <old> <new>"
    return
  fi

  # Escape special characters in old and new
  local old_escaped
  local new_escaped

  old_escaped=$(printf "%s" "$old" | sed -e 's/[\\/&]/\\&/g')
  new_escaped=$(printf "%s" "$new" | sed -e 's/[\\/&]/\\&/g')

  # Use ag to find files and replace in them
  ag "$old" -l | xargs -I {} sed -i -e "s/${old_escaped}/${new_escaped}/g" {}
}

eval $(keychain --eval 2>/dev/null)

alias gam="/home/feliperoveran/bin/gam/gam"

alias vim="nvim"
export KUBE_EDITOR="nvim"

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
function gcom() {
  git checkout $(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
}
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

# gwt <name>: Create a git worktree adjacent to the primary repo at ../<repo-name>-<name>;
# if <name> doesn't exist locally, create from HEAD; otherwise reuse it.
gwt() {
  local name="$1"
  [ -n "$name" ] || { echo "usage: gwt <name>"; return 1; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "not in a git repo"; return 1; }

  # Primary (main) worktree root (first listed)
  local main_root
  main_root="$(git worktree list --porcelain | awk '/^worktree /{print substr($0,10); exit}')" || return 1
  [ -n "$main_root" ] || { echo "cannot resolve main worktree"; return 1; }

  local parent repo target
  parent="$(dirname "$main_root")"
  repo="$(basename "$main_root")"
  target="${parent}/${repo}-${name}"

  if git show-ref --verify --quiet "refs/heads/${name}"; then
    git -C "$main_root" worktree add "${target}" "${name}"
  else
    git -C "$main_root" worktree add -b "${name}" "${target}" HEAD
  fi
}

# gwt_rm <name>: Remove the worktree ../<repo-name>-<name>; if its branch exists and
# isn’t used elsewhere, attempt a safe delete (-d).
gwt_rm() {
  local name="$1"
  [ -n "$name" ] || { echo "usage: gwt_rm <name>"; return 1; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "not in a git repo"; return 1; }

  # Primary (main) worktree root
  local main_root
  main_root="$(git worktree list --porcelain | awk '/^worktree /{print substr($0,10); exit}')" || return 1
  [ -n "$main_root" ] || { echo "cannot resolve main worktree"; return 1; }

  local parent repo target
  parent="$(dirname "$main_root")"
  repo="$(basename "$main_root")"
  target="${parent}/${repo}-${name}"

  # Prefer exact registered path match ending with /<repo>-<name>
  local registered
  registered="$(git worktree list --porcelain | awk '/^worktree /{print substr($0,10)}' | grep -E "/${repo}-${name}$" || true)"
  if [ -n "$registered" ]; then
    target="$registered"
  fi

  # Verify it’s a registered worktree
  if ! git worktree list --porcelain | awk '/^worktree /{print substr($0,10)}' | grep -Fx -- "$target" >/dev/null; then
    echo "no registered worktree at: $target"
    return 1
  fi

  # If currently inside that worktree, hop to main root first
  case "$PWD/" in
    "$target"/*) cd "$main_root" || return 1 ;;
  esac

  git -C "$main_root" worktree remove "$target" || return 1
  git -C "$main_root" worktree prune >/dev/null 2>&1 || true

  # Safe-Delete branch if not used by any worktree
  if git show-ref --verify --quiet "refs/heads/${name}"; then
    if ! git worktree list --porcelain | grep -q "^branch refs/heads/${name}$"; then
      git -C "$main_root" branch -d "$name" || echo "note: branch '$name' not fully merged; use: git branch -D '$name' to force."
    fi
  fi

  echo "✅ removed worktree: $target"
}

# Enable autocompletion for git aliases
__git_complete gb _git_branch
__git_complete gpo _git_branch
__git_complete gp _git_branch
__git_complete gco _git_checkout

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

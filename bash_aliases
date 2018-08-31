alias brspec='bundle exec rspec'

# git aliases
alias g="git"
alias ga="git add"
alias gb="git branch"
alias gc="git commit"
alias gco="git checkout"
alias gcom="git checkout master"
alias gd="git diff"
alias gl="git log"
alias gm="git merge"
alias gp="git pull origin"
alias gpo="git push origin"
alias gs="git status"
alias gds="git diff --staged"

# show branch name on PS1
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
#export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

export PS1="${debian_chroot:+($debian_chroot)}\u@\h\[\033[00m\]:\[\033[32m\]\w\[\033[36m\]\$(parse_git_branch)\[\033[00m\]$ "

# vagrant aliases
alias vagemkt='cd /home/feliperoveran/locaweb/emkt/emkt-vagrant/ && vagrant up && vagrant ssh'
alias vaghg='cd /home/feliperoveran/locaweb/hg/vagrant/ && vagrant up && vagrant ssh'
alias vagsmtp='cd /home/feliperoveran/locaweb/smtp/vagrant/ && vagrant up && vagrant ssh'

# nibbler aliases
alias nibbler1='ssh -i ~/.ssh/id_rsa_nibbler _froveran@nibbler0001.linux.locaweb.com.br'
alias nibbler2='ssh -i ~/.ssh/id_rsa_nibbler _froveran@nibbler0002.linux.locaweb.com.br'

export PATH="$PATH:/home/feliperoveran/locaweb/hg/freddie/scripts"

[ -f ~/.fzf.bash  ] && source ~/.fzf.bash

function vimo() {
  if test -f Session.vim; then
    env vim -S
  else
    env vim -c Obsession "$@"
  fi
}

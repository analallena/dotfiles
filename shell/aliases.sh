#!/usr/bin/env bash
# Shortcuts

alias reload="source ~/.bash_profile"
alias ll="ls -la"

# Navigation

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
#alias -= "cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias ws="cd ~/ws"

# Yarn
#alias yi= "yarn install"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash;"

#git
alias g="git"
alias gp="git pull"
alias gc="git checkout"

alias bs-app="cd ~/ws/iberia/software-engineering--platform--backstage-application"
alias bs-data="cd ~/ws/iberia/software-engineering--platform--backstage-data"
alias bs-data-int="cd ~/ws/iberia/software-engineering--platform--backstage-data-int"
alias bs-tk="cd ~/ws/iberia/software-engineering--platform--technical-knowledge"
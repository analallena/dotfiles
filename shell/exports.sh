export HISTCONTROL=ignoredups
export HISTSIZE=5000
export HISTTIMEFORMAT="%h %d %H:%M:%S "

# hstr
export HSTR_CONFIG=hicolorm,case-sensitive,raw-history-view

export path=(
  "$DOTFILES_PATH/bin"
#  "$HOME/.krew/bin"
  "$JAVA_HOME/bin"
  "/usr/local/bin"  # This contains all Brew binaries (zsh...)
  "/usr/local/sbin" # This contains all Brew binaries
  "/bin"            # macOS zsh is here
  "/usr/bin"
  "/usr/sbin"
  "/sbin"
)
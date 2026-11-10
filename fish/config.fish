# PATH
set -Ux PATH ~/.bun/bin $PATH

# -----------------------------
# Initialize zoxide only in interactive shells
# -----------------------------
#status --is-interactive; and source (zoxide init fish)

# STOP MAKO THEN RUN AGAIN
# if pgrep -x mako >/dev/null
#     killall -q mako
# end
# sleep 0.5
# mako >/dev/null 2>&1 &
# disown
#

# -----------------------------
# Aliases
# -----------------------------
alias .. 'z ..'
alias . z
alias ls eza
alias l eza
alias cls clear
alias zj zellij
alias ff fastfetch
alias lg lazygit
alias oc opencode
alias br 'bun run'
alias tt 'taskwarrior-tui -r today'

# -----------------------------
# BINDS 
# -----------------------------
bind \t forward-char

# -----------------------------
# Git shortcuts
# -----------------------------
function add
    git add $argv
end

function commit
    git commit -m "$argv"
end

function pull
    git pull $argv
end

function push
    git push $argv
end

function branch
    git branch $argv
end

function gs
    git status $argv
end

function log
    git log --oneline --graph --all $argv
end

function checkout
    git checkout $argv
end

function restore
    git restore $argv
end

#zoxide
zoxide init fish | source

# Fast Fetch
fastfetch

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# TTYPER
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/go/bin $PATH

set -gx PATH $HOME/.local/bin $PATH

# simutil
fish_add_path /home/bakr/.local/lib/simutil

# opencode
fish_add_path /home/bakr/.opencode/bin

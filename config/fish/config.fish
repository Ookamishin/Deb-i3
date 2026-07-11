# Fish shell — Cyberpunk prompt & aliases

# Prompt
set -g theme_display_git yes
set -g theme_display_date no

function fish_prompt
    set -l cyan (set_color 00f0ff)
    set -l pink (set_color ff007f)
    set -l purple (set_color 7c3aed)
    set -l norm (set_color normal)
    set -l host (hostname -s)
    set -l dir (prompt_pwd)

    echo -n $cyan"["$pink$USER$cyan"@"$pink$host$cyan"] "$purple$dir$norm" "
end

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias cat='bat --theme=ansi'      # bat if installed
alias grep='rg'                   # ripgrep if installed
alias top='btop'
alias sys='fastfetch'
alias weather='curl wttr.in/Madrid'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'
alias gs='git status'
alias gp='git push'
alias gc='git commit -m'
alias ga='git add -A'
alias ..='cd ..'
alias ...='cd ../..'

# Auto-start neofetch on terminal open
if status is-interactive
    command -q fastfetch && fastfetch
end

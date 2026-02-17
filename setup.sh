#!/usr/bin/env bash
set -euo pipefail

echo "Starting Apple terminal setup..."

if ! command -v brew >/dev/null 2>&1; then
  cat <<'EOF'
Homebrew is required but not installed.
Install it first, then re-run this script:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
EOF
  exit 1
fi

BREW_PREFIX="$(brew --prefix)"
NVM_DIR_TARGET="${NVM_DIR_TARGET:-$HOME/.nvm}"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
ITERM_INTEGRATION="$HOME/.iterm2_shell_integration.zsh"

echo "Installing brew packages..."
brew install nvm eza zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
brew install --cask iterm2 font-meslo-lg-nerd-font font-symbols-only-nerd-font

echo "Installing nvm into: $NVM_DIR_TARGET"
mkdir -p "$NVM_DIR_TARGET"
if [ ! -s "$NVM_DIR_TARGET/nvm.sh" ]; then
  PROFILE=/dev/null NVM_DIR="$NVM_DIR_TARGET" curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo "Downloading iTerm2 shell integration..."
curl -fsSL https://iterm2.com/shell_integration/zsh -o "$ITERM_INTEGRATION"

echo "Updating $ZSHRC"
touch "$ZSHRC"
tmp_file="$(mktemp)"
awk '
BEGIN { skip = 0 }
$0 == "# >>> apple-terminal-settings >>>" { skip = 1; next }
$0 == "# <<< apple-terminal-settings <<<" { skip = 0; next }
skip == 0 { print }
' "$ZSHRC" > "$tmp_file"
cat "$tmp_file" > "$ZSHRC"
rm -f "$tmp_file"

cat >> "$ZSHRC" <<EOF

# >>> apple-terminal-settings >>>
# Managed by: poc/apple-terminal-settings/setup.sh
export NVM_DIR="$NVM_DIR_TARGET"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"

# History settings
HISTFILE="\$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Prompt with git branch
autoload -Uz colors vcs_info
colors
zstyle ':vcs_info:git:*' formats ' %F{213}(%b)%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
APPLE_GLYPH=\$'\\uf8ff'
PROMPT='%F{45}%n \${APPLE_GLYPH}%f %F{81}%~%f\${vcs_info_msg_0_} %F{244}>%f '

# zsh plugins
[ -r "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -r "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ] && source "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
[ -r "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# Up/Down arrow history search
bindkey "\${terminfo[kcuu1]}" history-substring-search-up
bindkey "\${terminfo[kcud1]}" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# iTerm2 shell integration
[ -r "$ITERM_INTEGRATION" ] && source "$ITERM_INTEGRATION"

# Colorful ls with icons
if command -v eza >/dev/null 2>&1; then
  # Apple Terminal can miss some Nerd Font glyphs; use color-only there.
  if [[ "\$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    alias ls='eza --icons=never --group-directories-first --color=always'
    alias ll='eza -la --icons=never --group-directories-first --git --color=always'
    alias la='eza -la --icons=never --group-directories-first --color=always'
  else
    alias ls='eza --icons=auto --group-directories-first --color=always'
    alias ll='eza -la --icons=auto --group-directories-first --git --color=always'
    alias la='eza -la --icons=auto --group-directories-first --color=always'
  fi
else
  alias ls='ls -G'
  alias ll='ls -lahG'
  alias la='ls -lahG'
fi
# <<< apple-terminal-settings <<<
EOF

echo
echo "Setup complete."
echo "Run: source \"$ZSHRC\""
echo "Then open iTerm2 and set fonts:"
echo "  1) Font: MesloLGS Nerd Font Mono"
echo "  2) Enable non-ASCII font and set: Symbols Nerd Font Mono"
echo "Apple Terminal note:"
echo "  Some icons may still be missing in Apple Terminal."
echo "  This setup automatically uses color-only ls output there."

# Apple Terminal Settings

One-command setup for a polished macOS terminal experience with:
- iTerm2
- `nvm`
- zsh autosuggestions and syntax highlighting
- Up/Down history substring search
- single-line custom prompt (with Apple logo + git branch)
- colorful `ls` with icons via `eza`

## Files
- `setup.sh`: installs dependencies and writes a managed block to `~/.zshrc`

## Run
```bash
cd /Users/vineet/Desktop/poc/apple-terminal-settings
chmod +x setup.sh
./setup.sh
source ~/.zshrc
```

## What `setup.sh` installs
- Homebrew formulae:
  - `nvm`
  - `eza`
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
  - `zsh-history-substring-search`
- Homebrew casks:
  - `iterm2`
  - `font-meslo-lg-nerd-font`
  - `font-symbols-only-nerd-font`

## Manual Steps (Required Once)
Icon glyphs render correctly only after setting iTerm2 fonts:

1. Open `iTerm2` -> `Settings` -> `Profiles` -> `Text`
2. Set `Font` to `MesloLGS Nerd Font Mono`
3. Enable `Use a different font for non-ASCII text`
4. Set non-ASCII font to `Symbols Nerd Font Mono`
5. Open a new iTerm tab/window

## Notes
- The script is idempotent for shell config:
  - It rewrites only the block between:
    - `# >>> apple-terminal-settings >>>`
    - `# <<< apple-terminal-settings <<<`
- Default nvm install path is `~/.nvm`.
- To use a custom nvm location:
```bash
NVM_DIR_TARGET="$HOME/Desktop/.nvm" ./setup.sh
```

## Troubleshooting
- If `brew` is missing, install Homebrew first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
- If icons look like `?`:
  - Re-check iTerm2 font settings in Manual Steps.
  - Open a new iTerm tab after applying the font changes.

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
plugins=(git nvm)
fastfetch
source $ZSH/oh-my-zsh.sh
export PATH=$PATH:/home/vib1240n/.local/bin
export CONFIG=$HOME/.config
export DEV=$HOME/Development/
eval "$(oh-my-posh init zsh --config /home/vib1240n/.cache/oh-my-posh/themes/peru.omp.json)"
(cat ~/.cache/wal/sequences &)

source $CONFIG/functions/alias

export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
alias caff='systemd-inhibit --what=idle:sleep:handle-lid-switch sleep infinity &'
alias decaff='pkill -f "systemd-inhibit --what=idle:sleep:handle-lid-switch"'
export FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"
# Qt6 fractional scaling fixes
export QT_SCALE_FACTOR_ROUNDING_POLICY="RoundPreferFloor"
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1.25

# Disable subpixel for clean rendering
export QT_XFT_ANTIALIAS=1
export QT_XFT_HINTING=1  
export QT_XFT_HINTSTYLE="hintslight"

# Enable stem darkening for macOS-like fonts
export FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"
export QT_QPA_PLATFORMTHEME=qt6ct

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

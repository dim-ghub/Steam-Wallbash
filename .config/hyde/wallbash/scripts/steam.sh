#!/bin/bash

SYSTEMCTL_PATH=$(command -v systemctl)
USERNAME=$(whoami)

# Sudoers rule to add
SUDOERS_LINE="$USERNAME ALL=(ALL) NOPASSWD: $SYSTEMCTL_PATH restart plugin_loader"

# dcol paths
COLOR_CONFIGS=(
    "~/.config/hyde/wallbash/always/steam#config.dcol"
    "~/.config/hyde/wallbash/always/steam#index.dcol"
    "~/.config/hyde/wallbash/always/steam#theme.dcol"
)

if [[ "$1" == "-r" ]]; then
    # restart plugin_loader
    sudo $SYSTEMCTL_PATH restart plugin_loader
else
    # Install Decky Loader if missing
    if [ ! -d "$HOME/homebrew" ]; then
        echo "Decky Loader not detected. Running installer..."
        sh -c 'rm -f /tmp/user_install_script.sh; \
        if curl -S -s -L -O --output-dir /tmp/ --connect-timeout 60 https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh; \
        then bash /tmp/user_install_script.sh; \
        else echo "Something went wrong, please report this if it is a bug"; read; fi'
    fi

    # Always attempt to install themes
    echo "Cloning SteamBash and installing themes..."
    git clone https://github.com/dim-ghub/SteamBash.git "$HOME/SteamBash"

    if [ -d "$HOME/SteamBash/themes" ]; then
        mkdir -p "$HOME/homebrew/themes"
        cp -r "$HOME/SteamBash/themes/"* "$HOME/homebrew/themes/"
        echo "Themes copied to ~/homebrew/themes/"
    else
        echo "Warning: SteamBash/themes folder not found."
    fi

    # sudo rule
    if ! command -v pkexec &>/dev/null; then
        echo "Error: pkexec is not installed."
        exit 1
    fi

    pkexec bash -c "
        TEMP_FILE=\$(mktemp)
        cp /etc/sudoers \$TEMP_FILE

        if ! grep -Fxq \"$SUDOERS_LINE\" \$TEMP_FILE; then
            echo \"$SUDOERS_LINE\" >> \$TEMP_FILE
        fi

        if visudo -c -f \$TEMP_FILE; then
            cp \$TEMP_FILE /etc/sudoers
            echo 'Sudo rule added successfully.'
        else
            echo 'Syntax error in sudoers file. Aborting.'
        fi

        rm -f \$TEMP_FILE
    "

    if [ $? -ne 0 ]; then
        echo "Warning: Failed to add sudo rule with pkexec. You may be prompted for a password when restarting plugin_loader."
    fi

    # apply wallbash
    echo "Applying Steam color configs..."
    for config in "${COLOR_CONFIGS[@]}"; do
        # Expand tilde
        eval CONFIG_PATH="$config"
        color.set.sh --single "$CONFIG_PATH"
    done
fi

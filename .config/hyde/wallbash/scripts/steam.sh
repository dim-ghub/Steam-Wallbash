#!/bin/bash

if ! command -v millennium >/dev/null 2>&1; then
    echo "'millennium' command not found. Aborting."
    exit 1
fi

pkexec chown -R $USER:$USER /home/$USER/.local/share/millennium

if [ -f /usr/bin/steam.millennium.bak ]; then
    echo "already patched"
else
    echo "not patched"
    pkexec millennium patch
fi

git clone https://github.com/shdwmtr/simply-dark.git ~/.local/share/Steam/steamui/skins/simply-dark

# Final instructions
echo "To apply the theme:"
echo "- Refresh Wallbash"
echo "- Restart Steam"
echo "- Go into the Millennium menu"
echo "- Click the settings button for the theme"
echo "- Navigate to 'Colors' and click 'Reset' next to each one"
echo "Sorry the process is a bit long — it's the only known way right now."

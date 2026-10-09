#!/bin/sh
set -eu

# Forge OS V1.1 desktop defaults. Run once for each user at first login.
mkdir -p "$HOME/Desktop" "$HOME/Forge/Projects" "$HOME/Forge/Games" "$HOME/Forge/SDKs" "$HOME/Forge/Downloads"

if command -v xfconf-query >/dev/null 2>&1; then
  xfconf-query -c xsettings -p /Net/ThemeName -s 'Arc-Darker' 2>/dev/null || true
  xfconf-query -c xsettings -p /Net/IconThemeName -s 'Papirus' 2>/dev/null || true
  xfconf-query -c xfwm4 -p /general/button_layout -s 'O|HMC' 2>/dev/null || true
  xfconf-query -c xfwm4 -p /general/theme -s 'Default' 2>/dev/null || true
  xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 42 2>/dev/null || true
  xfconf-query -c xfce4-panel -p /panels/panel-1/length -s 100 2>/dev/null || true
  xfconf-query -c xfce4-panel -p /panels/panel-1/autohide-behavior -s 0 2>/dev/null || true
  xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 2 2>/dev/null || true
fi

# Keep the live desktop and installed system visually consistent.
if [ -f /usr/share/backgrounds/forge/forge-wallpaper.svg ]; then
  mkdir -p "$HOME/.local/share/backgrounds"
  cp -f /usr/share/backgrounds/forge/forge-wallpaper.svg "$HOME/.local/share/backgrounds/forge-wallpaper.svg" || true
  if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$HOME/.local/share/backgrounds/forge-wallpaper.svg" 2>/dev/null || true
  fi
fi

# Only initialize the shortcuts once.
if [ ! -f "$HOME/.config/forge-v11-initialized" ]; then
  mkdir -p "$HOME/.config"
  touch "$HOME/.config/forge-v11-initialized"

  for app in firefox-esr thunar xfce4-terminal mousepad steam lutris; do
    desktop="/usr/share/applications/${app}.desktop"
    if [ -f "$desktop" ]; then
      cp -f "$desktop" "$HOME/Desktop/" 2>/dev/null || true
    fi
  done

  # Friendly Forge launchers.
  cat > "$HOME/Desktop/Forge-Gaming-Center.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Forge Gaming Center
Comment=Jogos, Steam, Lutris e ferramentas de desempenho
Exec=lutris
Icon=applications-games
Terminal=false
Categories=Game;
EOF
  chmod +x "$HOME/Desktop/Forge-Gaming-Center.desktop"

  cat > "$HOME/Desktop/Forge-Dev-Center.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Forge Dev Center
Comment=Ambiente para programação e projetos Forge
Exec=xfce4-terminal --working-directory=%h/Forge/Projects
Icon=utilities-terminal
Terminal=false
Categories=Development;
EOF
  chmod +x "$HOME/Desktop/Forge-Dev-Center.desktop"
fi

exit 0

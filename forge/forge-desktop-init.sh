#!/bin/sh
set -eu

# Forge OS V1.1 desktop defaults. Run once for each user at first login.
mkdir -p "$HOME/Desktop" "$HOME/Forge/Projects" "$HOME/Forge/Games" "$HOME/Forge/SDKs" "$HOME/Forge/Downloads" "$HOME/Forge/Assets" "$HOME/.config/gtk-3.0"

if command -v xfconf-query >/dev/null 2>&1; then
  # Forge visual identity: Windows-like workflow, but with Forge colors and spacing.
  xfconf-query -c xsettings -p /Net/ThemeName -s 'Arc-Darker' 2>/dev/null || true
  xfconf-query -c xsettings -p /Net/IconThemeName -s 'Papirus' 2>/dev/null || true
  xfconf-query -c xsettings -p /Gtk/FontName -s 'Inter 10' 2>/dev/null || true
  xfconf-query -c xfwm4 -p /general/button_layout -s 'O|HMC' 2>/dev/null || true
  xfconf-query -c xfwm4 -p /general/theme -s 'Default' 2>/dev/null || true
  xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 42 2>/dev/null || true
  xfconf-query -c xfce4-panel -p /panels/panel-1/length -s 100 2>/dev/null || true
  xfconf-query -c xfce4-panel -p /panels/panel-1/autohide-behavior -s 0 2>/dev/null || true
  xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 2 2>/dev/null || true
  # Forge is an always-ready live desktop: do not lock the session automatically.
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-suspend-hibernate -s false 2>/dev/null || true
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-on-suspend -s false 2>/dev/null || true
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0 2>/dev/null || true
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-off -s 0 2>/dev/null || true
fi

# Disable X11 screen blanking/locking for the live session.
if command -v xset >/dev/null 2>&1; then
  xset s off 2>/dev/null || true
  xset -dpms 2>/dev/null || true
  xset s noblank 2>/dev/null || true
fi

# Forge-specific GTK styling. It keeps the familiar Windows-like layout while
# making the Start/Whisker menu visibly different from stock XFCE.
cat > "$HOME/.config/gtk-3.0/gtk.css" <<'EOF'
/* Forge OS V1.1 — Forge Studio visual language */
#whiskermenu-window {
  border-radius: 18px;
  padding: 10px;
  background: rgba(12, 18, 30, 0.98);
  border: 1px solid rgba(75, 145, 255, 0.55);
}
#whiskermenu-window border {
  border-radius: 16px;
  border-width: 0;
}
#whiskermenu-window treeview.view {
  border-radius: 10px;
  padding: 5px;
}
#whiskermenu-window treeview.view:hover {
  background-color: rgba(48, 115, 220, 0.28);
}
#whiskermenu-window entry {
  border-radius: 12px;
  padding: 8px 12px;
}
EOF

# Keep the live desktop and installed system visually consistent.
if [ -f /usr/share/backgrounds/forge/forge-wallpaper.svg ]; then
  mkdir -p "$HOME/.local/share/backgrounds"
  cp -f /usr/share/backgrounds/forge/forge-wallpaper.svg "$HOME/.local/share/backgrounds/forge-wallpaper.svg" || true
  if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$HOME/.local/share/backgrounds/forge-wallpaper.svg" 2>/dev/null || true
  fi
fi

# Only initialize the Forge shortcuts once.
if [ ! -f "$HOME/.config/forge-v11-initialized" ]; then
  mkdir -p "$HOME/.config"
  touch "$HOME/.config/forge-v11-initialized"

  # Everyday applications.
  for app in firefox-esr thunar xfce4-terminal mousepad vlc pavucontrol; do
    desktop="/usr/share/applications/${app}.desktop"
    if [ -f "$desktop" ]; then
      cp -f "$desktop" "$HOME/Desktop/" 2>/dev/null || true
    fi
  done

  # Forge Gaming Center.
  cat > "$HOME/Desktop/Forge-Gaming-Center.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Forge Gaming Center
Comment=Jogos, Lutris, Wine, RetroArch e desempenho
Exec=lutris
Icon=applications-games
Terminal=false
Categories=Game;
EOF
  chmod +x "$HOME/Desktop/Forge-Gaming-Center.desktop"

  # Forge Dev Center.
  cat > "$HOME/Desktop/Forge-Dev-Center.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Forge Dev Center
Comment=Projetos, terminal e ferramentas de programação
Exec=xfce4-terminal --working-directory=%h/Forge/Projects
Icon=utilities-terminal
Terminal=false
Categories=Development;
EOF
  chmod +x "$HOME/Desktop/Forge-Dev-Center.desktop"

  # Core Forge Studio creation tools.
  for spec in \
    'Blender|blender|applications-graphics' \
    'Godot 3|godot3|applications-games' \
    'OBS Studio|obs|camera-video' \
    'Krita|krita|applications-graphics' \
    'GIMP|gimp|applications-graphics' \
    'Inkscape|inkscape|applications-graphics'; do
    name=$(printf '%s' "$spec" | cut -d'|' -f1)
    cmd=$(printf '%s' "$spec" | cut -d'|' -f2)
    icon=$(printf '%s' "$spec" | cut -d'|' -f3)
    file="$HOME/Desktop/Forge-${cmd}.desktop"
    cat > "$file" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Comment=Ferramenta Forge Studio
Exec=$cmd
Icon=$icon
Terminal=false
Categories=Development;Graphics;Game;
EOF
    chmod +x "$file"
  done
fi

# Steam is the only gaming component that cannot be installed in the normal
# live-build package phase because Debian's Steam package needs i386 enabled.
# On the first Forge login, start the setup automatically in the background.
# If there is no Internet, the manual desktop launcher remains available.
if [ -x /usr/local/bin/forge-install-steam ] && [ ! -f "$HOME/.config/forge-steam-setup-done" ] && [ ! -f "$HOME/.config/forge-steam-setup-running" ]; then
  touch "$HOME/.config/forge-steam-setup-running"
  (
    if sudo -n /usr/local/bin/forge-install-steam >/tmp/forge-steam-install.log 2>&1; then
      touch "$HOME/.config/forge-steam-setup-done"
      command -v notify-send >/dev/null 2>&1 && notify-send 'Forge Gaming' 'Steam foi instalado automaticamente.' || true
    fi
    rm -f "$HOME/.config/forge-steam-setup-running"
  ) &
fi

# Keep a manual launcher even when automatic Steam setup is running/offline.
if [ -x /usr/local/bin/forge-install-steam ]; then
  cat > "$HOME/Desktop/Forge-Install-Steam.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Instalar Steam
Comment=Ativa i386 e instala o Steam no Forge OS
Exec=pkexec /usr/local/bin/forge-install-steam
Icon=steam
Terminal=true
Categories=Game;
EOF
  chmod +x "$HOME/Desktop/Forge-Install-Steam.desktop"
fi

exit 0

#!/bin/sh
set -u

LOG=/tmp/forge-dev-tools-install.log
exec >"$LOG" 2>&1

echo 'Forge Dev Tools: iniciando instalação opcional.'

# GitHub CLI, Git, compilers, Python, Node, Java, Rust and Go are already part
# of the base Forge package set. This script only installs tools that are not
# safely available as Debian Bookworm packages during live-build.

# Microsoft Visual Studio Code — official Microsoft APT repository.
if ! command -v code >/dev/null 2>&1; then
  tmp_deb=/tmp/code-repo.deb
  if curl -fsSL https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.95.3-1731513102_amd64.deb -o "$tmp_deb"; then
    dpkg -i "$tmp_deb" || apt-get -f install -y
  else
    # Fallback to Microsoft's repository metadata so the current package can be resolved.
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg || true
    printf '%s\n' 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main' > /etc/apt/sources.list.d/vscode.list
    apt-get update || true
    apt-get install -y code || true
  fi
fi

# Android Studio — official Google download page. Resolve the current Linux
# archive at install time so the ISO does not depend on an old Studio version.
if [ ! -x /opt/android-studio/bin/studio ]; then
  mkdir -p /opt
  studio_url=$(curl -fsSL https://developer.android.com/studio 2>/dev/null | \
    grep -oE 'https://[^" ]+android-studio-[^" ]+-linux\.tar\.gz' | head -n 1 || true)
  if [ -n "$studio_url" ]; then
    tmp=/tmp/android-studio.tar.gz
    if curl -fL "$studio_url" -o "$tmp"; then
      rm -rf /opt/android-studio
      tar -xzf "$tmp" -C /opt
      rm -f "$tmp"
    fi
  fi
fi

# Make launchers available even if a network mirror was temporarily unavailable.
mkdir -p /usr/share/applications
if [ -x /opt/android-studio/bin/studio ]; then
  cat > /usr/share/applications/forge-android-studio.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Android Studio — Forge
Comment=Desenvolvimento Android no Forge OS
Exec=/opt/android-studio/bin/studio
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Categories=Development;IDE;
EOF
fi

if command -v code >/dev/null 2>&1; then
  cat > /usr/share/applications/forge-vscode.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Visual Studio Code — Forge
Comment=IDE principal de programação
Exec=code --new-window
Icon=code
Terminal=false
Categories=Development;IDE;
EOF
fi

exit 0

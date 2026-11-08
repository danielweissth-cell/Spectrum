#!/bin/sh
# Adds Spectrum to the desktop menu of the current user.
# Usage: linux/packaging/install_desktop_entry.sh <path to the built bundle folder>
set -eu
bundle=$(cd "$1" && pwd)
here=$(cd "$(dirname "$0")" && pwd)
id=com.danielweissth.media_player
mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/512x512/apps"
sed "s|@BUNDLE@|$bundle|" "$here/$id.desktop" > "$HOME/.local/share/applications/$id.desktop"
cp "$here/$id.png" "$HOME/.local/share/icons/hicolor/512x512/apps/$id.png"
gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
update-desktop-database -q "$HOME/.local/share/applications" 2>/dev/null || true
echo "Spectrum added to the menu: $HOME/.local/share/applications/$id.desktop"

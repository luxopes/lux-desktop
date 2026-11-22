#!/bin/bash
# LuxOS Desktop (unofficial, unsupported) - downloads the parts of the LuxOS source that the desktop
# is built from (github.com/luxopes/LuxOS-Arch, sparse checkout) and runs its installer:
#   ./install.sh            build the lux-desktop package and install it with your package manager
#   ./install.sh --build    only build the package
# LUXD_REF=<branch|tag> picks another LuxOS revision (default: main).
set -euo pipefail
REPO=https://github.com/luxopes/LuxOS-Arch.git
REF=${LUXD_REF:-main}
DIR=${LUXD_SRC:-${XDG_CACHE_HOME:-$HOME/.cache}/lux-desktop/LuxOS-Arch}

[[ $EUID -ne 0 ]] || { echo "lux-desktop: run as your normal user (sudo is used only to install packages)" >&2; exit 1; }
command -v git >/dev/null || { echo "lux-desktop: install git first (Fedora: sudo dnf install git, Arch: sudo pacman -S git)" >&2; exit 1; }

echo "==> LuxOS Desktop is an UNOFFICIAL, UNSUPPORTED side project and can be out of date with LuxOS."
if [[ -d $DIR/.git ]]; then
    echo "==> Updating the LuxOS source in $DIR"
    git -C "$DIR" fetch -q --depth 1 origin "$REF"
    git -C "$DIR" checkout -q --force FETCH_HEAD
else
    echo "==> Downloading the LuxOS source to $DIR"
    mkdir -p "${DIR%/*}"
    git clone -q --depth 1 --filter=blob:none --sparse --branch "$REF" "$REPO" "$DIR"
fi
git -C "$DIR" sparse-checkout set desktop-standalone LICENSES packages/luxos-i18n packages/luxos-branding \
    packages/luxos-themes packages/luxos-desktop packages/luxos-text packages/luxos-terminal packages/rofi
exec "$DIR/desktop-standalone/install.sh" "$@"

#!/usr/bin/env bash
# Setup script for the Claude Code cloud environment "native-mobile".
# Paste this into the environment's setup script at claude.ai/code.
# Installs: JDK 17, Android command-line tools (API 36), Swift (via swiftly).
# Target: stay under ~5 minutes so the environment can be cached.
# Every step is idempotent, so a re-run skips whatever is already installed.
set -euo pipefail

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null; then SUDO="sudo"; fi

ANDROID_API=36
ANDROID_BUILD_TOOLS=36.0.0
CMDLINE_TOOLS_ZIP=commandlinetools-linux-13114758_latest.zip   # check developer.android.com/studio#command-tools for newer
export ANDROID_HOME=/opt/android-sdk

echo "== apt packages (JDK 17 + Swift build deps) =="
$SUDO apt-get update -y -qq
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
  openjdk-17-jdk-headless unzip curl ca-certificates git gnupg2 build-essential pkg-config tzdata \
  libcurl4-openssl-dev libxml2-dev libsqlite3-dev libncurses-dev libedit2 libpython3-dev libz3-dev zlib1g-dev

echo "== Android command-line tools =="
if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
  tmp=$(mktemp -d)
  curl -fsSL "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP" -o "$tmp/clt.zip"
  unzip -q "$tmp/clt.zip" -d "$tmp"
  $SUDO mkdir -p "$ANDROID_HOME/cmdline-tools"
  $SUDO mv "$tmp/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
  $SUDO chown -R "$(id -u):$(id -g)" "$ANDROID_HOME"
  rm -rf "$tmp"
fi
SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
yes | "$SDKMANAGER" --licenses >/dev/null || true
"$SDKMANAGER" --install "platform-tools" "platforms;android-$ANDROID_API" "build-tools;$ANDROID_BUILD_TOOLS" >/dev/null

echo "== Swift toolchain (swiftly) =="
if ! command -v swift >/dev/null && [ ! -f "$HOME/.local/share/swiftly/env.sh" ]; then
  tmp=$(mktemp -d)
  (cd "$tmp" \
    && curl -fsSLO "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz" \
    && tar zxf "swiftly-$(uname -m).tar.gz" \
    && ./swiftly init --quiet-shell-followup --assume-yes)
  rm -rf "$tmp"
fi
# Sessions may run commands in non-login shells that never read .bashrc,
# so also link the swiftly-managed tools (swift, swiftc, ...) into /usr/local/bin.
if [ -d "$HOME/.local/share/swiftly/bin" ]; then
  for tool in "$HOME/.local/share/swiftly/bin/"*; do $SUDO ln -sf "$tool" /usr/local/bin/; done
fi

echo "== Make the tools visible to every shell =="
JAVA_HOME_DIR=$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")
$SUDO tee /etc/profile.d/native-mobile.sh >/dev/null <<EOF
export JAVA_HOME=$JAVA_HOME_DIR
export ANDROID_HOME=$ANDROID_HOME
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=\$JAVA_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH
[ -f "$HOME/.local/share/swiftly/env.sh" ] && . "$HOME/.local/share/swiftly/env.sh"
EOF
grep -q native-mobile.sh "$HOME/.bashrc" 2>/dev/null || echo '. /etc/profile.d/native-mobile.sh' >> "$HOME/.bashrc"

. /etc/profile.d/native-mobile.sh
java -version 2>&1 | head -1
swift --version 2>&1 | head -1
echo "native-mobile environment ready"

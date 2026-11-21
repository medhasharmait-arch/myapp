#!/usr/bin/env bash
# Setup script for the Claude Code cloud environment "native-mobile".
# Paste this into the environment's setup script at claude.ai/code.
# Installs: JDK 17 (build) + JDK 21 (Robolectric tests), Android command-line tools (API 36), Swift (official toolchain tarball, GPG-verified).
# Target: stay under ~5 minutes so the environment can be cached.
# Every step is idempotent, so a re-run skips whatever is already installed.
set -euo pipefail

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null; then SUDO="sudo"; fi

ANDROID_API=36
ANDROID_BUILD_TOOLS=36.0.0
CMDLINE_TOOLS_ZIP=commandlinetools-linux-13114758_latest.zip   # check developer.android.com/studio#command-tools for newer
SWIFT_VERSION=6.4.2                                            # check swift.org/install/linux for newer
SWIFT_HOME=/opt/swift
export ANDROID_HOME=/opt/android-sdk

echo "== apt packages (JDK 17 + 21, Swift build deps) =="
$SUDO apt-get update -y -qq
# `env` keeps the variable assignment valid when $SUDO is empty (running as root).
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
  openjdk-17-jdk-headless openjdk-21-jdk-headless unzip curl ca-certificates git gnupg2 build-essential pkg-config tzdata \
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

echo "== Swift toolchain $SWIFT_VERSION =="
# Not swiftly: swift.org serves keys/all-keys.asc gzip-encoded, and swiftly hands the raw bytes
# to `gpg --import`, which fails. So fetch the tarball directly and verify its signature here.
if [ ! -x "$SWIFT_HOME/usr/bin/swift" ]; then
  . /etc/os-release                                   # ubuntu 24.04 -> "ubuntu2404" / "ubuntu24.04"
  plat="${ID}${VERSION_ID//./}"; file_plat="${ID}${VERSION_ID}"
  if [ "$(uname -m)" = "aarch64" ]; then plat="$plat-aarch64"; file_plat="$file_plat-aarch64"; fi
  base="https://download.swift.org/swift-$SWIFT_VERSION-release/$plat/swift-$SWIFT_VERSION-RELEASE"
  tarball="swift-$SWIFT_VERSION-RELEASE-$file_plat.tar.gz"
  tmp=$(mktemp -d)
  export GNUPGHOME="$tmp/gnupg"; mkdir -m 700 "$GNUPGHOME"
  curl -fsSL --compressed https://www.swift.org/keys/all-keys.asc | gpg --batch --quiet --import
  curl -fsSL "$base/$tarball" -o "$tmp/swift.tar.gz"
  curl -fsSL "$base/$tarball.sig" -o "$tmp/swift.tar.gz.sig"
  gpg --batch --verify "$tmp/swift.tar.gz.sig" "$tmp/swift.tar.gz"
  $SUDO mkdir -p "$SWIFT_HOME"
  $SUDO tar -xzf "$tmp/swift.tar.gz" -C "$SWIFT_HOME" --strip-components=1
  unset GNUPGHOME
  rm -rf "$tmp"
fi
# Sessions may run commands in non-login shells that never read .bashrc,
# so also link the Swift tools (swift, swiftc, ...) into /usr/local/bin.
for tool in "$SWIFT_HOME/usr/bin/"swift*; do $SUDO ln -sf "$tool" /usr/local/bin/; done

echo "== Make the tools visible to every shell =="
# Pin JDK 17 explicitly: the base image may ship a newer default JDK that `javac` resolves to.
JAVA_HOME_DIR=/usr/lib/jvm/java-17-openjdk-$(dpkg --print-architecture)
$SUDO tee /etc/profile.d/native-mobile.sh >/dev/null <<EOF
export JAVA_HOME=$JAVA_HOME_DIR
export ANDROID_HOME=$ANDROID_HOME
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=\$JAVA_HOME/bin:$SWIFT_HOME/usr/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH
EOF
grep -q native-mobile.sh "$HOME/.bashrc" 2>/dev/null || echo '. /etc/profile.d/native-mobile.sh' >> "$HOME/.bashrc"

. /etc/profile.d/native-mobile.sh
java -version 2>&1 | grep -i version
swift --version 2>&1 | head -1
echo "native-mobile environment ready"

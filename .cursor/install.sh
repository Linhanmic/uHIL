#!/usr/bin/env bash
#
# Idempotent Cloud Agent bootstrap for the uHIL meta-repo.
#
# Prepares an end-to-end Gauge development environment:
#   - Go 1.26 toolchain (required by the `gauge` core and `html-report` plugin)
#   - Gauge core built and installed from the `gauge` submodule
#   - Gauge plugins: js (language runner), html-report + flash (built from source)
#   - gauge-js-demo Node dependencies (Taiko downloads its own Chromium)
#
# Safe to run repeatedly: every step checks for existing state before doing work.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GO_VERSION="1.26.7"
GO_ROOT="/usr/local/go"

log() { printf '\n=== %s ===\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Go toolchain
# ---------------------------------------------------------------------------
install_go() {
  if [ -x "${GO_ROOT}/bin/go" ] && "${GO_ROOT}/bin/go" version | grep -q "go${GO_VERSION}"; then
    log "Go ${GO_VERSION} already installed"
  else
    log "Installing Go ${GO_VERSION}"
    local tarball="go${GO_VERSION}.linux-amd64.tar.gz"
    curl -sSLo "/tmp/${tarball}" "https://go.dev/dl/${tarball}"
    sudo rm -rf "${GO_ROOT}"
    sudo tar -C /usr/local -xzf "/tmp/${tarball}"
    rm -f "/tmp/${tarball}"
  fi
  # Expose the toolchain on PATH for interactive and non-interactive shells.
  sudo ln -sf "${GO_ROOT}/bin/go" /usr/local/bin/go
  sudo ln -sf "${GO_ROOT}/bin/gofmt" /usr/local/bin/gofmt
}

# ---------------------------------------------------------------------------
# 2. Submodules
# ---------------------------------------------------------------------------
init_submodules() {
  log "Initializing git submodules"
  git -C "${REPO_ROOT}" submodule update --init --recursive
}

# ---------------------------------------------------------------------------
# 3. Gauge core
# ---------------------------------------------------------------------------
build_gauge() {
  log "Building and installing Gauge core"
  ( cd "${REPO_ROOT}/gauge"
    go run build/make.go
    sudo env "PATH=${PATH}" go run build/make.go --install --prefix=/usr/local )
  gauge version || true
}

# ---------------------------------------------------------------------------
# 4. Gauge plugins
# ---------------------------------------------------------------------------
install_js_plugin() {
  if gauge version 2>/dev/null | grep -q '^js '; then
    log "Gauge js plugin already installed"
  else
    log "Installing Gauge js plugin"
    gauge install js
  fi
}

build_plugin_from_source() {
  local dir="$1" name="$2"
  if gauge version 2>/dev/null | grep -q "^${name} "; then
    log "Gauge ${name} plugin already installed"
  else
    log "Building and installing Gauge ${name} plugin from source"
    ( cd "${REPO_ROOT}/${dir}"
      go run build/make.go
      go run build/make.go --install )
  fi
}

# ---------------------------------------------------------------------------
# 5. gauge-js-demo Node dependencies
# ---------------------------------------------------------------------------
install_demo_deps() {
  log "Installing gauge-js-demo Node dependencies"
  ( cd "${REPO_ROOT}/gauge-js-demo" && npm install )
}

main() {
  install_go
  export PATH="${GO_ROOT}/bin:${HOME}/go/bin:${PATH}"
  export GOPATH="${HOME}/go"
  init_submodules
  build_gauge
  install_js_plugin
  build_plugin_from_source html-report html-report
  build_plugin_from_source flash flash
  install_demo_deps
  log "Environment ready. Gauge plugins:"
  gauge version || true
}

main "$@"

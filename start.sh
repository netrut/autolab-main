#!/bin/bash
# ─────────────────────────────────────────────
#  Autolab — Start Web Server
#  Run every time: bash start.sh
# ─────────────────────────────────────────────

FLUTTER_BIN="/workspaces/autolab-main/flutter/bin"
BUILD_DIR="/workspaces/autolab-main/build/web"

# Add Flutter to PATH
export PATH="$PATH:$FLUTTER_BIN"

# Kill any existing server on port 8080
fuser -k 8080/tcp 2>/dev/null && echo "Stopped previous server on port 8080" || true

# Rebuild if source changed since last build
if [ "$1" == "--rebuild" ]; then
  echo "▶ Rebuilding Flutter web app..."
  cd /workspaces/autolab-main && flutter build web --release
fi

# Check build exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "⚠ No build found. Running full build first..."
  cd /workspaces/autolab-main && flutter build web --release
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 Autolab is running on port 8080"
echo ""
echo "  Open in browser:"
echo "  → Ports tab → port 8080 → 🌐 globe icon"
echo ""
echo "  To rebuild after code changes:"
echo "     bash start.sh --rebuild"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$BUILD_DIR"
python3 -m http.server 8080 --bind 0.0.0.0

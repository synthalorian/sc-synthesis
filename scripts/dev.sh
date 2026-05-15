#!/usr/bin/env bash
# SC:Synthesis — Development Runner
# Starts the Rust API server and optionally the Flutter app
# Usage: ./scripts/dev.sh [--flutter]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
APP_DIR="$SCRIPT_DIR/app"

echo "╔══════════════════════════════════════════╗"
echo "║        SC:Synthesis — Dev Mode           ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Kill any existing server process
if lsof -ti:3001 &>/dev/null; then
    echo "→ Stopping existing server on port 3001..."
    lsof -ti:3001 | xargs kill -9 2>/dev/null || true
    sleep 1
fi

# Start the Rust server
echo "→ Building and starting Rust API server..."
cd "$SERVER_DIR"

# Build in release for better perf, debug for faster iteration
if [ "$1" == "--release" ]; then
    cargo build --release 2>&1
    ./target/release/sc-synthesis-server --bind 0.0.0.0:3001 &
else
    cargo build 2>&1 | tail -5
    ./target/debug/sc-synthesis-server --bind 0.0.0.0:3001 &
fi

SERVER_PID=$!
echo "   Server PID: $SERVER_PID"

# Wait for server to be ready
echo "→ Waiting for server to start..."
for i in $(seq 1 15); do
    sleep 1
    if curl -s http://localhost:3001/api/v1/status &>/dev/null; then
        echo "   ✓ Server is alive on http://localhost:3001"
        break
    fi
    if [ "$i" -eq 15 ]; then
        echo "   ✗ Server failed to start within 15s"
        exit 1
    fi
done

echo ""

# Start Flutter if requested
if [ "$1" == "--flutter" ] || [ "$2" == "--flutter" ]; then
    echo "→ Starting Flutter app..."
    cd "$APP_DIR"
    flutter run -d linux &
    FLUTTER_PID=$!
    echo "   Flutter PID: $FLUTTER_PID"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Server: http://localhost:3001            ║"
echo "║  Status: http://localhost:3001/api/v1/status ║"
echo "║  Press Ctrl+C to stop                     ║"
echo "╚══════════════════════════════════════════╝"

# Cleanup on exit
trap "echo '→ Shutting down...'; kill $SERVER_PID 2>/dev/null; exit 0" INT TERM

# Keep running
wait
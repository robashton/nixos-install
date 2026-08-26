#!/usr/bin/env bash
# Suspend test with logging - run as root
# Logs are saved to /tmp/suspend-test-* for analysis if system freezes

set -e

LOG_DIR="/tmp/suspend-test-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"

echo "=== Suspend Test Logger ==="
echo "Logs will be saved to: $LOG_DIR"
echo ""

# Pre-suspend state capture
echo "[1/5] Capturing pre-suspend state..."
lsmod | grep nvidia > "$LOG_DIR/nvidia-modules-before.txt"
cat /proc/driver/nvidia/suspend > "$LOG_DIR/nvidia-suspend-state.txt"
systemctl cat nvidia-suspend.service > "$LOG_DIR/nvidia-suspend-service.txt" 2>&1 || true
systemctl cat nvidia-resume.service > "$LOG_DIR/nvidia-resume-service.txt" 2>&1 || true

# Start dmesg watcher
echo "[2/5] Starting dmesg watcher..."
dmesg -w > "$LOG_DIR/dmesg.log" 2>&1 &
DMESG_PID=$!
echo "  PID: $DMESG_PID"

# Start journal watcher for suspend-related units
echo "[3/5] Starting journal watcher..."
journalctl -f -u 'nvidia*' -u '*suspend*' -u '*sleep*' -u '*resume*' > "$LOG_DIR/journal.log" 2>&1 &
JOURNAL_PID=$!
echo "  PID: $JOURNAL_PID"

# Save PIDs for cleanup
echo "$DMESG_PID" > "$LOG_DIR/dmesg.pid"
echo "$JOURNAL_PID" > "$LOG_DIR/journal.pid"

# Sync filesystem
echo "[4/5] Syncing filesystems..."
sync

echo "[5/5] Ready to suspend."
echo ""
echo "Log directory: $LOG_DIR"
echo ""
echo "Press Enter to run 'systemctl suspend', or Ctrl+C to abort..."
read

echo "Suspending NOW - $(date)" >> "$LOG_DIR/timeline.log"
sync

systemctl suspend

# If we get here, we woke up successfully
echo "Resumed at $(date)" >> "$LOG_DIR/timeline.log"
echo ""
echo "=== RESUME SUCCESSFUL ==="
echo ""

# Cleanup
kill $DMESG_PID $JOURNAL_PID 2>/dev/null || true

# Post-resume capture
lsmod | grep nvidia > "$LOG_DIR/nvidia-modules-after.txt" || true
echo "Post-resume logs saved to $LOG_DIR"

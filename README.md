# worktrack

Automatic time tracking for git repos. Tracks work sessions using filesystem watching and terminal activity detection, with idle timeout handling. Designed for tying hours to git commits for invoice generation.

## Install

```bash
git clone git@github.com:gallop-systems/worktrack.git ~/Projects/worktrack
cd ~/Projects/worktrack
./install.sh
```

Or manually:

```bash
# Copy to PATH
mkdir -p ~/.local/bin
cp worktrack ~/.local/bin/worktrack
chmod +x ~/.local/bin/worktrack

# Add to PATH (if not already)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Install the shell hook for auto-tracking
worktrack init >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

The shell hook does two things:
- **Auto-starts** tracking when you `cd` into a registered repo
- **Records terminal activity** on every command, so reading code, running git commands, and planning all count as work time (not just file writes)

## Usage

```bash
# Register a repo for auto-tracking
cd ~/Projects/my-project
worktrack register

# Manual controls
worktrack start          # Start tracking current repo
worktrack stop           # Stop tracking and save session
worktrack status         # Show current session + today's total

# Reporting
worktrack report              # Current month summary
worktrack report 2026-01      # Specific month
worktrack dump 2026-01        # Raw JSON session data

# Management
worktrack list           # Show all registered repos
worktrack unregister     # Remove current repo from auto-tracking
worktrack update         # Pull latest version from GitHub and install
```

## How it works

- `fswatch` monitors file changes in the repo
- A shell hook (`precmd`) records terminal activity on every command
- A background watchdog manages sessions: starts on first activity, ends after 15 min idle
- Sessions are logged to `~/.worktrack/<repo>.jsonl`
- Survives laptop sleep: unsaved sessions are recovered on next start

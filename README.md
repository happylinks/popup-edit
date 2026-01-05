# popup-edit

A lightweight native macOS popup editor for use with CLI tools that support the `EDITOR` environment variable (like Claude Code).

![popup-edit](https://img.shields.io/badge/macOS-native-blue)

## Features

- Native macOS floating window
- Monospaced font for code/prompts
- **⌘↩** (Cmd+Enter) to save and close
- **⎋** (Escape) to cancel
- Proper multiline text editing with scrolling
- Text is pre-selected on open for quick replacement

## Installation

### Option 1: Build from source

```bash
# Clone the repo
git clone https://github.com/happylinks/popup-edit.git
cd popup-edit

# Compile
swiftc -O -o popup-edit popup-edit.swift

# Move to your bin directory
mv popup-edit ~/bin/
# or
sudo mv popup-edit /usr/local/bin/
```

### Option 2: Download release

Download the pre-built binary from the [releases page](https://github.com/happylinks/popup-edit/releases).

## Usage

### With Claude Code

```bash
EDITOR=~/bin/popup-edit claude
```

Or add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export EDITOR=~/bin/popup-edit
```

### Standalone

```bash
popup-edit /path/to/file.txt
```

## How it works

The editor:
1. Opens the specified file in a floating popup window
2. Blocks until you save (⌘↩) or cancel (⎋)
3. Exits with code 0 on save, code 1 on cancel

This makes it compatible with any tool that uses `EDITOR` and expects the editor to block until editing is complete.

## Requirements

- macOS 10.15+
- Swift 5.0+ (for building from source)

## License

MIT

# Hello World Plugin

A simple example plugin that demonstrates the dotfiles plugin system capabilities.

## Description

This plugin serves as a demonstration of how to create and structure plugins for the modern dotfiles framework. It provides a simple "hello world" functionality while showcasing plugin best practices.

## Features

- Simple greeting functionality
- Plugin system demonstration
- Configuration file management
- Installation and uninstallation scripts
- Cross-platform compatibility

## Installation

```bash
dot plugin install hello-world
dot plugin enable hello-world
```

## Usage

```bash
# Basic greeting
dot hello

# Greeting with custom name
dot hello "Alice"

# Check plugin status
dot plugin info hello-world
```

## Commands

- `hello [name]` - Display a greeting message

## Configuration

The plugin creates a configuration file at `~/.local/share/dotfiles/plugins/hello-world/config.json` to store plugin settings.

## Development

This plugin demonstrates:

- Plugin metadata structure (`plugin.yaml`)
- Core functionality implementation (`lib/core.sh`)
- Installation and uninstallation scripts
- Documentation and README files
- Plugin directory structure

## License

MIT License - This is an example plugin for the dotfiles framework.
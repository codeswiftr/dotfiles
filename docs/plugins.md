# 🔌 Plugin Development

Plugins extend the dotfiles CLI and workflows.

## Layout
```
plugins/
└── local/
    └── hello-world/
        ├── plugin.yaml
        ├── README.md
        ├── install.sh
        ├── uninstall.sh
        └── lib/
            └── core.sh
```

## Lifecycle
- Install: `dot plugin install local/hello-world`
- Uninstall: `dot plugin uninstall local/hello-world`
- List: `dot plugin list`

## plugin.yaml (example)
```yaml
name: hello-world
version: 0.1.0
entry: lib/core.sh
hooks:
  post-install: install.sh
  pre-uninstall: uninstall.sh
```

## Development
- Put reusable functions in `lib/*.sh` and source from the CLI.
- Keep scripts POSIX-compatible; lint with `shellcheck`.
- Provide a `README.md` with usage and commands.

## CLI Integration
- Add subcommands under `lib/cli/plugin.sh` if needed.
- Follow naming: `dot plugin <action>`.

## Testing
- Provide smoke scripts; integrate with `tests/infrastructure/*`.

## Publishing
- Keep plugins in-repo under `plugins/` or in separate repos with the same structure.

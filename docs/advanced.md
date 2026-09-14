# Advanced usage

Keep changes small and local.

## Config

- Prefer small files under `config/zsh/*.zsh`, `config/herdr/config.toml`, `config/nvim/lua/**`.
- Machine-local: `~/.zshrc.local`, `~/.env.local` — never commit secrets.
- Links: chezmoi source is `home/` — run `just link` or `./install.sh link` after edits.

## Install / update

```bash
./setup                     # memorable: standard profile
./install.sh install minimal
just update --self          # pull + relink
just update                 # also upgrade brew/npm/uv/mise
```

Encourage the same `./install.sh` / `./setup` path for contributors.

## Tools

- Platform packages: `config/tools.yaml` + Brewfile  
- Pinned CLIs: `mise.toml`  
- Add a tool once in `tools.yaml`; profiles pull groups  

## Multiplexer

Herdr only (`hw` `ha` `hl`). Prefix `Ctrl-a`. Phone clients: Moshi over Tailscale.

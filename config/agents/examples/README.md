# Agent Configuration Examples

These are **example node-agent configs** — not loaded automatically. They show how
to configure per-node agent behavior (which agents to use, resource limits, task routing).

## How to use

Copy `node-agent-template.zsh` to `config/agents/<your-hostname>.zsh` and customize.
It will be sourced automatically from `.zshrc` based on hostname.

## Key variables to configure

```zsh
AGENT_NODE_NAME="your-hostname"   # This node's name
AGENT_MAX_PARALLEL=2              # Max concurrent AI agents (based on RAM)
AGENT_DEFAULT="claude"            # Default agent command
AGENT_TASK_TYPES=("dev" "review") # Tasks this node handles
```

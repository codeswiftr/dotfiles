# Search Prompts Skill

Search your Claude Code conversation history for prompts matching keywords.

## Usage
```
/search-prompts <keywords...>
```

## Examples
```
/search-prompts flywheel compounding
/search-prompts cto autonomous factory
/search-prompts authentication api
```

## What it does
1. Scans all session JSONL files in ~/.claude/projects/
2. Extracts actual USER prompts (filters out tool results, system messages)
3. Ranks by keyword match count and prompt quality
4. Returns top 20 matching prompts with dates

## Output
Lists matching prompts with:
- Date of prompt
- Keywords matched
- Preview of prompt text (first 200 chars)

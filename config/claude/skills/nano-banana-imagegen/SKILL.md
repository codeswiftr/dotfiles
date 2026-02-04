---
name: nano-banana-imagegen
description: Generate image assets using Gemini (Nano Banana) via OpenRouter or Google API. Creates PNG/JPG images from text prompts.
---

# Nano Banana Image Generator

Generate high-quality image assets using Google's Gemini image generation API (internally codenamed "Nano Banana"). Supports both OpenRouter and direct Google API.

## When to Use
- Creating UI component mockups, icons, or illustrations for projects
- Generating placeholder images or design assets
- Producing marketing visuals or social media graphics
- Creating diagrams or conceptual visualizations

## Prerequisites
- Python 3.11+ with `httpx` (`uv add httpx`)
- One of:
  - **OpenRouter API key** (preferred): `export OPENROUTER_API_KEY='your-key'`
  - **Google API key**: `export GOOGLE_API_KEY='your-key'`

## Quick Start

```bash
# With OpenRouter (auto-detected if OPENROUTER_API_KEY is set)
python ~/.claude/skills/nano-banana-imagegen/scripts/generate.py "minimalist search icon"

# Explicit provider
python ~/.claude/skills/nano-banana-imagegen/scripts/generate.py "dark mode toggle" --provider openrouter
```

## Workflow

### Basic Generation
```bash
python ~/.claude/skills/nano-banana-imagegen/scripts/generate.py "your prompt"
```

### With Options
```bash
python ~/.claude/skills/nano-banana-imagegen/scripts/generate.py "your prompt" \
  --resolution 2K \
  --style minimalist \
  --output ./my-image.png \
  --count 3 \
  --provider openrouter
```

### Available Options
| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--resolution` | 1K, 2K, 4K | 2K | Output resolution |
| `--style` | minimalist, realistic, illustration, technical | minimalist | Style preset |
| `--output` | path | auto | Output file path |
| `--count` | 1-4 | 1 | Number of variations |
| `--model` | flash, pro, flash-thinking | flash | Model selection |
| `--provider` | openrouter, google, cli | auto | API provider |

## Provider Comparison

| Provider | Env Variable | Free Tier | Notes |
|----------|--------------|-----------|-------|
| **OpenRouter** | `OPENROUTER_API_KEY` | Yes (gemini-2.0-flash-exp:free) | Preferred, unified API |
| **Google** | `GOOGLE_API_KEY` | Limited | Direct access |
| **CLI** | N/A | Varies | Requires gemini CLI |

## Prompt Engineering Tips

### Formula for Quality Results
```
[SUBJECT] [COMPOSITION] [STYLE] [TECHNICAL] [QUALITY]
```

### Examples

**UI Component:**
```
Modern dark mode toggle switch, glass morphism style,
centered composition, minimalist flat design, 24x24 size,
rounded corners, blue-to-purple gradient, high contrast
```

**Icon Set:**
```
Minimalist search magnifying glass icon, thin line weight,
monochrome black on transparent, 24x24 pixels,
clean geometric shapes, suitable for app UI
```

**Marketing Visual:**
```
Abstract technology background, flowing data streams,
blue and purple color palette, modern tech aesthetic,
16:9 aspect ratio, suitable for hero section
```

## Configuration

Optional config file: `~/.config/nano-banana/config.json`
```json
{
  "provider": "openrouter",
  "default_resolution": "2K",
  "default_style": "minimalist",
  "output_directory": "./generated_assets"
}
```

## Rate Limits & Costs

### OpenRouter
- Free tier: `gemini-2.0-flash-exp:free` available
- Pay-per-use for other models
- Check https://openrouter.ai/models for current pricing

### Google Direct
- Free tier: ~15 requests/minute
- Pro tier: ~60 requests/minute
- Cost: ~$0.10 per 4K image

## Limitations
- Best for design assets, icons, illustrations
- Complex photographs may lack realism
- Text rendering can be inconsistent
- OpenRouter may return text descriptions instead of images for some prompts

## Integration with Other Skills
- Pair with `repo-reviewer` for design asset audits
- Use `git-committer` after finalizing assets
- Store generated assets in project's `assets/` or `static/` directory

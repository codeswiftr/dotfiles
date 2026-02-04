---
name: perplexity-researcher
description: Conduct real-time web research with citations using Perplexity Sonar API. Supports quick lookups, deep analysis, and async research reports.
---

# Perplexity Researcher

AI-powered research with real-time web search and automatic citations via Perplexity's Sonar API.

## When to Use

- Researching current events, news, or recent developments (last 24-48 hours)
- Technical documentation, API references, best practices
- Market research, competitor analysis
- Fact-checking and verification with authoritative sources
- Deep research reports requiring extensive sourcing

## Prerequisites

- Perplexity MCP server installed: `claude mcp add perplexity --env PERPLEXITY_API_KEY="pplx-xxx" -- npx -yq @perplexity-ai/mcp-server`
- Valid API key from https://sonar.perplexity.ai/

## Research Modes

### 1. Quick Research (sonar)
For simple factual queries and summaries. Fast and cost-effective.

```
Use Perplexity to quickly look up: [topic]
```

### 2. Standard Research (sonar-pro)
For complex queries requiring deeper analysis and follow-up capability.

```
Research [topic] using Perplexity:
- Current state and recent developments
- Key findings and insights
- Actionable recommendations
Include all sources with URLs.
```

### 3. Reasoning Research (sonar-reasoning-pro)
For technical decisions and trade-off analysis.

```
Analyze the trade-offs between [option A] vs [option B] for [use case].
Use Perplexity reasoning mode for in-depth technical analysis.
```

### 4. Deep Research (sonar-deep-research)
For comprehensive reports with extensive citations. Async mode, takes 2-5 minutes.

```
Conduct deep research on [topic]:
- Comprehensive multi-source analysis
- Multiple perspectives and viewpoints
- Extensive citations and sourcing
Use sonar-deep-research model (async).
```

## Workflow

### Quick Lookup
Use the MCP `perplexity_search` tool directly for fast answers with citations.

### Structured Research
1. **Define scope**: Clear research question with specific deliverables
2. **Select model**: Match complexity to appropriate Sonar model (see references/models.md)
3. **Execute query**: Use Perplexity MCP tool
4. **Format output**:
   - **Summary**: 2-3 sentence overview
   - **Key Findings**: Bullet points with evidence
   - **Sources**: URLs with titles and access dates
   - **Next Actions**: Specific follow-up tasks

### Save Research
Store findings in project documentation:
```
docs/research/YYYY-MM-DD-topic.md
```

## Prompt Templates

### Technology Evaluation
```
Evaluate [TECHNOLOGY] for [USE CASE]:
1. What problems does it solve?
2. Current alternatives and comparisons
3. Pros and cons with specific examples
4. Community and maintenance status
5. Integration complexity and learning curve
6. Clear recommendation with reasoning
Include sources from 2024-2025.
```

### Best Practices Research
```
Research current best practices for [DOMAIN]:
- Industry standards (2024-2025)
- Common implementation patterns
- Pitfalls to avoid with examples
- Recommended tools and frameworks
Cite authoritative sources (official docs, reputable blogs).
```

### API/Library Investigation
```
Investigate [API/LIBRARY]:
- Official documentation links
- Key features and capabilities
- Usage examples and code snippets
- Known limitations and gotchas
- Version compatibility matrix
Prioritize official docs and recent community discussions.
```

### Competitive Analysis
```
Analyze competitors in [MARKET]:
- Top 5 players with market position
- Feature comparison matrix
- Pricing models and tiers
- Strengths and weaknesses
- Recent news and announcements
- Market trends and predictions
```

### Current Events / News
```
What are the latest developments in [TOPIC]?
Focus on the last [timeframe: 24 hours / week / month].
Include sources with publication dates.
```

## Model Selection Guide

| Query Type | Model | When to Use |
|------------|-------|-------------|
| Quick facts, definitions | sonar | Simple lookups, fast answers |
| Complex analysis | sonar-pro | Multi-step queries, comparisons |
| Technical decisions | sonar-reasoning | Trade-offs, architecture choices |
| Advanced reasoning | sonar-reasoning-pro | Deep technical analysis |
| Comprehensive reports | sonar-deep-research | Documentation, whitepapers |

See `references/models.md` for detailed specifications.

## Output Format

Always structure research output as:

```markdown
# Research: [Topic]

**Date**: YYYY-MM-DD
**Model**: sonar-pro
**Query**: [Original research question]

## Summary
[2-3 sentence executive summary]

## Key Findings
- Finding 1 with evidence
- Finding 2 with evidence
- Finding 3 with evidence

## Detailed Analysis
[Expanded analysis organized by theme]

## Sources
1. [Title](URL) - Brief description
2. [Title](URL) - Brief description

## Next Actions
- [ ] Action item 1
- [ ] Action item 2
```

## Tips

- **Recency**: Perplexity excels at recent information; specify timeframes when relevant
- **Citations**: Always include sources for verification; note when information may be outdated
- **Iteration**: Use follow-up queries to drill deeper into specific aspects
- **Cross-reference**: For critical decisions, verify with multiple queries
- **Cost awareness**: deep-research is expensive (~$0.50/report); use for substantial research only
- **Confidence**: Note when Perplexity hedges or expresses uncertainty

## Troubleshooting

### MCP Connection Issues
```bash
claude mcp list  # Verify server is running
claude mcp remove perplexity && claude mcp add perplexity ...  # Reinstall
```

### Rate Limits
Implement delays between queries. Use lower search modes for bulk research.

### Timeout Errors
Increase timeout: set `PERPLEXITY_TIMEOUT_MS=600000` (10 minutes)

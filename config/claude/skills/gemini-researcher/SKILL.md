---
name: gemini-researcher
description: Run structured research using the Gemini CLI, capture findings, and store them with citations and follow-up actions.
---

# Gemini Researcher

Deep research capability using Google's Gemini CLI for comprehensive analysis.

## When to Use
- Investigating technical topics, APIs, or frameworks
- Validating architectural decisions with evidence
- Gathering market intelligence or competitive analysis
- Researching compliance, security, or best practices

## Prerequisites
- Gemini CLI installed: `pip install google-generativeai` or via Google Cloud
- API key configured: `export GOOGLE_API_KEY='your-key'`

## Workflow

### Quick Research
```bash
gemini -p "Research [topic]: goals, current state, recommendations" > research-notes.md
```

### Structured Research
1. Craft a focused prompt with clear deliverables:
   ```
   Research [TOPIC]:
   - Current state of the art
   - Key players and solutions
   - Pros/cons analysis
   - Actionable recommendations
   Include sources with URLs.
   ```

2. Execute: `gemini -p "your prompt" > docs/research/YYYY-MM-topic.md`

3. Review and structure output:
   - Summary (2-3 sentences)
   - Key Findings (bullet points)
   - Sources (with URLs and dates)
   - Next Actions (specific tasks)

4. Link findings to relevant project documentation

## Prompt Templates

### Technology Evaluation
```
Evaluate [TECHNOLOGY] for [USE CASE]:
1. What problems does it solve?
2. Alternatives and comparisons
3. Integration complexity
4. Community and support status
5. Recommendation with reasoning
```

### Best Practices Research
```
Research best practices for [DOMAIN]:
- Industry standards
- Common pitfalls
- Implementation patterns
- Tools and frameworks
Include recent sources (2024-2025).
```

## Tips
- Always include sources with URLs; note confidence when Gemini hedges
- For lengthy output, distill into bullet-friendly sections
- Cross-reference with multiple queries for controversial topics
- Save raw output before editing for reference

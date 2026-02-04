# Perplexity Sonar Model Reference

## Model Family Overview

Perplexity's Sonar models are purpose-built for search-augmented generation. They provide real-time web access with automatic citation generation.

## Available Models

### sonar
**Best for**: Quick factual queries, summaries, current events

| Spec | Value |
|------|-------|
| Base Model | Llama 3.3 70B |
| Speed | 1200 tokens/second |
| Context | 128K tokens |
| SimpleQA Score | 0.773 |
| Cost | Low |

**Use cases**:
- Quick lookups and definitions
- Topic summaries
- Product comparisons
- Current events
- Simple information retrieval

---

### sonar-pro
**Best for**: Complex queries, follow-up questions, deeper analysis

| Spec | Value |
|------|-------|
| Speed | Fast |
| Context | Extended |
| SimpleQA Score | 0.858 (industry leading) |
| Cost | Medium |

**Use cases**:
- Multi-step research queries
- Complex comparisons
- Detailed analysis requiring multiple sources
- Follow-up investigations

---

### sonar-reasoning
**Best for**: Real-time reasoning with search grounding

| Spec | Value |
|------|-------|
| Type | Reasoning + Search |
| Speed | Fast |
| Cost | Medium |

**Use cases**:
- Technical decision-making
- Trade-off analysis
- Architecture recommendations
- Problem-solving with current data

---

### sonar-reasoning-pro
**Best for**: Advanced reasoning with comprehensive search

| Spec | Value |
|------|-------|
| Base Model | DeepSeek-R1 |
| Type | Advanced Reasoning + Search |
| Speed | Medium |
| Cost | Higher |

**Use cases**:
- Complex technical analysis
- Strategic planning with market data
- Deep reasoning chains
- Expert-level recommendations

---

### sonar-deep-research
**Best for**: Comprehensive research reports

| Spec | Value |
|------|-------|
| Mode | Asynchronous |
| Time | 2-5 minutes typical |
| Output | Long-form reports |
| TTL | 7 days |
| Cost | Higher |

**Use cases**:
- Whitepapers and documentation
- Market research reports
- Comprehensive competitive analysis
- Due diligence research

**Async API Endpoints**:
- `POST /async/chat/completions` - Create job
- `GET /async/chat/completions/{id}` - Poll status
- `GET /async/chat/completions` - List all jobs

---

## Search Modes

Available for sonar and sonar-pro:

| Mode | Depth | Cost | Best For |
|------|-------|------|----------|
| `low` | Minimal | $ | Simple factual queries |
| `medium` | Balanced | $$ | General research (default) |
| `high` | Maximum | $$$ | Complex analysis, critical decisions |

---

## Pricing (2025)

### Token Costs
- **Citation tokens**: FREE (except deep-research)
- **Input tokens**: Prompt + citations processed
- **Output tokens**: Generated response

### Deep Research Costs
- **Searches**: $5/1000 searches
- **Reasoning**: Separate billing for reasoning phase
- **Typical report**: ~$0.30-0.50

### Pro Subscription Benefit
Pro subscribers receive $5/month in API credits automatically.

---

## Model Selection Decision Tree

```
Is it a simple factual query?
├── Yes → sonar (low mode)
└── No
    ├── Does it require reasoning/trade-offs?
    │   ├── Yes → sonar-reasoning or sonar-reasoning-pro
    │   └── No
    │       ├── Is it a comprehensive report?
    │       │   ├── Yes → sonar-deep-research (async)
    │       │   └── No → sonar-pro (medium/high mode)
```

---

## Environment Variables

```bash
PERPLEXITY_API_KEY     # Required: Your API key
PERPLEXITY_MODEL       # Optional: Default model (default: sonar)
PERPLEXITY_TIMEOUT_MS  # Optional: Request timeout (default: 300000)
PERPLEXITY_LOG_LEVEL   # Optional: DEBUG|INFO|WARN|ERROR
```

---

## Rate Limits & Best Practices

1. **Implement backoff**: Exponential backoff on rate limit errors
2. **Monitor usage**: Check `usage` field in responses
3. **Batch wisely**: Group related queries rather than many small ones
4. **Cache results**: Store responses for repeated queries
5. **Use appropriate mode**: Don't over-specify search depth

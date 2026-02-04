---
name: debug
description: Investigate and fix bugs. Uses debug-detective agent for complex issues.
arguments: issue_description
---

# Debug: $ARGUMENTS

Investigate and fix bugs. For complex issues, spawns **debug-detective agent**.

## When to Use
- Any bug or issue that needs investigation
- Simple bugs: fix directly
- Complex bugs: use debug-detective agent

### Complex Bug Indicators
- Intermittent/flaky failures
- Race conditions or timing issues
- Production-only bugs
- Memory leaks or resource exhaustion
- Issues spanning multiple systems

## Workflow

### 1. Document the Symptom
- What exactly is the observed behavior?
- What is the expected behavior?
- How often does it occur? (100%, random, under load?)
- When did this start? What changed?

### 2. Spawn Debug Detective Agent
Use the Task tool with `subagent_type: debug-detective` to:
- Gather and analyze evidence (logs, metrics, traces)
- Form hypotheses about root cause
- Design experiments to test each hypothesis
- Identify the true root cause

### 3. Investigation Framework
The agent follows this process:

```markdown
## 🔍 Debug Investigation

### Symptom Analysis
- Observed Behavior: [What's happening]
- Expected Behavior: [What should happen]
- Frequency: [Always / Intermittent / Specific conditions]
- First Occurrence: [When it started]

### Evidence Collected
- Logs: [Key entries]
- Metrics: [Relevant data at failure time]
- Timeline: [Sequence of events]
- Patterns: [Any patterns observed]

### Hypotheses
#### Hypothesis 1: [Name]
- Theory: [What might cause it]
- Evidence For/Against: [Supporting data]
- Test: [How to confirm/eliminate]
- Likelihood: [High/Medium/Low]

### Root Cause
- Location: `file.py:line`
- Issue: [What's actually wrong]
- Why It Happens: [Underlying cause]
- Why It Wasn't Caught: [Gap in testing/review]

### Recommended Fix
[Code or configuration change]

### Prevention
- [ ] Add test for this scenario
- [ ] Add monitoring for early detection
- [ ] Update documentation
```

## Techniques Available
- Binary search debugging (bisect changes)
- Differential debugging (compare working vs failing)
- Stress testing (apply load/constraints)
- Instrumentation (strategic logging)
- Minimization (smallest repro case)

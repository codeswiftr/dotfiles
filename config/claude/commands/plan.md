---
name: plan
description: Research, design architecture, and create implementation plan
arguments: milestone_description
---

# Plan: $ARGUMENTS

Research, design, and create a comprehensive implementation plan.

## Workflow

### 1. Research (Explore Agent)
- Existing codebase patterns
- Related implementations
- Dependencies and constraints

### 2. Architecture Design
For complex systems, design:
- Component architecture
- Data models and API contracts
- Integration points
- Security considerations

### 3. Task Breakdown
Create actionable tasks:
- **Small**: 2-4 hours max
- **Testable**: Clear done criteria
- **Ordered**: Logical sequence

### 4. Output: PLAN.md

```markdown
# Milestone: [Name]

## Status: Planning | Ready | In Progress
## Target: [Date/Sprint]

---

## Overview
[1-2 paragraphs: what and why]

## Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]

## Technical Design

### Architecture
[Components, data flow, key decisions]

### Data Models
[Key entities]

### API Contracts
[Endpoints if applicable]

---

## Implementation Plan

### Phase 1: [Name]
| Task | Description | Agent | Est |
|------|-------------|-------|-----|
| 1.1 | [Description] | backend-engineer | 2h |
| 1.2 | [Description] | - | 1h |

**Checkpoint**: [What works after Phase 1]

### Phase 2: [Name]
| Task | Description | Agent | Est |
|------|-------------|-------|-----|
| 2.1 | [Description] | frontend-builder | 2h |

**Checkpoint**: [What works after Phase 2]

---

## Testing Strategy
- Unit: [Coverage target]
- Integration: [What to test]
- E2E: [Critical paths]

## Risks
| Risk | Mitigation |
|------|------------|
| [Risk] | [Strategy] |

## Open Questions
- [ ] [Question]
```

## Agent Recommendations

| Task Type | Agent |
|-----------|-------|
| API/Backend | backend-engineer |
| UI/Frontend | frontend-builder |
| Tests | qa-test-guardian |
| Security review | security-auditor |
| Performance | performance-optimizer |
| Complex bugs | debug-detective |
| Architecture | architect-advisor |
| DevOps | devops-deployer |

## Checklist
- [ ] Tasks are small (≤4h)
- [ ] Success criteria measurable
- [ ] Risks documented
- [ ] Testing strategy defined

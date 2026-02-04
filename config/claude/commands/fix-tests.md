---
name: fix-tests
description: Systematic protocol for fixing failing tests with senior developer debugging mindset
---

# Fix Failing Tests

Apply senior developer debugging protocol to systematically fix failing tests.

## Debugging Mindset
- Observe without judgment
- Question assumptions - is the test correct or the implementation?
- TDD is about discovery, not being right the first time
- Quiet the ego

## Protocol

### Step 1: Assess the Situation
```bash
# Run tests and capture output
pytest --tb=short -q 2>&1 | head -100

# Or for Node
npm test 2>&1 | head -100
```

Note:
- Total passed/failed/skipped
- Which test files are failing
- Error patterns (same error across tests?)

### Step 2: Analyze Each Failure

For each failing test:

```
┌─────────────────────────────────────────────┐
│         FAILURE ANALYSIS LOOP               │
├─────────────────────────────────────────────┤
│                                             │
│  1. READ the test code                      │
│     - What is it actually testing?          │
│     - What's the expected behavior?         │
│                                             │
│  2. READ the error message                  │
│     - What specifically failed?             │
│     - Expected vs Actual values?            │
│                                             │
│  3. QUESTION                                │
│     - Is the test correct?                  │
│     - Is the implementation incomplete?     │
│     - Is there a dependency issue?          │
│                                             │
│  4. TRACE                                   │
│     - Follow code path from test to impl    │
│     - Identify the exact failure point      │
│                                             │
│  5. FIX                                     │
│     - Minimal change that addresses root    │
│     - Run test to verify                    │
│                                             │
└─────────────────────────────────────────────┘
```

### Step 3: Persistent Error Protocol
If same error occurs twice:
1. **Stop and think** - Write 3 distinct reasoning paragraphs
2. **Zoom out** - Review entire component, not just the function
3. **Consider**:
   - State management issues
   - Dependency injection problems
   - Order of operations
   - Edge cases in test data
   - Environment differences

### Step 4: Common Failure Patterns

| Error Type | Likely Cause | Fix Approach |
|------------|--------------|--------------|
| `AttributeError` | Missing attribute/method | Check class definition, settings |
| `ImportError` | Missing dependency or path | Check imports, __init__.py |
| `AssertionError` | Logic error | Compare expected vs actual |
| `TypeError` | Wrong argument type | Check function signatures |
| `KeyError` | Missing dict key | Check data structure |
| `ConnectionError` | External dependency | Mock the dependency |
| `Timeout` | Slow or hanging code | Add timeout, check infinite loops |

### Step 5: Fix Workflow

```
Make it work → Make it right → Make it fast
```

1. **Implement minimal fix** that addresses root cause
2. **Run the specific test** to verify
3. **Run related tests** to check for regressions
4. **Run full suite** before committing
5. **Commit with descriptive message**

## Output Format

```markdown
## 🔧 Test Fix Report

### Initial State
```
Tests: X passed, Y failed, Z skipped
```

### Failures Analyzed

#### Failure 1: `test_name`
**Error**: `ErrorType: message`
**Root Cause**: [What's actually wrong]
**Fix**: [What was changed]
```python
# Before
broken_code()

# After
fixed_code()
```

#### Failure 2: `test_name`
[Same structure...]

### Final State
```
Tests: X passed, 0 failed, Z skipped
```

### Changes Made
| File | Change |
|------|--------|
| `file.py` | [Description] |

### Commits
- `abc123` fix(module): Resolve test failures in X

### Remaining Issues
- [Any tests still failing or skipped for valid reasons]
```

## Commands
```bash
# Run single failing test with verbose output
pytest tests/path/to_test.py::test_name -v

# Run tests in same file
pytest tests/path/to_test.py -v

# Run with print statements visible
pytest -s tests/path/to_test.py

# Run tests matching pattern
pytest -k "pattern" -v
```

## Checklist
- [ ] All failures identified
- [ ] Root causes understood (not just symptoms)
- [ ] Minimal fixes applied
- [ ] No new failures introduced
- [ ] Full suite passing
- [ ] Changes committed

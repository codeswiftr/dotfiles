---
name: test-coverage-analyzer
description: Analyze test coverage, identify gaps, and suggest tests to improve coverage in critical paths.
---

# Test Coverage Analyzer

## When to Use
- After implementing new features to ensure coverage.
- Before releases to validate quality.
- When refactoring to ensure regression protection.
- During code reviews to assess test quality.

## Coverage Metrics

| Metric | Target | Critical |
|--------|--------|----------|
| Line Coverage | 80%+ | 60%+ |
| Branch Coverage | 75%+ | 50%+ |
| Function Coverage | 90%+ | 70%+ |

## Workflow

### 1. Generate Coverage Report
```bash
# Python (pytest)
pytest --cov=src --cov-report=html --cov-report=term-missing

# JavaScript (Jest)
npm test -- --coverage

# Go
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Rust
cargo tarpaulin --out Html
```

### 2. Analyze Gaps
Focus on:
- **Critical paths**: Auth, payments, data handling.
- **Error handling**: Exception branches, edge cases.
- **Business logic**: Core domain functions.
- **Integration points**: API calls, database operations.

### 3. Prioritize Tests
| Priority | What to Test |
|----------|-------------|
| P0 | Security-critical code (auth, encryption) |
| P1 | Business-critical logic (payments, core features) |
| P2 | Error handling and edge cases |
| P3 | Utility functions and helpers |
| P4 | UI components (if not critical) |

### 4. Generate Test Suggestions
For each uncovered function:
- Identify input types and ranges.
- List edge cases (null, empty, boundary).
- Note error conditions to test.
- Suggest mocking requirements.

## Test Suggestion Template
```markdown
## Missing Coverage: `function_name` (file.py:42)

### Current Coverage: 45% (lines 42-60 uncovered)

### Suggested Tests:

#### Happy Path
```python
def test_function_name_success():
    result = function_name(valid_input)
    assert result == expected_output
```

#### Edge Cases
```python
def test_function_name_empty_input():
    with pytest.raises(ValueError):
        function_name("")

def test_function_name_boundary():
    result = function_name(MAX_VALUE)
    assert result == expected_boundary
```

#### Error Handling
```python
def test_function_name_handles_timeout():
    with mock.patch('module.external_call', side_effect=TimeoutError):
        result = function_name(input)
        assert result == fallback_value
```
```

## Output Checklist
- [ ] Coverage report generated.
- [ ] Critical path coverage verified.
- [ ] Gap analysis completed.
- [ ] Test suggestions for uncovered code.
- [ ] Priority ranking for new tests.

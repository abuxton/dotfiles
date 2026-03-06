---
name: code-review
description: "Systematic code review: security checks, performance analysis, complexity assessment, best practice validation, and review checklists."
metadata: {"thinkfleetbot":{"emoji":"🔍","requires":{"anyBins":["gh","git"]}}}
---

# Code Review

Systematic code review covering security, performance, maintainability, and correctness.

## Review a PR

```bash
# View PR diff
gh pr diff <PR_NUMBER>

# View specific file changes
gh pr diff <PR_NUMBER> -- src/specific-file.ts

# View PR details and checks
gh pr view <PR_NUMBER> --json title,body,additions,deletions,changedFiles,reviews | jq .

# List changed files
gh pr diff <PR_NUMBER> --name-only
```

## Review Checklist

When reviewing code, check each category:

### Correctness
- Does the code do what the PR description says?
- Are edge cases handled (null, empty, overflow, concurrency)?
- Are error paths handled, not just happy paths?
- Do new functions have clear input/output contracts?

### Security
- User input validated and sanitized before use?
- No SQL concatenation (use parameterized queries)?
- No secrets/credentials hardcoded?
- Auth checks on new endpoints?
- File paths validated (no path traversal)?
- HTML output escaped (no XSS)?

### Performance
- No N+1 queries or unbounded loops?
- Large data sets paginated?
- Database queries use indexes?
- No unnecessary re-renders (React) or recomputation?
- Caching considered where appropriate?

### Maintainability
- Functions do one thing?
- Names are descriptive (no `data`, `temp`, `result` without context)?
- No dead code or commented-out blocks?
- Complex logic has comments explaining *why* (not *what*)?
- Consistent with existing codebase patterns?

### Testing
- New code has tests?
- Tests cover edge cases, not just happy path?
- Tests are deterministic (no flaky timing, random data)?
- Mocks are reasonable (not mocking everything)?

## Complexity Analysis

```bash
# JavaScript/TypeScript — count function lengths
grep -rn "function\|=>" src/ | wc -l

# Find long functions (crude but useful)
awk '/function.*\{/{name=$0; count=0} /\{/{count++} /\}/{count--; if(count==0 && NR-start>50) print start": "name}' src/**/*.ts

# Python — check cyclomatic complexity
# Install: pip install radon
radon cc src/ -a -nb

# Show maintainability index
radon mi src/ -nb
```

## Leaving Review Comments

```bash
# Approve
gh pr review <PR_NUMBER> --approve --body "Looks good. Clean implementation."

# Request changes
gh pr review <PR_NUMBER> --request-changes --body "See inline comments — security concern in auth middleware."

# Comment without approve/reject
gh pr review <PR_NUMBER> --comment --body "A few suggestions, nothing blocking."

# Add inline comment on specific line
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments \
  -f body="This should use parameterized queries to prevent SQL injection." \
  -f path="src/db.ts" \
  -F line=42 \
  -f commit_id="$(gh pr view <PR_NUMBER> --json headRefOid -q .headRefOid)"
```

## Notes

- Review the *intent* first (PR description), then the *implementation* (diff).
- Prioritize: security issues > correctness bugs > performance > style.
- Be specific in feedback — "this is wrong" is unhelpful; "this allows SQL injection because..." is actionable.
- Check the test coverage — untested code is unreviewed code.
- Look at what's *not* in the diff — was something important missed?

---
name: clean-code
description: "Refactoring patterns, SOLID principles, code smell detection, and pragmatic coding standards."
metadata: {"thinkfleetbot":{"emoji":"✨","requires":{"anyBins":["git"]}}}
---

# Clean Code

Pragmatic refactoring patterns and coding standards. Not dogma — practical improvements.

## Code Smells to Fix

### Long functions (>30 lines)
Extract into named functions. The name documents intent better than a comment.

### Deep nesting (>3 levels)
Use early returns, guard clauses, or extract helper functions.

```javascript
// Bad
function process(user) {
  if (user) {
    if (user.active) {
      if (user.verified) {
        // actual logic
      }
    }
  }
}

// Good
function process(user) {
  if (!user) return;
  if (!user.active) return;
  if (!user.verified) return;
  // actual logic
}
```

### Magic numbers/strings
Extract to named constants.

### Duplicate code
If you copy-paste 3+ times, extract. Two occurrences are often fine.

### Dead code
Delete it. Git has history if you need it back.

## SOLID Principles (Practical Version)

- **Single Responsibility** — A function does one thing. A module handles one concern. If you can't name it simply, it does too much.
- **Open/Closed** — Extend with new code, don't modify working code. Use composition, interfaces, or strategy patterns.
- **Liskov Substitution** — Subtypes must work where parent types are expected. Don't override methods to throw "not implemented."
- **Interface Segregation** — Don't force clients to depend on methods they don't use. Smaller interfaces > fat interfaces.
- **Dependency Inversion** — Depend on abstractions, not concrete implementations. Pass dependencies in, don't create them inside.

## Refactoring Techniques

### Extract Function

```bash
# Find long functions
grep -rn "function\|=>\|def " src/ | awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -10
```

### Rename for clarity

```bash
# Find vague variable names
grep -rn "\bdata\b\|\btemp\b\|\bresult\b\|\binfo\b\|\bstuff\b" src/ --include="*.ts" --include="*.py" | head -20
```

### Remove dead code

```bash
# Find unused exports (TypeScript)
npx ts-unused-exports tsconfig.json

# Find unused functions (crude)
grep -rn "function " src/ --include="*.ts" -l | while read f; do
  grep -oP "function \K\w+" "$f" | while read fn; do
    count=$(grep -rn "\b$fn\b" src/ --include="*.ts" | wc -l)
    [ "$count" -le 1 ] && echo "Possibly unused: $fn in $f"
  done
done
```

### Simplify conditionals

Replace nested if/else with:
- Early returns
- Lookup tables/maps
- Polymorphism (if the condition is on type)

## Naming Conventions

- Functions: verb + noun (`getUser`, `validateEmail`, `parseResponse`)
- Booleans: `is`/`has`/`should` prefix (`isActive`, `hasPermission`)
- Collections: plural (`users`, `orderItems`)
- Avoid: `handle`, `process`, `manage` without specificity — they say nothing

## Notes

- Refactor in small, tested steps. Don't rewrite a whole file in one commit.
- Pragmatism over purity. Three similar lines are better than a premature abstraction.
- The best code needs no comments. But when logic isn't obvious, explain *why*, not *what*.
- Run tests after each refactoring step. If tests break, you changed behavior, not just structure.

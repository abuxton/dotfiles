# GitHub Copilot Instructions for This Repository

This document contains instructions for GitHub Copilot Chat when working in this repository.

## Repository Context

This is a personal dotfiles repository using the OpenSpec artifact-driven workflow system. The repository contains:

- **Core dotfiles**: Shell configurations (.bashrc, .zshrc), git config, editor settings
- **OpenSpec system**: Structured change management for repository improvements and features
- **Modular organization**: Features organized in `modules/`, initialization in `init/`

## Key Workflow: OpenSpec Changes

This repository uses OpenSpec for managing improvements and changes to dotfiles. When working on changes:

**Always reference [AGENTS.md](./AGENTS.md) for detailed guidance on OpenSpec workflows.**

### Quick Skill Reference

Use these skills when you see the pattern indicated:

| When User Says | Use Skill | Starting Point |
|---|---|---|
| "Create a new feature" or "Add ..." | `openspec-new-change` | Scaffolds change |
| "Work on this change" or "Implement ..." | `openspec-apply-change` | Implements tasks |
| "What should we build?" or "Let me think about ..." | `openspec-explore` | Discussion mode |
| "Keep going with this change" | `openspec-continue-change` | Next artifact |
| "Is this complete?" or "Verify ..." | `openspec-verify-change` | Quality check |
| "Done with this, move it" | `openspec-archive-change` | Finalize change |

### Pattern: Most Common Flow

```
[User describes work]
  ↓
openspec-new-change [create scaffolding]
  ↓
openspec-apply-change [implement work]
  ↓
openspec-verify-change [quality check]
  ↓
openspec-archive-change [save to history]
```

### Pattern: Complex Changes (Careful)

```
[User describes work]
  ↓
openspec-new-change [create scaffolding]
  ↓
review proposal, finalize requirements
  ↓
openspec-continue-change [specs artifact]
  ↓
review specs, finalize design
  ↓
openspec-continue-change [design artifact]
  ↓
review design, finalize tasks
  ↓
openspec-apply-change [implement]
  ↓
openspec-verify-change [validate]
  ↓
openspec-archive-change [save]
```

## Directory Structure You'll Encounter

```
/Users/abuxton/src/github/dotfiles/
├── AGENTS.md                          ← REFERENCE THIS for detailed OpenSpec guidance
├── copilot-instructions.md           ← You are here
├── openspec/
│   ├── config.yaml                   ← Schema configuration
│   ├── specs/                        ← Main specs (synced from changes)
│   └── changes/
│       ├── <active-changes>/         ← Work in progress
│       └── archive/                  ← Completed changes
├── modules/                          ← Feature modules
├── init/                             ← Initialization files
├── .bashrc, .zshrc, etc.            ← Dotfiles
└── [other directories]
```

## When Responding to User Requests

### 1. Identify the Type of Work

- **Planning/Exploration**: Use `openspec-explore`
- **Starting new work**: Use `openspec-new-change`
- **Implementing existing work**: Use `openspec-apply-change`
- **Quality/Completeness check**: Use `openspec-verify-change`
- **Finalizing work**: Use `openspec-archive-change`

### 2. Provide Context

In your response, make clear:
- Which OpenSpec skill you're using (if applicable)
- Where work is located (change name, file paths)
- Current status and what comes next
- Link to [AGENTS.md](./AGENTS.md) for detailed explanation

### 3. Example Response Template

```
I'll [skill description] for you.

**Using**: [Skill name]
**Change**: [change-name]
**Status**: [current state]

[Perform work]

**Next step**: [what comes next]

For detailed OpenSpec guidance, see [AGENTS.md](./AGENTS.md).
```

## Common Scenarios

### User: "Add support for Python virtual environments"

1. Ask clarifying questions about scope/approach
2. Use `openspec-new-change add-python-venv-support`
3. After scaffolding: could use `openspec-ff-change` to quickly create artifacts OR `openspec-continue-change` if need approval at each stage
4. Use `openspec-apply-change` to implement
5. Use `openspec-verify-change` to ensure completeness
6. Use `openspec-archive-change` when done

### User: "I'm not sure how to organize this feature"

1. Use `openspec-explore` to think through together
2. Once decided, use `openspec-new-change` to scaffold
3. Proceed from there

### User: "Let's implement the tasks for the auth system change"

1. If change exists: use `openspec-apply-change auth-system`
2. If change needs to be created: use `openspec-new-change auth-system` first

## Dotfiles-Specific Guidelines

### About This Codebase

- **Purpose**: Personal development environment configuration
- **Format**: Shell scripts, dotfiles, configuration files
- **Scope**: Often affects shell sessions, development tools, system settings
- **Testing**: Changes should be validated in actual shell session

### When Implementing Changes

1. **Find relevant file**: Usually in root or in modules/
2. **Understand structure**: Most files are sourced by .bashrc/.zshrc
3. **Test in place**: Suggest user reload shell to verify changes
4. **Document interactions**: Note if change affects other profiles (.extras, profile files, etc.)

### Common File Types

- `.*rc`, `*_profile`: Shell configuration
- `Makefile`, `*.mk`: Build/automation
- `*.yaml`, `*.json`: Configuration
- `init/`: Terminal/editor initialization (e.g., Sublime preferences)
- `scripts/bin/`: Executable utilities

## Integration with Repository Skills

This repository has OpenSpec skills configured in:
- `.opencode/skills/` - For OpenCode agent integration
- `.claude/skills/` - For Claude integration

These are synchronized with the guidance in AGENTS.md. When using OpenSpec skills, they follow the patterns and workflows described there.

## Getting Help

If you need detailed information about a specific workflow:

1. **First reference**: Always point to [AGENTS.md](./AGENTS.md)
2. **Specific skill help**: Direct to the skill documentation
3. **Uncertain about approach**: Use `openspec-explore` to think it through

## Best Practices for This Repository

1. **One change per feature/fix**: Keep changes focused
2. **Use descriptive change names**: Helps future self understand what was done
3. **Archive completed changes**: Keeps workspace tidy
4. **Reference artifacts in commits**: Link to the change documentation
5. **Test dotfile changes**: Shell sourcing can have subtle effects

## Extended Skills: Git Workflow Skill

In addition to OpenSpec workflow skills, this repository includes the **git-workflow skill** for Git version control best practices.

### When to Use `git-workflow` Skill

| When User Says | Use Skill |
|---|---|
| "Set up Git Flow" or "Branching strategy" | `git-workflow` |
| "How should I commit this?" or "Write commit message" | `git-workflow` |
| "Create a pull request" or "Review this PR" | `git-workflow` |
| "Configure GitHub Actions" or "Set up CI/CD" | `git-workflow` |
| "Merge conflicts" or "Resolve conflicts" | `git-workflow` |
| "Cherry-pick/rebase" or "Advanced git" | `git-workflow` |

### Git Workflow Quick Reference

**Conventional Commits**:
```
feat(scope): description       # New feature (MINOR version bump)
fix(scope): description        # Bug fix (PATCH version bump)
docs: description              # Documentation
ci: description                # CI configuration
```

**Branching**:
```
feature/TICKET-123-description
fix/TICKET-456-bug-name
release/1.2.0
hotfix/1.2.1-security-patch
```

**GitHub Flow**:
```bash
git checkout main && git pull
git checkout -b feature/my-feature
# make changes
git push -u origin HEAD && gh pr create
```

For full Git workflow guidance, see **Extended Skills** section in [AGENTS.md](./AGENTS.md#extended-skills).

---

## Quick Commands

Users can directly invoke OpenSpec skills with patterns like:

- `/opsx-new`: Start new change
- `/opsx-apply`: Apply/implement change
- `/opsx-verify`: Verify implementation
- `/opsx-archive`: Archive completed change

For full skill names and details, refer to [AGENTS.md](./AGENTS.md).

---

For comprehensive guidance on OpenSpec workflows regardless of agent used, see the canonical reference: **[AGENTS.md](./AGENTS.md)**

# AGENTS Agent-Agnostic Workflow Guide

This guide explains how to work with projects using OpenSpec, an artifact-driven workflow system. Use this regardless of which agent interface you're using (GitHub Copilot, OpenCode, Claude, or any other agent).

## Overview

Agents are expected to be used for a veriety of projects and we would like to establish a standardised approach utilising a mix of agent skills and Spec driven deployment in any development environment setup. Work is organized using **OpenSpec**, an artifact-driven workflow that structures development into well-defined phases:

1. **Proposal** — What you want to build and why
2. **Specs** — Technical requirements and acceptance criteria
3. **Design** — Architecture and implementation approach
4. **Tasks** — Concrete, actionable work items
5. **Implementation** — Code changes and deployment

This structure enables methodical progression from planning through completion.

### What Makes This Repository Agent-Aware?

- **Unified agent resources:** All skills, commands, prompts, and configuration in `~/.agents/`
- **Local development:** During development, resources are in `.agents/` within project
- **Deployable structure:** Copy entire `.agents/` directory to `~/.agents/` for system-wide access
- **Multiple agent types:** Supports Claude, Copilot, OpenCode, and custom integrations
- **Idempotent operations:** Safe for both autonomous and human decision-making
- **Clear phase documentation:** Bootstrap, setup, validation, optional features
- **Artifact-driven workflow:** OpenSpec structures complex changes consistently

### Key Concepts

- **Change**: A unit of work (feature, fix, refactor) organized in `openspec/changes/<change-name>/`
- **Artifact**: Structured documents that guide implementation (proposal, specs, design, tasks)
- **Schema**: A workflow template that defines which artifacts are needed and their sequence
- **Skills**: Agent-specific instructions for performing OpenSpec operations

## Available Skills

All skills are available in a unified location. The path depends on your context:

**Development (in project):**
- **Location:** `./.agents/skills/`
- **Commands:** `./.agents/commands/`
- **Prompts:** `./.agents/prompts/`
- **Configuration:** `./.agents/settings.json`

**Deployed (system-wide):**
- **Location:** `~/.agents/skills/`
- **Commands:** `~/.agents/commands/`
- **Prompts:** `~/.agents/prompts/`
- **Configuration:** `~/.agents/settings.json`

Access available skills:

```bash
# During development (in project)
ls ./.agents/skills/

# After deployment to home directory
ls ~/.agents/skills/
```

All skills follow the same conceptual pattern:

### 🎯 Primary Skills

#### `openspec-new-change`
**Start a new change with the artifact-driven workflow**

Use when: Creating a new feature, fix, or significant modification

Flow:
1. Optionally provide a change name (kebab-case) or describe what you want to build
2. System infers the schema (defaults to spec-driven)
3. Agent creates scaffolding at `openspec/changes/<name>/`
4. Agent shows first artifact template and stops for your input

#### `openspec-apply-change`
**Implement tasks from an existing change**

Use when: You have an active change and need to implement the work

Flow:
1. Provide an optional change name (auto-detects if only one active change)
2. Agent reads the change context (proposal, specs, design)
3. Agent displays current task status
4. Agent works through tasks, making code changes and marking them complete
5. On completion, suggests archiving

#### `openspec-continue-change`
**Create the next artifact in a change**

Use when: Current artifact(s) complete but design incomplete (e.g., proposal done, need specs)

Flow:
1. Provide the change name or context
2. Agent determines which artifacts are complete and which are ready to create
3. Agent shows the template for the next artifact
4. Agent waits for your input/approval before creating

#### `openspec-explore`
**Think through ideas before or during a change**

Use when: You need to explore/investigate before committing to a design

Flow:
1. Provide your question/problem/context
2. Agent acts as a thinking partner, discussing options
3. You can refine ideas before creating formal artifacts

#### `openspec-verify-change`
**Validate implementation matches artifacts**

Use when: Want to ensure implementation is complete and coherent before archiving

Flow:
1. Provide the change name
2. Agent reads all artifacts and current implementation
3. Agent checks: completeness, correctness, coherence
4. Agent reports findings and suggests fixes if needed

### 📦 Advanced Skills

#### `openspec-ff-change`
**Fast-forward through artifact creation**

Use when: You want to quickly create all needed artifacts rather than stepping through one-by-one

Flow:
1. Provide the change name
2. Agent rapidly creates proposal, specs, design - flowing to implementation tasks
3. Agent stops at implementation ready state

#### `openspec-archive-change`
**Archive a completed change to history**

Use when: Change implementation is complete and verified

Flow:
1. Provide the change name
2. Agent validates completion
3. Agent moves `openspec/changes/<name>` → `openspec/changes/archive/<name>`
4. Agent prepares summary

#### `openspec-bulk-archive-change`
**Archive multiple completed changes at once**

Use when: Several changes are ready to archive simultaneously

Flow:
1. List multiple change names or confirm all completion-ready changes
2. Agent archives all and provides summary

#### `openspec-sync-specs`
**Sync delta specs to main specs without archiving**

Use when: You want to update main spec files with changes from a delta spec

Flow:
1. Provide the change name
2. Agent merges delta specs into main specs
3. Change remains active (not archived)

#### `openspec-onboard`
**Guided onboarding for OpenSpec**

Use when: First time using OpenSpec or wanting to learn the workflow

Flow:
1. Agent walks through a complete workflow cycle
2. Creates real change in the repository
3. Demonstrates each step with narrative
4. You learn by doing

## Workflow Patterns

### Pattern 1: Step-by-Step (Careful)
Best for complex changes or when you need explicit approval at each stage:

```
new-change → show proposal template
→ you approve/revise
→ continue-change → show specs template
→ you approve/revise
→ continue-change → show design template
→ you approve/revise
→ continue-change → show tasks
→ apply-change → implement
→ verify-change
→ archive-change
```

### Pattern 2: Fast-Forward (Rapid)
Best for straightforward changes or when you know what you're building:

```
ff-change → creates all artifacts
→ apply-change → implement
→ verify-change
→ archive-change
```

### Pattern 3: Explore-First (Thoughtful)
Best for uncertain or complex changes needing investigation:

```
explore → discuss ideas/options
→ new-change → create scaffolding
→ continue-change → create artifact(s) informed by exploration
→ apply-change → implement
→ verify-change
→ archive-change
```

## Directory Structure

```
openspec/
├── config.yaml          # Schema definition and project context
├── specs/               # Main specification files (synced from changes)
├── changes/
│   ├── <change-name>/   # Active changes
│   │   ├── proposal.md  # Initial concept and rationale
│   │   ├── specs.md     # Technical specifications
│   │   ├── design.md    # Architecture and design decisions
│   │   └── tasks.md     # Implementation tasks (with checkboxes)
│   └── archive/         # Completed changes
│       └── <change-name>/
└── [any other schema files]
```

## Communication with Agents

### Providing Clear Input

- **Change name**: Use kebab-case (e.g., `add-user-auth`, `fix-memory-leak`)
- **Descriptions**: Be specific about what/why/who-benefits
- **Overrides**: Most skills accept optional parameters to specify which change to use

### Asking for Help

- If you're unsure what skill to use, describe what you're trying to do
  - Agent determines appropriate skill
  - If multiple options exist, agent asks you to choose

- If a task is unclear during implementation:
  - Say so - agent either clarifies or suggests updating the artifact

- If you want to switch patterns mid-change:
  - You can pause implementation
  - Use `explore` to think through a problem
  - Resume with `apply-change`

### Handling Conflicts or Issues

- **Change already exists**: Agent detects and suggests continuing instead of recreating
- **Missing dependencies**: Agent shows what artifact(s) must be created first
- **Implementation blockers**: Agent reports and waits for guidance

## Configuration

Agent configuration is managed in two places:

### OpenSpec Configuration

OpenSpec configuration lives in `openspec/config.yaml`:

```yaml
schema: spec-driven
# Additional context can be added here to inform AI agents
# Examples: tech stack, conventions, style guides, domain knowledge
```

### Agent Resources Configuration

Agent settings and environment configuration lives in `~/.agents/settings.json`:

```json
{
  "version": "1.0",
  "settings": {
    "// Comment": "Agent integration settings"
  },
  "skills": {},
  "commands": {},
  "prompts": {}
}
```

During development, this file is at `./.agents/settings.json` in your project. When deployed to your home directory, agents use `~/.agents/settings.json` to configure their behavior and available resources.

## Tips for Effective Use

1. **Use appropriate skill for your need** - don't force everything through apply-change
2. **Be specific in descriptions** - helps agents create better artifacts
3. **Use explore when uncertain** - better to think through first than fix later
4. **Review artifacts before impl** - agents draft, you guide
5. **Mark tasks as you complete them** - keeps progress clear
6. **Archive regularly** - keeps active changes focused

## Integration with Development

OpenSpec changes integrate with your Git workflow:

- Each change creates a directory you can reference
- Implementation happens in your regular codebase
- Artifacts serve as documentation and validation
- Archive keeps project history organized

When ready to commit work:

1. Run `verify-change` to ensure completeness
2. Update necessary documentation from change artifacts
3. Commit implementation
4. Archive the change
5. Sync specs if updating main specifications

## Agent Integration

All agents access the same unified resource structure in `~/.agents/`:

```
~/.agents/
├── skills/          # All OpenSpec and domain-specific skills
│   ├── openspec-new-change/
│   ├── openspec-apply-change/
│   ├── openspec-explore/
│   ├── openspec-verify-change/
│   ├── openspec-archive-change/
│   ├── openspec-bulk-archive-change/
│   ├── openspec-continue-change/
│   ├── openspec-ff-change/
│   ├── openspec-sync-specs/
│   ├── openspec-onboard/
│   ├── git-workflow/
│   ├── go-development-skill/
│   └── [other domain-specific skills]
│
├── commands/        # CLI command definitions for OpenCode and similar
│   └── [command definitions]
│
├── prompts/         # Prompt templates for Copilot and other agents
│   ├── opsx-new.prompt.md
│   ├── opsx-apply.prompt.md
│   ├── opsx-explore.prompt.md
│   └── [other prompts]
│
└── settings.json    # Configuration and integration settings
```

### How Different Agents Use `~/.agents/`

During development, agents reference `.agents/` in your project directory. After deployment, the same structure is available at `~/.agents/` for system-wide access.

**Claude AI:**
- Loads skills from `~/.agents/skills/`
- References prompts for guidance
- Uses settings.json for integration parameters

**GitHub Copilot:**
- Uses `~/.agents/prompts/` for custom prompt workflows
- Accesses skills from `~/.agents/skills/`
- References settings.json for VS Code integration

**OpenCode CLI:**
- Uses `~/.agents/commands/` for CLI operations
- Loads skills from `~/.agents/skills/`
- Reads settings.json for CLI configuration

**Custom Integrations:**
- Any agent can read from `~/.agents/skills/`
- Use `~/.agents/settings.json` for agent-specific configuration
- Reference `~/.agents/prompts/` for interaction patterns

## Common Workflows

### Adding a New Feature
1. `openspec-new-change add-feature-name`
2. Create proposal (what/why/acceptance criteria)
3. `openspec-continue-change add-feature-name` for specs
4. Create specs (API, UI, database changes)
5. `openspec-continue-change add-feature-name` for design
6. Create architecture/design decisions
7. `openspec-continue-change add-feature-name` for tasks
8. Create implementation tasks
9. `openspec-apply-change add-feature-name`
10. Implement, verify, archive

### Fixing a Bug
1. `openspec-explore` - discuss root cause and solution approaches
2. `openspec-new-change fix-bug-description`
3. `openspec-ff-change fix-bug-description` - create all artifacts rapidly
4. `openspec-apply-change fix-bug-description` - implement
5. `openspec-verify-change fix-bug-description` - ensure fix is complete
6. `openspec-archive-change fix-bug-description`

### Large Refactor
1. `openspec-new-change refactor-component-name`
2. Carefully build proposal + specs + design (use step-by-step pattern)
3. `openspec-apply-change refactor-component-name` - break into focused tasks
4. Implement methodically, pausing if design issues emerge
5. `openspec-verify-change refactor-component-name`
6. `openspec-archive-change refactor-component-name`

## Extended Skills

In addition to the OpenSpec workflow skills above, this repository includes skills for Git workflows and best practices.

### `git-workflow` 🔗 Git Workflow Skill

**Expert patterns for Git version control: branching, commits, collaboration, and CI/CD.**

Deployed from: [netresearch/git-workflow-skill](https://github.com/netresearch/git-workflow-skill)

#### Use When
- Setting up branching strategies (Git Flow, GitHub Flow, Trunk-based)
- Writing commit messages with Conventional Commits
- Creating or reviewing pull requests
- Handling merge conflicts
- Integrating Git with CI/CD systems (GitHub Actions, GitLab CI)
- Performing advanced Git operations (rebase, cherry-pick, bisect)
- Managing releases with semantic versioning

#### Expertise Areas
- **Branching Strategies**: Git Flow, GitHub Flow, Trunk-based development, release management
- **Commit Conventions**: Conventional Commits format, semantic versioning, commit best practices
- **Collaboration**: PR workflows, code review processes, merge strategies (merge, squash, rebase), conflict resolution
- **CI/CD Integration**: GitHub Actions, GitLab CI, branch protection rules, automated versioning
- **Advanced Operations**: Interactive rebase, cherry-picking, bisecting, reflog recovery, signed commits

#### Quick Reference: Conventional Commits
```
<type>[scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Breaking change**: Add `!` after type or `BREAKING CHANGE:` in footer

Example:
```
feat(auth): add OAuth2 support

Adds OpenID Connect provider integration for enterprise SSO.

Closes #123
```

#### Quick Reference: Branch Naming
```bash
feature/TICKET-123-description     # New features
fix/TICKET-456-bug-name            # Bug fixes
release/1.2.0                       # Release branches
hotfix/1.2.1-security-patch        # Emergency fixes
```

#### Quick Reference: GitHub Flow
```bash
git checkout main && git pull
git checkout -b feature/my-feature
# ... make changes ...
git add -p                          # Stage hunks interactively
git commit -m "feat: description"   # Conventional commit
git push -u origin HEAD
gh pr create
gh pr merge --squash                # Merge with squash strategy
```

#### Reference Files
When working on Git-related tasks, agents can load detailed references:
- `branching-strategies.md` - For choosing and implementing branching models
- `commit-conventions.md` - For writing clear, semantic commits
- `pull-request-workflow.md` - For PR structure, review processes, conflict resolution
- `ci-cd-integration.md` - For automating workflows with GitHub Actions and CI/CD
- `advanced-git.md` - For rebasing, cherry-picking, bisecting
- `github-releases.md` - For release management and immutable release patterns

#### Critical Note: Immutable Releases
GitHub **permanently blocks** tag names when releases are deleted. See `github-releases.md` for prevention and recovery patterns. Always get releases right the first time.

---

## Directory Reference

**Agent Resources (Deployed):**
- `~/.agents/skills/` - All OpenSpec and domain-specific skills
- `~/.agents/commands/` - CLI command definitions
- `~/.agents/prompts/` - Prompt templates for agent workflows
- `~/.agents/settings.json` - Agent configuration and integration settings

**Agent Resources (Development):**
- `.agents/skills/` - All OpenSpec and domain-specific skills
- `.agents/commands/` - CLI command definitions
- `.agents/prompts/` - Prompt templates for agent workflows
- `.agents/settings.json` - Agent configuration and integration settings

**Project Configuration:**
- `openspec/config.yaml` - Schema and project context
- `openspec/changes/` - Active and archived changes
- `openspec/specs/` - Specification files for the project

**Deployment:**
- Copy entire `.agents/` directory from project to `~/.agents/` for system-wide home-based access
- Agents automatically locate resources in `~/.agents/` on any system

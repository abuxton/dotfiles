 Copilot Instructions for Development Projects

**PRIMARY RESOURCE:** Before consulting this file, refer to `$HOME/AGENTS.md` for the authoritative workflow and skill reference.

This document provides guidance for GitHub Copilot when assisting with development using Spec Driven Development with openspec, OpenSpec workflow, and GitFlow version control conventions.
Regardless of language, with core support for Go development patterns, shell/bash scripting, and Infrastructure as Code. It should be used as a reference for Copilot to understand best practices for workflow, standards, and patterns when generating code or providing suggestions.

**Date:** 2026-02-25

---

## Table of Contents

1. [Go Development Standards](#go-development-standards)
2. [Local Development Skills](#local-development-skills)
3. [GitFlow Workflow (Quick Reference)](#gitflow-workflow-quick-reference)
4. [Code Quality & Testing](#code-quality--testing)
5. [Architecture Decision Records](#architecture-decision-records)
6. [Common Development Patterns](#common-development-patterns)

---

## Go Development Standards

### Core Principles

**Type Safety**
- **Avoid:** `interface{}` (use `any` instead), `sync.Map`, scattered type assertions, bare reflection
- **Prefer:** Generics `[T any]`, concrete types, compile-time verification
- **Modernize:** Run `go fix ./...` after Go upgrades to apply automated modernizers

**Error Handling Conventions**
- Error messages: lowercase, no punctuation (`errors.New("invalid input")`)
- Error wrapping: Always use `%w` for context (`fmt.Errorf("failed to process: %w", err)`)
- Naming conventions: `ID`, `URL`, `HTTP` (not `Id`, `Url`, `Http`)

**Consistency**
- One pattern per problem domain
- Match existing codebase patterns
- Refactor holistically or not at all

### Module & Version Management


- **Go version:** 1.23 or later (use `go 1.23` minimum in `go.mod`)
- **Toolchain:** `toolchain go1.23.3` (as of latest)
- **Dependency updates:** Use `go get -u ./...` before merges; run `go mod tidy` after any changes
- **Pre-merge checks:** Verify all tests pass with `go test -v ./...`, `go vet ./...`, and quality gates before PRs

### Code Organization

Organize code with clear separation of concerns:

```
project/
├── cmd/              # Command implementations (if CLI-based)
├── internal/         # Internal packages not for external use
├── pkg/              # Public packages for library use
├── test/             # Integration & e2e tests
├── main.go           # Entry point (if applicable)
├── go.mod            # Module definition
├── README.md         # Project overview
├── Makefile          # Build and test targets
└── .github/          # GitHub configuration
    ├── workflows/    # CI/CD pipelines
    └── (skills and prompts deployed to ~/.agents/)
```

**Note:** During development, skills and prompts are in `.github/skills/` and `.github/prompts/`. After deployment, they are available at `~/.agents/skills/` and `~/.agents/prompts/`.

### Naming Conventions

- **Packages:** use lowercase, no underscores or hyphens (e.g., `server`, `models`, `handlers`)
- **Functions:** CamelCase, exported functions start with uppercase (e.g., `GetState`, `ProcessData`)
- **Constants:** ALL_CAPS for exported, camelCase for unexported
- **Interfaces:** Suffix with "er" when describing capability (e.g., `Reader`, `Writer`, `Validator`)
- **Files:** use hyphens for multi-word names if clarity requires (e.g., `helper_logs.go`)

### Error Handling Patterns

- Always return errors explicitly; avoid `panic()` except during initialization
- Use descriptive error messages with context: `fmt.Errorf("failed to clone repo %s: %w", repoName, err)`
- Wrap errors using `%w` to preserve error chain and context
- Never ignore errors; use `_` only when explicitly documented
- Use type-safe error checking (avoid `errors.As` with bare variables; prefer context-aware patterns)

### Configuration Management

- Use **Viper** for config file & environment variable handling
- Support both TOML/YAML config files AND environment variable overrides
- Prefix env vars with your project name (e.g., `MYPROJECT_API_TOKEN`)
- Document all config keys in README and code comments

---

## Project Structure

### Key Packages

| Package | Purpose | Key Functions |
|---------|---------|---|
| `cmd/root` | CLI entry & root command | SetupViper, Execute |
| `cmd/copy` | Copy resources between orgs | CopyWorkspaces, CopyTeams, CopyVarSets |
| `cmd/core` | Core migration workflows | Clone, GetState, CreateWorkspaces, UploadStates, LinkVCS |
| `cmd/delete` | Deletion workflows | DeleteWorkspace, DeleteWorkspaceVCS |
| `cmd/helper` | Shared utilities | LoggingSetup, TimeFormatting, ViperConfig |
| `tfclient` | TFC/TFE API wrapping | DestinationOnlyClient, TFEClient |
| `vcsclients` | VCS provider abstractions | GitHub client, GitLab client (future: Bitbucket, Azure DevOps) |
| `output` | Result formatting | Write, TableFormat, JSONFormat |

### Test Structure

- Unit tests: Co-located with source files (e.g., `copy_test.go` with `copy.go`)
- Integration tests: Located in `test/` directory
- CI/CD: GitHub Actions workflows in `.github/workflows/`

---

## Local Development Skills

This repository includes development skills deployed to `~/.agents/` for both offline reference and CI/CD integration.

**Location during development:** `.github/skills/` and `.github/prompts/`
**Location after deployment:** `~/.agents/skills/` and `~/.agents/prompts/`

**Copilot should use the deployed location:** `~/.agents/`

### Available Skills

**Go Development Skill** (`~/.agents/skills/go-development-skill/`)
- **Metadata:** [go-development.md](~/.agents/skills/go-development-skill/SKILL.md)
- **Use cases:** CLI applications, job scheduling, Docker integration, LDAP clients, resilient services
- **Key patterns:** Type safety, generics, error handling, testing strategies, performance optimization

**Git Workflow Skill** (`~/.agents/skills/git-workflow/`)
- **Metadata:** [SKILL.md](~/.agents/skills/git-workflow/SKILL.md)
- **Use cases:** Branching strategies, conventional commits, PR workflows, merge strategies, CI/CD integration
- **Key patterns:** Git Flow, GitHub Flow, commit conventions, release management

### Reference Documents

**Go Development References** (`~/.agents/skills/go-development-skill/references/`):

| Document | Purpose |
|----------|----------|
| [architecture.md](~/.agents/skills/go-development-skill/references/architecture.md) | Package structure, config management, middleware chains |
| [api-design.md](~/.agents/skills/go-development-skill/references/api-design.md) | Functional options, builder patterns, extensible APIs |
| [testing.md](~/.agents/skills/go-development-skill/references/testing.md) | Table-driven tests, mocks, build tags, test structure |
| [logging.md](~/.agents/skills/go-development-skill/references/logging.md) | Structured logging with log/slog, migration from logrus |
| [resilience.md](~/.agents/skills/go-development-skill/references/resilience.md) | Retry logic, graceful shutdown, context propagation |
| [linting.md](~/.agents/skills/go-development-skill/references/linting.md) | golangci-lint v2 config, code quality, static analysis |
| [docker.md](~/.agents/skills/go-development-skill/references/docker.md) | Docker client patterns, buffer pooling |
| [cron-scheduling.md](~/.agents/skills/go-development-skill/references/cron-scheduling.md) | go-cron patterns, runtime updates, resilience |
| [modernization.md](~/.agents/skills/go-development-skill/references/modernization.md) | Go 1.26+ features, `go fix`, generics, utilities |
| [ldap.md](~/.agents/skills/go-development-skill/references/ldap.md) | LDAP/Active Directory integration |
| [makefile.md](~/.agents/skills/go-development-skill/references/makefile.md) | Standard Makefile interface for CI/CD |
| [fuzz-testing.md](~/.agents/skills/go-development-skill/references/fuzz-testing.md) | Go fuzzing patterns, security seeds |
| [mutation-testing.md](~/.agents/skills/go-development-skill/references/mutation-testing.md) | Gremlins configuration, test quality measurement |

**Git Workflow References** (`~/.agents/skills/git-workflow/references/`):

| Document | Purpose |
|----------|----------|
| [branching-strategies.md](~/.agents/skills/git-workflow/references/branching-strategies.md) | Git Flow, GitHub Flow, trunk-based development |
| [commit-conventions.md](~/.agents/skills/git-workflow/references/commit-conventions.md) | Conventional Commits format, semantic versioning |
| [pull-request-workflow.md](~/.agents/skills/git-workflow/references/pull-request-workflow.md) | PR creation, review, merge strategies, thread resolution |
| [ci-cd-integration.md](~/.agents/skills/git-workflow/references/ci-cd-integration.md) | GitHub Actions automation, branch protection |
| [advanced-git.md](~/.agents/skills/git-workflow/references/advanced-git.md) | Rebasing, cherry-picking, bisecting |
| [github-releases.md](~/.agents/skills/git-workflow/references/github-releases.md) | Release management, immutable releases |

**Reference:** For Git workflow details, see [~/.agents/skills/git-workflow/references/branching-strategies.md](~/.agents/skills/git-workflow/references/branching-strategies.md) and [pull-request-workflow.md](~/.agents/skills/git-workflow/references/pull-request-workflow.md).

### Accessing Deployed Skills

**In VS Code/Copilot context:** Reference skills from `~/.agents/skills/` for offline access and to keep guidance in sync.

**In CI/CD workflows:** Skills are available locally at `~/.agents/` without network dependencies, making builds faster and more reliable.

**For Copilot:**
- **PRIMARY:** Refer to `$HOME/AGENTS.md` first for workflow and skill guidance
- When asked about Go development patterns, refer to `~/.agents/skills/go-development-skill/references/` docs
- When asked about Git workflow, branching, commits, or PRs, refer to `~/.agents/skills/git-workflow/references/` docs

---

## GitFlow Workflow (Quick Reference)

For comprehensive Git workflow guidance, refer to the deployed git-workflow skill at `~/.agents/skills/git-workflow/`.

This guide uses **GitFlow** for version control and release management. Key commands and patterns are documented in deployed skill references.

### Branch Naming

- **Feature:** `feature/issue-number-short-description` (link to issue tracker)
- **Bugfix:** `bugfix/issue-number-short-description`
- **Release:** `release/<version>`
- **Hotfix:** `hotfix/<version>-issue`

**See also:** [~/.agents/skills/git-workflow/references/branching-strategies.md](~/.agents/skills/git-workflow/references/branching-strategies.md) for detailed conventions and alternative branching models.

### Pull Request Workflow

**Reference:** See [~/.agents/skills/git-workflow/references/pull-request-workflow.md](~/.agents/skills/git-workflow/references/pull-request-workflow.md) for comprehensive PR guidance.

**Standard Requirements:**
- **Title format:** Clear, descriptive title with issue reference (e.g., `#123: Add user authentication`)
- **Description:** Link related issues, explain *why* changes are needed, reference any architectural decisions
- **Commit convention:** Follow [Conventional Commits](~/.agents/skills/git-workflow/references/commit-conventions.md) format:
  ```
  type(scope): description

  Body: Detailed explanation.
  Footer: Fixes #issue-number
  ```
- **Reviews:** Approval from code owners
- **Checks:** All CI/CD must pass
- **Merge:** Squash commits for feature branches; preserve history for main branch

### Release & Hotfix Workflows

**Reference:** See [~/.agents/skills/git-workflow/references/github-releases.md](~/.agents/skills/git-workflow/references/github-releases.md) for release management best practices.

**Release Process:**
1. Create `release/<version>` from `develop`
2. Update version files and CHANGELOG.md
3. Merge to `main` with PR review
4. Tag with semantic version (e.g., `v1.0.0`)
5. Merge back to `develop` to sync version

**Hotfix Process:**
1. Create `hotfix/<version>-issue` from `main`
2. Apply fix and bump patch version
3. Merge to `main` with tag
4. Merge back to `develop`

---

## Code Quality & Testing

### Testing Requirements

All PRs must include relevant test coverage:

- **Unit tests:** Minimum 70% code coverage on new packages
- **Integration tests:** For complex workflows or multi-step operations
- **E2E tests:** For critical user-facing functionality

### Quality Gates & Test Execution

All code must pass these checks before PR submission:

```bash
# Run all tests with race detection
go test -race -v ./...

# Run with coverage report
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific test
go test -v -run TestExample ./path/to/package

# Comprehensive linting (must pass all)
golangci-lint run --timeout 5m
go vet ./...
staticcheck ./...
govulncheck ./...           # Vulnerability scanning

# Format and import organization
go fmt ./...
goimports -w .

# Run modernizers (after Go version upgrades)
go fix ./...

# Make targets
make test                   # Run all tests
make lint                   # Run linting
make build                  # Build binary
```

### Code Review Checklist

Before requesting review, ensure:

- [ ] All quality gates pass:
  - [ ] `golangci-lint run --timeout 5m`
  - [ ] `go vet ./...`
  - [ ] `staticcheck ./...`
  - [ ] `govulncheck ./...`
  - [ ] `go test -race -v ./...` (minimum 70% coverage on new packages)
- [ ] Error messages are lowercase with no punctuation
- [ ] All errors wrapped with `%w` for context preservation
- [ ] Generics used instead of `interface{}` where applicable
- [ ] Type assertions and reflection minimized
- [ ] Naming follows conventions: `ID`, `URL`, `HTTP` (not `Id`, `Url`, `Http`)
- [ ] Commit messages follow conventional format
- [ ] ADR or design documentation reference included (if applicable)
- [ ] No hardcoded credentials or secrets
- [ ] Comments explain *why*, not *what*
- [ ] One pattern per problem domain (consistency with codebase)

---

## Architecture Decision Records

### Using ADRs in Development

Architecture Decision Records (ADRs) document major design decisions and their rationale:

1. **Create ADRs for significant decisions:** Complex features, major refactors, API changes
2. **Reference in code:** Link to ADR documentation in PR descriptions and relevant code comments
3. **Track status:** Move ADRs through `Proposed` → `Accepted` → `Implemented` as work progresses
4. **Version with code:** Keep ADR records in your repository for historical context

**Reference:** See your project's ADR directory for decision history and patterns.

---

## Common Development Patterns

### Error Handling Pattern

Always provide context with type-safe error wrapping:

```go
func ProcessData(data []byte) error {
    result, err := Parse(data)
    if err != nil {  // lowercase, no punctuation
        return fmt.Errorf("failed to parse data: %w", err)
    }
    return nil
}
```

### Logging Pattern

Use structured logging with optional color output for CLI feedback:

```go
import (
    "log/slog"
    // optional: "github.com/fatih/color" for CLI color output
)

func Example() {
    slog.Info("operation completed", "duration", elapsed)
    slog.Error("operation failed", "error", err)
}
```

### Generics & Type Safety Pattern

Prefer concrete types and generics over `interface{}`:

```go
// Avoid
func Process(items []interface{}) {
    for _, item := range items {
        v := item.(string)  // Runtime type assertion
        // ...
    }
}

// Prefer
func Process[T any](items []T) {
    for _, item := range items {
        // Compile-time type safety
        // ...
    }
}
```

### Functional Options Pattern

Use functional options for flexible, extensible config:

```go
type ProcessConfig struct {
    Timeout time.Duration
    Retries int
    Auth    string
}

type Option func(*ProcessConfig)

func WithTimeout(d time.Duration) Option {
    return func(cfg *ProcessConfig) { cfg.Timeout = d }
}

func WithRetries(n int) Option {
    return func(cfg *ProcessConfig) { cfg.Retries = n }
}

func Process(data []byte, opts ...Option) error {
    cfg := &ProcessConfig{Timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(cfg)
    }
    // Implementation with config
}

// Usage
Process(myData,
    WithTimeout(60*time.Second),
    WithRetries(3))
```

---

## Continuous Integration & Quality Assurance

All PRs automatically run these checks (must pass all before merge):

1. **`test.yml`** - Unit and integration tests with race detection
2. **Linting suite:**
   - `golangci-lint` (v2 configuration)
   - `go vet`
   - `staticcheck`
   - `govulncheck` (vulnerability scanning)
3. **Coverage** - Minimum 70% on new packages
4. **Build validation** - Cross-platform binary compilation
5. **Code formatting** - `go fmt`, `goimports` consistency

**Before merging to `develop` or `main`:**
- All CI checks must pass
- Code review approval from project maintainers
- Squash commits for feature branches
- Include any ADR/design document references in PR body

**View workflows:** `.github/workflows/`

### Security & Enterprise Requirements

For comprehensive reviews, consider these related domains:
- **Security audit:** OWASP analysis, vulnerability patterns
- **Enterprise readiness:** OpenSSF Scorecard, SLSA compliance, supply chain security
- **GitHub project setup:** Branch protection rules, CI workflow validation

---

## Go Development References

When developing features, load these patterns as needed from `~/.agents/skills/go-development-skill/references/`:

| Pattern | Purpose | Example Use Case |
|---------|---------|---|
| **Logging** | Structured logging with `log/slog` | Adding diagnostic output to application operations |
| **Error Handling** | Error wrapping with context, type-safe checks | Implementing robust error propagation throughout codebase |
| **Testing** | Table-driven tests, interface mocks, build tags | Writing comprehensive test coverage for new features |
| **Linting** | `golangci-lint` v2 config, static analysis best practices | Ensuring code quality gates before PR submission |
| **API Design** | Functional options, builder patterns, extensible config | Designing flexible, composable APIs and interfaces |
| **Resilience** | Retry logic, graceful shutdown, context propagation | Implementing timeout and retry behavior for network operations |
| **Performance** | Memory pooling, garbage collection awareness | Optimizing code and resource usage |
| **Modernization** | Go 1.26+ features, `go fix`, generic functions | Applying modern Go patterns during refactors |

### Code Quality Benchmarks

- **Test Coverage:** Minimum 70% on new packages; aim for 85%+ on critical paths
- **Linting:** Zero warnings from golangci-lint, go vet, staticcheck
- **Vulnerability:** Zero warnings from govulncheck on Go dependencies
- **Performance:** Race detection on all concurrent code paths (`go test -race`)

**Reference:** See deployed skills at `~/.agents/skills/go-development-skill/` for comprehensive Go patterns. Original source: [netresearch/go-development-skill](https://github.com/netresearch/go-development-skill/tree/main/skills/go-development).

---

## Code Ownership & Review

Code ownership and review processes vary by project. Refer to `.github/CODEOWNERS` for your project's specific ownership and review requirements.

---

## Resources & References

- **Main README:** [README.md](README.md)
- **Primary Workflow Guide:** [$HOME/AGENTS.md]($HOME/AGENTS.md)
- **Go Standards:** https://golang.org/doc/effective_go
- **Deployed Git Workflow Skill:** [~/.agents/skills/git-workflow/SKILL.md](~/.agents/skills/git-workflow/SKILL.md)
- **Deployed Go Development Skill:** [~/.agents/skills/go-development-skill/SKILL.md](~/.agents/skills/go-development-skill/SKILL.md)
- **Git Workflow References:** [~/.agents/skills/git-workflow/references/](~/.agents/skills/git-workflow/references/)
- **Go Development References:** [~/.agents/skills/go-development-skill/references/](~/.agents/skills/go-development-skill/references/)
- **GitFlow Reference:** https://nvie.com/posts/a-successful-git-branching-model/

---

**Last Updated:** 2026-02-25


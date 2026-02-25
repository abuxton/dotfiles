 Instructions for TFM Development

**PRIMARY RESOURCE:** Before consulting this file, refer to `$HOME/AGENTS.md` for the authoritative workflow and skill reference.

This document provides guidance for GitHub Copilot when assisting with development of a project with Spec Driven Development utilizing openspec, speckit and GitFlow workflow conventions.
regardless of language but with consideration for IaC, shell/bash and Go development patterns. It should be used as a reference for Copilot to understand the project's coding standards, workflow, and best practices when generating code or providing suggestions.

**Date:** 2026-02-25

---

## Table of Contents

1. [Go Development Standards](#go-development-standards)
2. [Project Structure](#project-structure)
3. [Local Development Skills](#local-development-skills)
4. [GitFlow Workflow (Quick Reference)](#gitflow-workflow-quick-reference)
5. [Code Quality & Testing](#code-quality--testing)
6. [ADR-Driven Development](#adr-driven-development)
7. [Common Tasks & Patterns](#common-tasks--patterns)

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

```
tfm/
├── cmd/              # Command implementations (Cobra CLI structure)
│   ├── root.go       # Root command
│   ├── copy/         # Copy command & subpackages
│   ├── core/         # Core migration logic
│   ├── delete/       # Delete command
│   ├── generate/     # Code generation
│   ├── helper/       # Shared helpers
│   ├── list/         # Listing commands
│   ├── lock/         # Locking logic
│   ├── nuke/         # Cleanup commands
│   └── unlock/       # Unlock logic
├── output/           # Output formatting (writers)
├── tfclient/         # Terraform Cloud client wrappers
├── vcsclients/       # VCS provider clients (GitHub, GitLab)
├── version/          # Version management
├── ADR/              # Architecture Decision Records
├── test/             # Integration & e2e tests
├── main.go           # Entry point
├── go.mod            # Module definition
├── README.md         # Project overview
├── Makefile          # Build and test targets
└── .github/          # GitHub configuration
    ├── workflows/    # CI/CD pipelines
    ├── copilot-instructions.md  # This file
    ├── CODEOWNERS    # Code ownership
    └── (skills and prompts deployed to ~/.agents/)
```

**Note:** During development, skills and prompts are in `.github/skills/` and `.github/prompts/`. After deployment, they are available at `~/.agents/skills/` and `~/.agents/prompts/`.

### Naming Conventions

- **Packages:** use lowercase, no underscores or hyphens (e.g., `copy`, `vcsclients`)
- **Functions:** CamelCase, exported functions start with uppercase (e.g., `GetState`, `CloneRepo`)
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
- Prefix env vars with `TFM_` (e.g., `TFM_SRC_TFE_TOKEN`)
- Document all config keys in README and code comments

### VCS Abstraction

- New VCS provider support must be abstraction-friendly (see ADR #0006)
- All VCS operations should be provider-agnostic where possible
- Use a `vcs_type` config option to route between GitHub/GitLab/future providers

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

### TFM-Specific GitFlow Setup

This project uses **GitFlow** for version control and release management. Key commands and patterns are documented in local skill references; quick reference below for TFM specifics.

### Branch Naming for TFM

- **Feature:** `feature/<ADR-number>-<short-description>` (links ADRs to implementation)
- **Bugfix:** `bugfix/<issue-number>-<short-description>`
- **Release:** `release/<version>`
- **Hotfix:** `hotfix/<version>-<issue>`

**See also:** [~/.agents/skills/git-workflow/references/branching-strategies.md](~/.agents/skills/git-workflow/references/branching-strategies.md) for detailed conventions and alternative branching models.

### PR Workflow for TFM

**Reference:** See [~/.agents/skills/git-workflow/references/pull-request-workflow.md](~/.agents/skills/git-workflow/references/pull-request-workflow.md) for comprehensive PR guidance.

**TFM Requirements:**
- **Title format:** `[ADR #0003] Implement monorepo discovery` (include ADR reference)
- **Description:** Reference the ADR, link related issues, explain *why* changes are needed
- **Commit convention:** Follow [Conventional Commits](~/.agents/skills/git-workflow/references/commit-conventions.md) format:
  ```
  type(scope): description

  Body: Detailed explanation.
  Footer: Fixes #issue-number, References ADR #number
  ```
- **Reviews:** 1+ code owner approval (see `.github/CODEOWNERS`)
- **Checks:** All CI/CD must pass
- **Merge:** Squash commits to `develop`; preserve history for `main`

### Release & Hotfix Workflows

**Reference:** See [~/.agents/skills/git-workflow/references/github-releases.md](~/.agents/skills/git-workflow/references/github-releases.md) for release management best practices.

**TFM Release Process:**
1. Create `release/<version>` from `develop`
2. Update `version/version.go` and `CHANGELOG.md`
3. Merge to `main` with PR review
4. Tag with semantic version (e.g., `v0.9.0`)
5. Merge back to `develop` to sync version

**TFM Hotfix Process:**
1. Create `hotfix/<version>-<issue>` from `main`
2. Apply fix and bump patch version
3. Merge to `main` with tag
4. Merge back to `develop`

---

## Code Quality & Testing

### Testing Requirements

All PRs must include relevant test coverage:

- **Unit tests:** Minimum 70% code coverage on new packages
- **Integration tests:** For multi-step workflows (clone → create workspaces → upload state)
- **E2E tests:** In `test/` directory for full migration scenarios

### Quality Gates & Test Execution

All code must pass these checks before PR submission:

```bash
# Run all tests with race detection
go test -race -v ./...

# Run with coverage report
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific test
go test -v -run TestCloneRepos ./cmd/core

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
- [ ] ADR reference included (if applicable)
- [ ] No hardcoded credentials or secrets
- [ ] Comments explain *why*, not *what*
- [ ] One pattern per problem domain (consistency with codebase)

---

## ADR-Driven Development

### ADR Reference in Code

Every feature PR should reference its driving ADR:

1. **Use ADR number in branch name:** `feature/0003-monorepo-discovery`
2. **Reference ADR in commits:** `References ADR #0003`
3. **Link ADR in PR description:** Include ADR URL or number
4. **Update ADR status:** Move status from `Proposed` → `Accepted` → `Implemented` as work progresses

### Active ADRs

| ADR | Title | Status | Primary Goal |
|-----|-------|--------|---|
| 0001 | Initial ADR | Foundational | Go/Cobra/Viper decision |
| 0003 | CE to TFC Migration | Proposed | Core migration workflow |
| 0004 | CLI-Driven Workspaces | Accepted | Automate `cloud {}` block insertion |
| 0005 | Variables Migration | Accepted | Terraform variable file handling |
| 0006 | GitLab VCS Support | Draft | Multi-VCS abstraction |

**Reference:** See [ADR/next-steps.md](../../ADR/next-steps.md) for current implementation roadmap.

---

## Common Tasks & Patterns

### Adding a New VCS Provider (e.g., Bitbucket after GitLab)

1. **Create `vcsclients/bitbucket.go`** following the GitLab pattern:
   ```go
   package vcsclients

   import (
       "context"
       bbClient "github.com/bitbucket/library-go"
   )

   type BitbucketContext struct {
       Client context.Context
       Token  string
       // ...other fields
   }

   func NewBitbucketClient(token, workspace string) (*BitbucketContext, error) {
       // Implementation
   }
   ```

2. **Refactor `cmd/core/clone.go`** to be provider-agnostic:
   ```go
   func CloneRepo(vcsType string, repoName string) error {
       switch vcsType {
       case "github":
           return cloneFromGitHub(repoName)
       case "gitlab":
           return cloneFromGitLab(repoName)
       case "bitbucket":
           return cloneFromBitbucket(repoName)
       default:
           return fmt.Errorf("unsupported VCS type: %s", vcsType)
       }
   }
   ```

3. **Update config validation** in `cmd/helper/helper_viper.go`:
   ```go
   func ValidateVCSConfig(vcsType string, config *Config) error {
       switch vcsType {
       case "gitlab":
           if config.GitLabToken == "" || config.GitLabGroup == "" {
               return errors.New("gitlab_token and gitlab_group required")
           }
       case "bitbucket":
           if config.BitbucketToken == "" || config.BitbucketWorkspace == "" {
               return errors.New("bitbucket_token and bitbucket_workspace required")
           }
       }
       return nil
   }
   ```

4. **Add tests** in `vcsclients/bitbucket_test.go`

5. **Reference ADR:** Link to multi-VCS support ADR in PR

### Adding a New Command

1. **Create `cmd/<command>/<command>.go`** with a `NewCommand()` function:
   ```go
   package example

   import "github.com/spf13/cobra"

   func NewCommand() *cobra.Command {
       cmd := &cobra.Command{
           Use:   "example",
           Short: "Example command",
           Long:  "Longer description",
           RunE:  RunCommand,
       }
       cmd.Flags().StringP("flag", "f", "default", "Flag description")
       return cmd
   }

   func RunCommand(cmd *cobra.Command, args []string) error {
       // Implementation
       return nil
   }
   ```

2. **Register in `cmd/root.go`:**
   ```go
   import "github.com/hashicorp-services/tfm/cmd/example"

   func init() {
       rootCmd.AddCommand(example.NewCommand())
   }
   ```

3. **Add tests** in `cmd/example/example_test.go`

### Error Handling Pattern

Always provide context with type-safe error wrapping:

```go
func CloneRepo(repoURL, targetPath string) error {
    client, err := git.PlainClone(targetPath, false, &git.CloneOptions{
        URL: repoURL,
    })
    if err != nil {  // lowercase, no punctuation
        return fmt.Errorf("failed to clone repository %s to %s: %w", repoURL, targetPath, err)
    }
    return nil
}
```

### Logging Pattern

Use structured logging with color output for CLI feedback:

```go
import (
    "log/slog"
    "github.com/fatih/color"
)

func Example() {
    color.Green("✓ Operation succeeded")
    color.Yellow("⚠ Warning message")
    color.Red("✗ Error message")
    slog.Info("operation completed", "duration", elapsed)
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
type CloneConfig struct {
    Timeout time.Duration
    Retries int
    Auth    string
}

type Option func(*CloneConfig)

func WithTimeout(d time.Duration) Option {
    return func(cfg *CloneConfig) { cfg.Timeout = d }
}

func WithRetries(n int) Option {
    return func(cfg *CloneConfig) { cfg.Retries = n }
}

func Clone(url string, opts ...Option) error {
    cfg := &CloneConfig{Timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(cfg)
    }
    // Implementation with config
}

// Usage
Clone("https://example.com/repo.git",
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

**Before merging to `develop`:**
- All CI checks must pass
- Code review approval from code owner
- Squash commits for feature branches
- Include ADR reference in PR body and commits

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
| **Architecture & Design** | Package structure, config management, middleware chains | Designing new command packages or refactoring VCS clients |
| **Logging** | Structured logging with `log/slog`, color CLI feedback | Adding diagnostic output to migration commands |
| **Error Handling** | Error wrapping with context, type-safe checks | Implementing robust error propagation in copied resources |
| **Testing** | Table-driven tests, interface mocks, build tags | Writing comprehensive test coverage for new features |
| **Linting** | `golangci-lint` v2 config, static analysis best practices | Ensuring code quality gates before PR submission |
| **API Design** | Functional options, builder patterns, extensible config | Designing CLI flags and config file options |
| **Resilience** | Retry logic, graceful shutdown, context propagation | Implementing timeout and retry behavior for VCS/TFC API calls |
| **Performance** | Memory pooling, garbage collection awareness | Optimizing large-scale copy operations |
| **Modernization** | Go 1.26+ features, `go fix`, generic functions | Applying modern Go patterns during refactors |

### Code Quality Benchmarks

- **Test Coverage:** Minimum 70% on new packages; aim for 85%+ on critical paths
- **Linting:** Zero warnings from golangci-lint, go vet, staticcheck
- **Vulnerability:** Zero warnings from govulncheck on Go dependencies
- **Performance:** Race detection on all concurrent code paths (`go test -race`)

**Reference:** See deployed skills at `~/.agents/skills/go-development-skill/` for comprehensive Go patterns. Original source: [netresearch/go-development-skill](https://github.com/netresearch/go-development-skill/tree/main/skills/go-development).

---

## Code Ownership & Review

See `.github/CODEOWNERS` for specific package ownership. Key maintainers:

- **Core migration logic:** Core team
- **VCS integrations:** VCS team
- **CLI/UX:** CLI team
- **Testing:** QA + core teams

---

## Resources & References

- **Main README:** [README.md](.README.md)
- **Primary Workflow Guide:** [$HOME/AGENTS.md]($HOME/AGENTS.md)
- **Architecture Decisions:** [ADR/](./doc/ADR/)
- **Implementation Status:** [ADR/next-steps.md](./doc/ADR/next-steps.md)
- **Terraform Documentation:** https://developer.hashicorp.com/terraform
- **Go Standards:** https://golang.org/doc/effective_go
- **Cobra CLI Framework:** https://cobra.dev
- **Deployed Git Workflow Skill:** [~/.agents/skills/git-workflow/SKILL.md](~/.agents/skills/git-workflow/SKILL.md)
- **Deployed Go Development Skill:** [~/.agents/skills/go-development-skill/SKILL.md](~/.agents/skills/go-development-skill/SKILL.md)
- **Git Workflow References:** [~/.agents/skills/git-workflow/references/](~/.agents/skills/git-workflow/references/)
- **Go Development References:** [~/.agents/skills/go-development-skill/references/](~/.agents/skills/go-development-skill/references/)
- **GitFlow Reference:** https://nvie.com/posts/a-successful-git-branching-model/

---

**Last Updated:** 2026-02-25


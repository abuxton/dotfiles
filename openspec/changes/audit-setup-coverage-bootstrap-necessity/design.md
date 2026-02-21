# Design: Audit setup.sh Coverage & Bootstrap.sh Necessity

## Context

The dotfiles repository has evolved over time with two deployment scripts that may have overlapping or unclear responsibilities. Currently:

- **setup.sh**: 400+ lines with 9 responsibilities (directories, secrets, symlinks, profiles, functions, validation, Homebrew)
- **bootstrap.sh**: 169 lines with 4-5 responsibilities (git pull, oh-my-zsh, rsync, npm globals, shell reload)

These scripts lack comprehensive documentation of their coverage, making it difficult for users to understand:
1. What files are deployed by which script
2. Whether both scripts are necessary or if one could be deprecated
3. What files in the repo are NOT deployed anywhere
4. When to run which script (first time vs updates)

The audit must produce actionable outputs (coverage matrix, workflow decisions) rather than just analysis.

## Goals / Non-Goals

**Goals:**
- Create complete file deployment matrix showing: every file/dir → what script handles it → why
- Determine if bootstrap.sh is unique or redundant vs setup.sh
- Identify any unmapped files that should probably be deployed
- Produce clear user documentation about when to run each script
- Establish a reference point for future deployment improvements
- Clarify shell integration (bash vs zsh, profile loading order)

**Non-Goals:**
- Refactoring or consolidating scripts yet (just analyze and document first)
- Adding new deployment capabilities (just map existing coverage)
- Changing the deployment approach (symlinks vs rsync, etc.)
- Optimizing performance or adding features (focus on clarity)

## Decisions

### Decision 1: Audit Approach - Line-by-line script analysis
**Choice**: Parse setup.sh and bootstrap.sh line-by-line to extract exact responsibilities
**Rationale**: Generic descriptions could miss nuances; line-by-line ensures completeness
**Alternatives Considered**:
- Run scripts in verbose mode and watch what happens (less reliable, harder to analyze)
- Interview maintainer about intent (good for context, but less objective)
- Combination of above (time-consuming but most reliable)

**Approach**:
- Use grep to identify all deployment patterns in both scripts
- Document each with: line number, operation type (mkdir, ln, cp, etc.), source, target, conditions
- Cross-reference with what files actually exist in repo

### Decision 2: Completeness Matrix Format
**Choice**: Create table with columns: filename | type | setup.sh? | bootstrap.sh? | other? | status | recommendation
**Rationale**: Visual matrix makes gaps obvious, supports multiple-handler detection
**Alternatives Considered**:
- Narrative descriptions (easier to read, harder to analyze)
- Simple checklist (less detailed)
- Script-generated report (depends on having a tool)

**Approach**:
- Create shell script to enumerate all root files
- Manually cross-reference against setup.sh and bootstrap.sh handling
- Produce markdown table for clarity

### Decision 3: Special Directory Deep-Dive
**Choice**: Manually examine init/, modules/, bin/, .functions/, .functions.d/, .zsh.d/
**Rationale**: These directories have unclear purpose; require investigation to understand deployment strategy
**Alternatives Considered**:
- Skip them as "probably config" (would miss important gaps)
- Ask maintainer (valid but time-consuming)
- Look at how other dotfiles repos handle them (good for context)

**Approach**:
- List contents of each
- Examine file meanings (comments, extensions, naming patterns)
- Check if they're referenced in any deployment scripts
- Document findings and deployment recommendation for each

### Decision 4: Bootstrap.sh Necessity - Honest Assessment
**Choice**: Classify each bootstrap.sh operation as unique/redundant and recommend consolidation strategy
**Rationale**: Can't make consolidation decision without clear classification
**Alternatives Considered**:
- Assume it's needed forever (avoids difficult conversations)
- Immediately deprecate it (risky without analysis)
- Leave it ambiguous (frustrates users)

**Approach**:
- Classify each operation: FIRST_TIME_ONLY (needs bootstrap) vs IDEMPOTENT (setup.sh could handle)
- Identify true conflicts (e.g., rsync copies then symlinks overwrites)
- Assess: can this be merged into setup.sh safely or is bootstrap truly necessary?
- Three possible outcomes: KEEP_BOTH (with clear docs) | MERGE_INTO_SETUP | DEPRECATE_BOOTSTRAP

### Decision 5: Workflow Documentation - Decision Tree Format
**Choice**: Create flowchart/decision tree showing "if X then run Y script"
**Rationale**: Users don't remember rules; visual flow is faster to follow
**Alternatives Considered**:
- Prose documentation (can be ambiguous)
- Just examples ("here are 5 scenarios") - incomplete
- Machine-readable format (overkill for this scale)

**Approach**:
- Identify decision points: first-time? existing setup? just updating?
- Map each path to required scripts
- Add escape hatches: "when in doubt, run setup.sh (it's safe)"

### Decision 6: Profile System Deep-Dive
**Choice**: Verify all 22 .*_profile files are deployed and understand load order
**Rationale**: Profile system is new and critical to language manager initialization
**Alternatives Considered**:
- Assume it's working (risky; could miss issues)
- Quick spot-check (insufficient coverage)
- Full verification with testing (comprehensive but time-consuming)

**Approach**:
- List all .*_profile files in repo (should be 22)
- Verify each is symlinked by setup.sh Step 3c
- Check .bash_profile and .zshrc for explicit sourcing loop
- Document load order and why it matters (language managers before clouds)

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| Missed edge cases in file deployment | Medium | Users don't deploy something important | Comprehensive grep + manual spot-check |
| Bootstrap.sh analysis reveals true complexity | Low | Consolidation harder than expected | Document clearly and recommend KEEP_BOTH if needed |
| Unmapped files exist but purpose unclear | Medium | Unclear recommendations | Mark as "requires clarification" and flag for follow-up |
| Dry-run feature doesn't match actual | Low | Documentation becomes wrong | Test setup.sh --dry-run and compare with actual |
| Bash-only or zsh-only profiles missed | Low | Some shells don't work | Test both shells independently |

## Migration Plan

This is an audit/documentation change, not a deployment change. No migration needed. Outputs:
1. Audit report in openspec/changes/audit-setup-coverage-bootstrap-necessity/reports/
2. Coverage matrix in docs/DEPLOYMENT_MATRIX.md
3. Decision tree in docs/DEPLOYMENT_WORKFLOW.md
4. Recommendations in docs/BOOTSTRAP_CONSOLIDATION.md
5. Update to README.md and CONTRIBUTING.md if recommendations warrant
6. Archive change when complete

## Open Questions

1. **Should bootstrap.sh be kept around for first-time users, or is the repo being cloned evidence they already have git?**
   - Current assumption: git pre-exists, so bootstrap.sh's git pull is just an update command
   - Question: do first-time users need oh-my-zsh setup? Or is that already installed on typical macOS?

2. **What's the intended relationship between .functions and .functions.d?**
   - .functions appears to be a monolithic file
   - .functions.d appears to be module directory
   - Are both used or is one legacy?

3. **Are init/ files (terminal themes, Sublime settings, etc.) meant to be manually copied or auto-deployed?**
   - Current: no deployment mechanism
   - Question: should they be symlinked to appropriate locations?

4. **Why does bootstrap.sh use rsync instead of symlinks?**
   - rsync copies files, setup.sh then symlinks them - who owns them?
   - Question: is this intentional two-step or could setup.sh alone work?

5. **Are there any profiles or files that should NOT be auto-deployed (local-only configs)?**
   - Current assumption: all .*_profile files get deployed
   - Question: should some profiles be gitignored (like .local_profile)?

## Implementation Approach

1. **Phase 1: Extract setup.sh coverage (3-4 hours)**
   - Use grep to find all file operations
   - Create line-by-line documentation
   - Verify against actual file system

2. **Phase 2: Extract bootstrap.sh coverage (1-2 hours)**
   - Map each function to responsibilities
   - Classify as unique vs redundant

3. **Phase 3: Root file inventory (1-2 hours)**
   - List all ~80 root items
   - Categorize by type
   - Cross-reference against scripts

4. **Phase 4: Special directories (1 hour)**
   - Deep dive: init/, modules/, bin/, .functions*/, .zsh.d/
   - Document findings

5. **Phase 5: Generate reports (2-3 hours)**
   - Build coverage matrices
   - Create workflow decision tree
   - Write consolidation recommendation

6. **Phase 6: Documentation (2-3 hours)**
   - Update README with workflow guidance
   - Create DEPLOYMENT_WORKFLOW.md quick reference
   - Update CONTRIBUTING.md guidance

**Total estimated effort: 10-15 hours of detailed analysis**

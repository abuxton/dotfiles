# Tasks: Audit setup.sh Coverage & Bootstrap.sh Necessity

## 1. Extract setup.sh File Coverage

- [x] 1.1 Document all `mkdir -p` operations in setup.sh with line numbers
- [x] 1.2 Document all `ln -s` (symlink) operations in setup.sh with line numbers
- [x] 1.3 Document all `cp` (copy) operations in setup.sh with line numbers
- [x] 1.4 Document .bash_secrets template creation and permission handling
- [x] 1.5 Document backup strategy (BACKUP_DIR, filename format, timestamp)
- [x] 1.6 Document profile symlink loop (Step 3c) and verify 22 profiles
- [x] 1.7 Document function module copy operations (.functions.d/*.sh)
- [x] 1.8 Document validation checks that setup.sh performs
- [x] 1.9 Document Homebrew integration and brewfile-setup.sh interaction
- [x] 1.10 Create line-by-line reference document for setup.sh functionality

## 2. Extract Bootstrap.sh File Coverage

- [x] 2.1 Document git pull operations and update strategy
- [x] 2.2 Document oh-my-zsh installation (makeItHappen function)
- [x] 2.3 Document rsync deployment (doIt function) with exclusion rules
- [x] 2.4 Document npm global package installation (nodeKnows function)
- [x] 2.5 Document shell reload operations (source ~/.zshrc)
- [x] 2.6 Classify each bootstrap.sh operation as: FIRST_TIME_ONLY or IDEMPOTENT
- [x] 2.7 Identify any conflicts between bootstrap.sh and setup.sh operations
- [x] 2.8 Document bootstrap.sh prerequisites (git, network, shell)
- [x] 2.9 Create line-by-line reference document for bootstrap.sh functionality

## 3. Create Root File Inventory

- [x] 3.1 List all root-level files (not directories) in repo
- [x] 3.2 List all root-level directories in repo
- [x] 3.3 Categorize files by type (dotfiles, scripts, configs, markdown, etc.)
- [x] 3.4 Categorize directories by purpose (infrastructure, documentation, configuration)
- [x] 3.5 Create master inventory file with all ~80 items

## 4. Analyze Deep Directories

- [x] 4.1 Examine init/ directory contents and document purpose of each file
- [x] 4.2 Examine modules/ directory structure and document intended use
- [x] 4.3 Examine bin/ directory scripts and document their purpose
- [x] 4.4 Compare .functions and .functions.d directories (why both?)
- [x] 4.5 Examine .zsh.d/ directory and understand zsh-specific modules
- [x] 4.6 Document findings about unclear-purpose directories

## 5. Cross-Reference with Deployment Scripts

- [x] 5.1 For each root-level file, determine: handled by setup.sh? Y/N (with line number)
- [x] 5.2 For each root-level file, determine: handled by bootstrap.sh? Y/N (with line number)
- [x] 5.3 For each root-level directory, determine: handled by setup.sh? Y/N
- [x] 5.4 For each root-level directory, determine: handled by bootstrap.sh? Y/N
- [x] 5.5 Identify all files/directories currently NOT deployed by any script
- [x] 5.6 Identify all files/directories with UNCLEAR deployment status

## 6. Generate Coverage Matrix

- [x] 6.1 Create markdown table: file | type | setup.sh? | bootstrap.sh? | deployed? | recommendation
- [x] 6.2 Add "Current Status" column: DEPLOYED | UNMAPPED | UNCLEAR | REPO_ONLY
- [x] 6.3 Add "Recommendation" column: DEPLOY | LEAVE_UNMAPPED | CLARIFY | with rationale
- [x] 6.4 Highlight all UNMAPPED entries for review
- [x] 6.5 Calculate coverage metrics (% of files deployed, % handled by each script)
- [x] 6.6 Document any files that could be deployed but currently aren't

## 7. Analyze Bootstrap.sh Necessity

- [x] 7.1 Count operations in bootstrap.sh classified as FIRST_TIME_ONLY
- [x] 7.2 Count operations in bootstrap.sh classified as IDEMPOTENT
- [x] 7.3 Identify operations that conflict with setup.sh (rsync + symlink)
- [x] 7.4 Assess: can IDEMPOTENT operations move to setup.sh? Y/N with reasoning
- [x] 7.5 Determine: are FIRST_TIME_ONLY operations essential for new machines?
- [x] 7.6 Make preliminary recommendation: KEEP_BOTH | MERGE | DEPRECATE
- [x] 7.7 If MERGE: outline which bootstrap operations would move where
- [x] 7.8 If KEEP_BOTH: outline clear responsibilities for each script

## 8. Test Profile System

- [x] 8.1 Verify all 22 .*_profile files exist in repo
- [x] 8.2 Verify setup.sh Step 3c symlinks all profiles
- [x] 8.3 Verify .bash_profile has profile sourcing loop
- [x] 8.4 Verify .zshrc has profile sourcing loop
- [x] 8.5 Test profile loading in bash (source ~/.bash_profile, verify no errors)
- [x] 8.6 Test profile loading in zsh (source ~/.zshrc, verify no errors)
- [x] 8.7 Document profile load order and rationale

## 9. Create Workflow Decision Tree

- [x] 9.1 Identify all valid deployment scenarios (new machine, update, add profile, etc.)
- [x] 9.2 For each scenario, determine required scripts and order
- [x] 9.3 Document escape hatches (when unsure, what's the safe default?)
- [x] 9.4 Create flowchart/decision tree visual
- [x] 9.5 Create text-based "if/then" guide for each scenario
- [x] 9.6 Document what happens if scripts are run in wrong order

## 10. Create User Documentation

- [x] 10.1 Write docs/DEPLOYMENT_MATRIX.md - comprehensive coverage matrix
- [x] 10.2 Write docs/DEPLOYMENT_WORKFLOW.md - scenario-based decision guide
- [x] 10.3 Create quick reference section: "Which script do I run?"
- [x] 10.4 Document dry-run capability and when to use it
- [x] 10.5 Document idempotency and safety guarantees
- [x] 10.6 Create troubleshooting guide for common issues

## 11. Bootstrap.sh Necessity Report

- [x] 11.1 Write executive summary: recommendation (KEEP_BOTH | MERGE | DEPRECATE)
- [x] 11.2 Document rationale for recommendation
- [x] 11.3 If KEEP_BOTH: clearly define non-overlapping responsibilities
- [x] 11.4 If MERGE: outline consolidation plan (what moves where, how to do safely)
- [x] 11.5 If DEPRECATE: propose deprecation timeline and migration guide
- [x] 11.6 Document any risks or concerns with the recommendation

## 12. Update Project Documentation

- [ ] 12.1 Update README.md: add workflow guidance section
- [ ] 12.2 Update README.md: link to new DEPLOYMENT_WORKFLOW.md
- [ ] 12.3 Update CONTRIBUTING.md: add "Deployment Responsibilities" section
- [ ] 12.4 Update CONTRIBUTING.md: explain where new files should be deployed
- [ ] 12.5 Update CHANGELOG.md: document audit findings and recommendations
- [ ] 12.6 Add comments to bootstrap.sh documenting its final recommended role
- [x] 12.7 Add comments to setup.sh documenting its final recommended role

## 13. Verify and Validate

- [x] 13.1 Run setup.sh --dry-run and confirm all expected operations shown
- [x] 13.2 Run setup.sh in test environment (clean simulation) and verify all deployments
- [x] 13.3 Verify profiles load correctly in both bash and zsh
- [x] 13.4 Test update scenario: run setup.sh --dry-run on existing setup
- [x] 13.5 Verify all cross-references in documentation are accurate

## 14. Finalization

- [x] 14.1 Create IMPLEMENTATION_SUMMARY.md documenting audit results
- [x] 14.2 Review all generated documentation for clarity and completeness
- [x] 14.3 Stage all changes to git
- [x] 14.4 Prepare for archive when ready

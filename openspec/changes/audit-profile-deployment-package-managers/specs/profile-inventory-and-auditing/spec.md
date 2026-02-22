## ADDED Requirements

### Requirement: Generate complete profile inventory document
The system SHALL create a comprehensive inventory document listing all `.*_profile` files with their purpose, source file locations, and dependencies.

#### Scenario: Inventory generation
- **WHEN** audit runs
- **THEN** a profile-inventory.md is created at openspec/changes/audit-profile-deployment-package-managers/doco/PROFILE_INVENTORY.md

#### Scenario: Profile documentation includes metadata
- **WHEN** audit documents .aws_profile
- **THEN** inventory includes: name, location, lines of code, dependencies (aws cli), last modified date

### Requirement: Identify cross-profile dependencies
The system SHALL detect and document when one profile sources, references, or depends on variables/functions from another profile.

#### Scenario: Document brew_profile dependency on brew
- **WHEN** auditing .brew_profile
- **THEN** system documents that it requires Homebrew to be installed and available in PATH

#### Scenario: Document python_profile dependency on pyenv
- **WHEN** auditing .python_profile
- **THEN** system notes eval "$(pyenv init --path)" and documents pyenv as a prerequisite

### Requirement: Categorize profiles by concern/domain
The system SHALL group profiles into logical categories (language tools, cloud platforms, package managers, development tools, etc.).

#### Scenario: Language profiles grouped together
- **WHEN** inventory is generated
- **THEN** profiles are grouped: "Language Tools: .python_profile, .ruby_profile, .rust_profile, .go_profile"

#### Scenario: Cloud platforms grouped
- **WHEN** inventory is generated
- **THEN** profiles are grouped: "Cloud Platforms: .azure_profile, .aws_profile, .gcloud_profile"

### Requirement: Flag problematic patterns and conflicts
The system SHALL identify and report profile patterns that could cause issues (duplicates, conflicts, unused variables, etc.).

#### Scenario: Detect duplicate PATH exports
- **WHEN** scanning profiles
- **THEN** system reports: ".aws_profile and .azure_profile both modify PATH - verify order"

#### Scenario: Detect unused profiles
- **WHEN** auditing profile usage
- **THEN** system reports which profiles are not sourced by any shell configuration

### Requirement: Create audit report with recommendations
The system SHALL generate a structured audit report with findings and actionable recommendations for cleanup/consolidation.

#### Scenario: Audit report generation
- **WHEN** audit completes
- **THEN** a detailed audit-report.md is created with sections: Summary, Profile Inventory, Dependencies, Issues Found, Recommendations

#### Scenario: Cleanup recommendations
- **WHEN** audit detects obsolete or conflicting profiles
- **THEN** report includes specific recommendations (e.g., "Merge .instruqt_profile into .uv_profile")

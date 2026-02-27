# README.md Template for Gists

Use this template when generating the mandatory `README.md` for any gist.

---

## Template

```markdown
# <Gist Title>

<A concise one- or two-sentence description of what this gist is and why it exists.>

## Files

| File | Description |
|------|-------------|
| `README.md` | This documentation |
| `<filename>` | <What this file does or contains> |

## Usage

> Include this section only when the gist contains executable scripts or commands.

### Prerequisites

- <Dependency or requirement, e.g., "bash 4+", "Python 3.9+", "jq">

### Running

```bash
<example command(s) to run the script>
```

### Examples

```bash
# Example 1: <brief label>
<command> <args>

# Example 2: <brief label>
<command> <args>
```

## Notes

<Optional: caveats, limitations, related resources, or context the reader should know.>
```

---

## Filling in the Template

| Field | Guidance |
|-------|----------|
| **Title** | Match the gist description (`--desc`) — be specific, not generic |
| **Description** | One-two sentences: what it does and when you'd use it |
| **Files table** | One row per file in the gist; README.md is always the first row |
| **Usage section** | Include for any `.sh`, `.py`, `.rb`, `.js`, or runnable file; omit for pure config or data files |
| **Prerequisites** | List tools/languages/versions needed to run the content |
| **Examples** | At least one realistic invocation; two or three is ideal |
| **Notes** | Anything that isn't obvious: edge cases, related gists, source URLs |

## Example: Completed README.md

```markdown
# Rotate AWS Credentials Script

Automates rotation of AWS IAM access keys for a given profile, updating
`~/.aws/credentials` in place and printing the new key ID on success.

## Files

| File | Description |
|------|-------------|
| `README.md` | This documentation |
| `rotate-aws-creds.sh` | Bash script to rotate credentials via AWS CLI |

## Usage

### Prerequisites

- bash 4+
- AWS CLI v2 configured with admin permissions

### Running

```bash
bash rotate-aws-creds.sh [profile-name]
```

### Examples

```bash
# Rotate the default profile
bash rotate-aws-creds.sh

# Rotate a named profile
bash rotate-aws-creds.sh my-work-profile
```

## Notes

The old key is deactivated (not deleted) before the new key is activated.
Requires `iam:CreateAccessKey`, `iam:UpdateAccessKey`, and `iam:DeleteAccessKey` permissions.
```

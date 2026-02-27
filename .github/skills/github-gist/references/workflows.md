# Multi-File Gist Workflows

Reference for creating and managing gists with multiple files.

## Creating a Gist with Multiple Files

The `gh gist create` command accepts multiple file arguments and glob patterns:

```bash
# Multiple explicit files (README.md must be included)
gh gist create --public --desc "My utility scripts" README.md cleanup.sh backup.sh

# Glob pattern (ensure README.md matches or add it explicitly)
gh gist create --desc "Config snippets" README.md *.conf

# From stdin with a filename
cat my-script.sh | gh gist create --filename my-script.sh --desc "Pipe from stdin"
# Note: stdin gists can't include README.md inline; add via edit afterward:
# gh gist edit <id> --add README.md
```

## Workflow: Create Gist from Scratch

```bash
# Step 1: Create a temp working directory
GIST_DIR=$(mktemp -d)
cd "$GIST_DIR"

# Step 2: Write your content files
cat > my-script.sh << 'SCRIPT'
#!/usr/bin/env bash
echo "Hello from gist!"
SCRIPT

# Step 3: Write README.md using the template
cat > README.md << 'README'
# My Script

Short description of what this does.

## Files

| File | Description |
|------|-------------|
| `README.md` | This documentation |
| `my-script.sh` | Main script |

## Usage

```bash
bash my-script.sh
```
README

# Step 4: Create the gist
gh gist create --public --desc "My Script - short description" README.md my-script.sh

# Step 5: Clean up temp dir
cd ~ && rm -rf "$GIST_DIR"
```

## Adding Files to an Existing Gist

```bash
# Check current files
gh gist view <id> --files

# Add a new file (will open editor for content)
gh gist edit <id> --add newfile.py

# Add a file with content from a local file
# (Copy local file to gist via edit → editor replaces content)
gh gist edit <id> --filename newfile.py
# Then paste or type the content in the editor

# Update the README.md to document the new file
gh gist edit <id> --filename README.md
```

## Updating Gist Description

```bash
gh gist edit <id> --desc "Updated description"
```

## Renaming a File

```bash
gh gist rename <id> <old-filename> <new-filename>
```

## Removing a File

```bash
gh gist edit <id> --remove <filename>
# Always update README.md afterward if the file was documented there
```

## Cloning and Editing Locally (Recommended for Large Changes)

When making multiple changes, cloning is more efficient than repeated `edit` calls:

```bash
# Clone
gh gist clone <id> gist-work
cd gist-work

# Make changes
vim my-script.sh
vim README.md  # update docs to match

# Push changes back
git add -A
git commit -m "Update script and docs"
git push
```

## Syncing a Local Script to a Gist

Use this pattern to keep a local file and a gist in sync:

```bash
GIST_ID="your-gist-id"
FILE="my-script.sh"

# Push local changes to gist
gh gist edit "$GIST_ID" --filename "$FILE" < "$FILE"
# Note: this opens the editor pre-populated; for non-interactive use, clone instead.

# Pull gist to local (overwrite)
gh gist view "$GIST_ID" --filename "$FILE" --raw > "$FILE"
```

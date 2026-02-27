# Gist Search, List, and Management

Reference for finding, inspecting, and deleting gists.

## Listing Gists

```bash
# Default: 10 most recent, all visibility
gh gist list

# Increase result count
gh gist list -L 100

# Filter by visibility
gh gist list --public
gh gist list --secret

# Filter by description or filename (regex supported)
gh gist list --filter "docker"
gh gist list --filter "\.sh$"

# Search inside file contents (slower, uses more rate limit)
gh gist list --filter "kubectl" --include-content
```

Output columns: `ID  DESCRIPTION  FILES  VISIBILITY  UPDATED`

## Viewing Gist Details

```bash
# Default rendered view (most recent gist interactively if no ID)
gh gist view

# View by ID
gh gist view <id>

# List all filenames in a gist
gh gist view <id> --files

# View a specific file
gh gist view <id> --filename script.sh

# Raw output (useful for piping)
gh gist view <id> --raw
gh gist view <id> --filename script.sh --raw | bash

# Open in browser
gh gist view <id> --web
```

## Cloning a Gist

Cloning gives you a full git repository you can commit to and push:

```bash
# Clone to directory named by gist ID
gh gist clone <id>

# Clone to a specific directory name
gh gist clone <id> my-scripts

# Clone with extra git flags (e.g., shallow clone)
gh gist clone <id> -- --depth 1
```

After cloning, push changes back with standard `git add / commit / push`.

## Finding a Gist ID

```bash
# List with filter to narrow results
gh gist list --filter "keyword" -L 50

# If you have the URL, the ID is the last path segment:
# https://gist.github.com/username/5b0e0062eb8e9654adad7bb1d81cc75f
#                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

## Deleting a Gist

```bash
gh gist delete <id>
```

There is no undo. Confirm the correct ID before deleting.

## Bulk Operations (Shell Patterns)

```bash
# Delete all secret gists (CAREFUL)
gh gist list --secret -L 1000 | awk '{print $1}' | xargs -I{} gh gist delete {}

# Export all gist IDs and descriptions to a file
gh gist list -L 500 | tee gist-inventory.txt

# Clone all gists locally
gh gist list -L 500 | awk '{print $1}' | while read id; do
  gh gist clone "$id"
done
```

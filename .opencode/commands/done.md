---
name: done
description: Finish current work and create a pull request
arguments: optional_pr_title
agent: designer
---

The designer is finished and wants to ship their work.

## What this does

This wraps up the current feature branch: runs final checks, commits any
remaining changes, pushes to remote, and creates a GitHub pull request.
The designer just needs to click the PR link and add screenshots.

## Steps

### 1. Verify branch state

```
git branch --show-current
```

- If on `main` or `master`: REFUSE. Tell the designer "You're on main -- there's nothing
  to ship. Use `/create` or `/update` first to build something on a branch."
- Capture the branch name for the PR title if no `$ARGUMENTS` provided.

### 2. Check for uncommitted changes

```
git status --porcelain
```

If there are uncommitted changes, run a checkpoint first:
- `mix test --no-color` to check test state
- Stage and commit with an appropriate message (see `/checkpoint` rules)

### 3. Run final quality checks

```
mix precommit
```

- If it fails: fix the issues, commit the fixes, and re-run until clean
- All tests must pass, no warnings, format must be clean

### 4. Push to remote

```
git push -u origin <branch-name>
```

If the push fails (e.g., no remote configured), tell the designer and suggest
they set up the remote manually or ask for help.

### 5. Create the pull request

Determine the PR title:
- If `$ARGUMENTS` provided, use that
- Otherwise, derive from branch name (e.g., `component/tooltip` -> "Add Tooltip component")

Query `.opencode/design_system.db` for context:
```sql
SELECT name, description, category, daisy_classes FROM design_components
WHERE name IN (<components touched on this branch>);
```

Create the PR:
```
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary

<1-2 sentence description of what changed>

## Components

<list of components added/modified with their categories>

## DaisyUI Classes Used

<list of DaisyUI classes used in this change>

## Test Coverage

<number of tests added/modified>

## Screenshots

<!-- Designer: add your screenshots here! -->

EOF
)"
```

### 6. Report to the designer

Tell them:
- The PR URL (clickable)
- "Click the link above to view your PR on GitHub"
- "Edit the PR description to add your screenshots"
- The branch is pushed and ready for review

## Interpreting designer language

Designers may say things like:
- "I'm done" -> `/done`
- "ship it" -> `/done`
- "make a PR" -> `/done`
- "I'm ready for review" -> `/done`
- "let's wrap this up" -> `/done`
- "create a pull request" -> `/done`
- "push this up" -> `/done`

## Constraints

- **NEVER push to main/master** -- refuse and explain why
- **NEVER force push** -- if there's a conflict, tell the designer
- **ALWAYS run `mix precommit`** before pushing -- the PR must be clean
- **ALWAYS include a screenshot placeholder** in the PR body
- **ALWAYS show the PR URL** so the designer can click it

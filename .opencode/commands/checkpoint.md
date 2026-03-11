---
name: checkpoint
description: Save current work as a git checkpoint
arguments: optional_message
---

The designer wants to save their progress.

## What this does

This is the designer-friendly way to say "save my work." You will translate this
into proper git operations.

## Steps

1. Check the current branch: `git branch --show-current`
2. **If on main/master**: REFUSE to commit. Tell the designer:
   "You're on main -- I can't save here. Use `/create` or `/update` first to start
   a feature branch, then I can checkpoint your work."
3. Check for changes: `git status --porcelain`
4. If no changes: tell the designer "Nothing new to save -- you're all caught up."
5. If there are changes:
   a. Run `mix test --no-color` to see if tests pass
   b. Stage ALL changed files individually (use full file paths, never `.` or `-u`):
      ```
      git add <file1> <file2> ...
      ```
   c. Determine a good commit message:
      - If `$ARGUMENTS` is provided, use it as the message basis
      - If no argument, analyze the diff to write a concise message
      - If tests pass: prefix with the appropriate conventional commit type (feat:, test:, fix:, chore:)
      - If tests fail: prefix with "wip:" so it's clear this is in-progress work
   d. Commit:
      ```
      git commit -m "<message>"
      ```
   e. Report to the designer:
      - What was saved (files changed)
      - Whether tests are passing or failing
      - Current branch name
      - "Use `/done` when you're ready to create a PR"

## Interpreting designer language

Designers may say things like:
- "save this" -> `/checkpoint`
- "save and make a checkpoint here" -> `/checkpoint`
- "I'm at a good stopping point" -> `/checkpoint`
- "let me save my progress" -> `/checkpoint`
- "commit this" -> `/checkpoint`
- "snapshot" -> `/checkpoint`

Always translate these into proper atomic git commits on the current feature branch.

## Constraints

- **NEVER commit to main/master** -- refuse and redirect to `/create` or `/update`
- **NEVER use `git add .` or `git add -u`** -- always add specific files
- **NEVER amend previous commits** unless the designer explicitly asks
- **ALWAYS report back** what was saved and the current state

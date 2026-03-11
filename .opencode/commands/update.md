---
name: update
description: Update an existing design system component
arguments: component_name
agent: designer
---

The designer wants to **UPDATE**: `$ARGUMENTS`

## Step 0: Git safety -- BRANCH FIRST

**You MUST do this before ANY file changes.**

1. Check the current branch: `git branch --show-current`
2. If on `main` or `master`, create a new branch IMMEDIATELY:
   ```
   git checkout -b update/$ARGUMENTS
   ```
3. If already on a branch named `update/$ARGUMENTS` or `component/$ARGUMENTS`: continue, you're in the right place
4. If on a DIFFERENT feature branch:
   - Check for uncommitted changes: `git status --porcelain`
   - If dirty: checkpoint first (commit with "wip: checkpoint before switching to update/$ARGUMENTS")
   - Switch to main, then create the update branch:
     ```
     git checkout main
     git checkout -b update/$ARGUMENTS
     ```

**NEVER commit component work directly to main/master. This is non-negotiable.**

## Step 1: Load current state from living memory

Open `.opencode/design_system.db` and query:

```sql
SELECT * FROM design_components WHERE name = '$ARGUMENTS';
```

If no rows returned, list all available components:
```sql
SELECT name, status, category, description FROM design_components ORDER BY name;
```
Ask the designer which one they meant.

If found, show the designer:
- **Name**: component name
- **Status**: active / draft / deprecated
- **Category**: input / display / feedback / etc.
- **Description**: what it does
- **Props**: the data/assigns it uses
- **DaisyUI classes**: current styling
- **Source location**: where it lives in showcase_live.ex
- **Commentary**: design notes and decisions

## Step 2: Understand the change

Ask the designer: **What do you want to change?** Common updates:
- Add a new interaction or state
- Change styling or DaisyUI classes
- Add/remove props
- Fix a visual bug
- Refactor the component structure

**Keep the scope tight.** If the designer describes multiple unrelated changes, break them into separate `/update` calls on separate branches. One topic per branch.

## Step 3: Update tests FIRST

Modify the relevant `describe` block in `test/design_system_showoff_web/live/showcase_live_test.exs`:

- Add new test cases for the changed behavior
- Update existing tests if the expected output changes
- Keep all other component tests untouched

Run: `mix test test/design_system_showoff_web/live/showcase_live_test.exs`
The new/changed tests should **FAIL** (red phase). Existing unchanged tests should still pass.

**Checkpoint**: commit the test changes:
```
git add test/design_system_showoff_web/live/showcase_live_test.exs
git commit -m "test: update tests for $ARGUMENTS changes"
```

## Step 4: Update the component

Modify the component in `lib/design_system_showoff_web/live/showcase_live.ex`:

- Update assigns in `mount/3` if needed
- Add/modify `handle_event` clauses
- Update the template section
- Keep stub data -- no real backend

Run tests again: ALL tests should **PASS** (green phase) -- both the updated ones and all others.

**Checkpoint**: commit the implementation:
```
git add lib/design_system_showoff_web/live/showcase_live.ex
git commit -m "feat: update $ARGUMENTS component"
```

## Step 4.5: Screenshot the updated component

Now that tests are green, capture screenshots so the designer can SEE the change:

1. Make sure the Phoenix server is running (it should be from boot)
2. Run the screenshot script for the updated component:
   ```
   bun run .opencode/scripts/screenshot.ts $ARGUMENTS
   ```
   This captures the component section in both light and dark themes.
3. **Show the screenshots to the designer** -- read the images at:
   - `screenshots/$ARGUMENTS-light.png`
   - `screenshots/$ARGUMENTS-dark.png`
4. Ask the designer: "Here's the updated component. Does this look right?"
5. If more changes are needed, update the code, re-run tests, re-screenshot, and show again.
6. Once the designer is happy, commit the screenshots:
   ```
   git add screenshots/$ARGUMENTS-light.png screenshots/$ARGUMENTS-dark.png
   git commit -m "docs: update screenshots for $ARGUMENTS component"
   ```

## Step 5: Update living memory

```sql
UPDATE design_components
SET
  description = '<updated>',
  props = '<updated_json>',
  daisy_classes = '<updated>',
  source_location = '<updated>',
  commentary = '<append_to_existing_json>',
  updated_at = datetime('now')
WHERE name = '$ARGUMENTS';
```

**Checkpoint**: commit the DB update:
```
git add .opencode/design_system.db
git commit -m "chore: update $ARGUMENTS in design system living memory"
```

## Step 6: Final checks

1. Run `mix precommit` -- must pass clean
2. If precommit fails, fix issues and commit the fixes
3. Tell the designer: "Your update is ready! Use `/done` when you want to create a PR."

## Constraints

- **PROTECT MAIN** -- never commit to main/master, always use a branch
- **SINGLE TOPIC** -- one update per branch, don't let scope creep
- **STUB DATA ONLY** -- no new Ecto schemas or migrations
- **SINGLE LIVEVIEW** -- modifications stay in `ShowcaseLive`
- **DON'T BREAK OTHERS** -- other components must still pass their tests
- **TEST FIRST** -- update tests before updating code
- **UPDATE THE DB** -- always update the living memory row after changes
- **ATOMIC COMMITS** -- small, logical commits at each phase

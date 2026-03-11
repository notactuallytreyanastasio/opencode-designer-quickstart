---
name: create
description: Create a new design system component (test-first)
arguments: component_name
agent: designer
---

The designer wants to **CREATE** a new component: `$ARGUMENTS`

## Step 0: Git safety -- BRANCH FIRST

**You MUST do this before ANY file changes.**

1. Check the current branch: `git branch --show-current`
2. If on `main` or `master`, you MUST create a new branch IMMEDIATELY:
   ```
   git checkout -b component/$ARGUMENTS
   ```
3. If already on a different branch (e.g., from a prior `/create` or `/update`):
   - Check if there are uncommitted changes: `git status --porcelain`
   - If dirty: checkpoint the current work first (commit with message "wip: checkpoint before switching to $ARGUMENTS"), then create the new branch FROM main:
     ```
     git checkout main
     git checkout -b component/$ARGUMENTS
     ```
   - If clean and the branch name matches this component: you're fine, continue
   - If clean and branch name is for a DIFFERENT component: switch to main first, then branch:
     ```
     git checkout main
     git checkout -b component/$ARGUMENTS
     ```

**NEVER commit component work directly to main/master. This is non-negotiable.**

## Step 1: Verify the component doesn't exist

1. Open the SQLite database at `.opencode/design_system.db`
2. Query `SELECT name FROM design_components` to list existing components
3. Verify `$ARGUMENTS` doesn't already exist (if it does, suggest `/update` instead)
4. Read `.opencode/design-tokens.md` for theme reference

## Step 2: Write tests FIRST

Add a new `describe` block to `test/design_system_showoff_web/live/showcase_live_test.exs`:

- Test that the component section renders with a unique `id` (e.g., `#$ARGUMENTS-section`)
- Test each interactive behavior the component should have
- Test visual states (loading, active, disabled, etc.)
- Test that DaisyUI classes are applied correctly via element selectors
- Every test should use `has_element?/2` or `has_element?/3` -- never test raw HTML strings

Run the tests: `mix test test/design_system_showoff_web/live/showcase_live_test.exs`
They should **FAIL** (red phase). This is correct and expected.

## Step 2.5: Design Review -- STOP AND ASK

**Do NOT proceed to implementation yet.** The failing tests are the design spec. Present them
to the designer in plain language so they can validate the intent before you build anything.

Summarize what the tests assert as a checklist. For example:

> Here's what I'm planning to build for **$ARGUMENTS**:
>
> - It will have a section on the showcase page
> - It will show [describe initial visual state]
> - When you [interaction], it will [outcome]
> - When you [interaction], it will [outcome]
> - It will use these DaisyUI styles: [list key classes]
>
> **Does this match what you have in mind? Want to add, remove, or change anything?**

**Wait for the designer to respond.** This is a hard stop -- do not continue until they confirm.

If the designer wants changes:
1. Update the tests to match their feedback
2. Re-run to confirm they still fail (red)
3. Present the updated checklist again
4. Repeat until the designer says "looks good" / "yes" / "go for it"

Once confirmed, checkpoint the tests:
```
git add test/design_system_showoff_web/live/showcase_live_test.exs
git commit -m "test: add failing tests for $ARGUMENTS component"
```

## Step 3: Build the component

Add the component to `lib/design_system_showoff_web/live/showcase_live.ex`:

- Add any new assigns in `mount/3`
- Add `handle_event` clauses for interactions
- Add the template section inside `#showcase-page` div
- Use **stub data only** -- define it as a module attribute like `@stub_table_data`
- Use DaisyUI classes from the theme (see `.opencode/design-tokens.md`)
- Every interactive element MUST have a unique DOM `id`

Run the tests again: `mix test test/design_system_showoff_web/live/showcase_live_test.exs`
They should **PASS** (green phase).

**Checkpoint**: commit the implementation:
```
git add lib/design_system_showoff_web/live/showcase_live.ex
git commit -m "feat: add $ARGUMENTS component to showcase"
```

## Step 3.5: Screenshot the component

Now that tests are green, capture screenshots so the designer can SEE the result:

1. Make sure the Phoenix server is running (it should be from boot)
2. Run the screenshot script for the new component:
   ```
   bun run .opencode/scripts/screenshot.ts $ARGUMENTS
   ```
   This captures the component section in both light and dark themes.
3. **Show the screenshots to the designer** -- read the images at:
   - `screenshots/$ARGUMENTS-light.png`
   - `screenshots/$ARGUMENTS-dark.png`
4. Ask the designer: "Here's what your component looks like. Want to tweak anything?"
5. If changes are needed, update the code, re-run tests, re-screenshot, and show again.
6. Once the designer is happy, commit the screenshots:
   ```
   git add screenshots/$ARGUMENTS-light.png screenshots/$ARGUMENTS-dark.png
   git commit -m "docs: add screenshots for $ARGUMENTS component"
   ```

## Step 4: Update living memory

Insert a new row into the `design_components` table in `.opencode/design_system.db`:

```sql
INSERT INTO design_components
  (name, status, category, description, props, daisy_classes, test_file, source_location, commentary)
VALUES
  ('$ARGUMENTS', 'active', '<category>', '<description>', '<props_json>', '<classes>',
   'test/design_system_showoff_web/live/showcase_live_test.exs',
   'lib/design_system_showoff_web/live/showcase_live.ex:L<start>-L<end>',
   '<commentary_json>');
```

**Checkpoint**: commit the DB update:
```
git add .opencode/design_system.db
git commit -m "chore: register $ARGUMENTS in design system living memory"
```

## Step 5: Final checks

1. Run `mix precommit` -- must pass with zero warnings and zero failures
2. If precommit fails, fix issues and commit the fixes
3. Tell the designer: "Your component is ready! Use `/done` when you want to create a PR."

## Constraints

- **PROTECT MAIN** -- never commit to main/master, always use a branch
- **STUB DATA ONLY** -- no Ecto schemas, no migrations, no real backend
- **SINGLE LIVEVIEW** -- everything goes in `ShowcaseLive`
- **DAISY UI** -- use only DaisyUI classes from the existing themes
- **UNIQUE IDS** -- every interactive element needs a unique DOM id
- **TEST FIRST** -- tests must exist and fail before the component code is written
- **ATOMIC COMMITS** -- small, logical commits at each phase (tests, implementation, DB)

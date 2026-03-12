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

## Step 3.5: Design Review -- ASSERTION DIALOGUE

**Do NOT proceed to implementation yet.** The failing tests define the change. Walk through
each NEW or CHANGED test assertion ONE AT A TIME with the designer, turning each into a
conversation that sharpens the update.

### How the dialogue works

**1. Anchor on what exists (unchanged assertions)**

> These existing behaviors stay the same -- I won't touch them:
> - [existing assertion 1]
> - [existing assertion 2]
>
> Anything here that should ALSO change while we're at it?

Wait for the designer. They may realize adjacent behaviors need updating too.

**2. Walk through each change one at a time**

For each new or modified test, present it as a plain-language assertion:

> **Changed assertion:** "[Old behavior]" → "[New behavior]"
>
> Is this the change you had in mind? What should the transition feel like?

Or for net-new tests:

> **New assertion:** "When the user [does X], the component will [do Y]."
>
> Is this the main thing you want to add? What should the user see before and after?

Wait for each response. This is where designers often discover:
- Side effects on existing behavior ("wait, if we add that, does the hover state still work?")
- Missing transitions ("it should fade, not just swap")
- Scope creep they want to defer ("let's save that for a separate update")

**3. Probe for edge cases around the changes**

> Now that we've changed [X], let me ask about edges:
> - Does this change affect [related interaction]?
> - What happens when [boundary condition for the new behavior]?
> - Should the old behavior still work as a fallback?
>
> Worth adding any of these as assertions?

Add tests for any edge cases the designer cares about.

**4. Recap: what's changing vs. what's staying**

> Here's the final picture for **$ARGUMENTS**:
>
> **Unchanged (still passing):**
> 1. [existing assertion]
> ...
>
> **New/Changed (currently failing, will be implemented):**
> 1. [new assertion]
> ...
>
> **All good? Or want to adjust anything before I start implementing?**

### Iteration rules

- If the designer changes their mind on a previous assertion, update that test immediately
- Re-run tests after changes: new/changed tests should fail (red), unchanged tests should pass
- Don't rush -- the whole point is to help the designer think through the impact of changes
- Only proceed when the designer explicitly confirms the final list

Once confirmed, checkpoint the tests:
```
git add test/design_system_showoff_web/live/showcase_live_test.exs
git commit -m "test: update tests for $ARGUMENTS changes"
```

## Step 4: Update the component

### 4a: Update the function component module

Modify the component in `lib/design_system_showoff_web/components/$ARGUMENTS.ex`:

- Add/remove/change `attr` or `slot` declarations as needed
- Update the HEEx markup in the component function
- Keep the component stateless — interaction events are handled by the parent

### 4b: Update the showcase page if needed

Modify `lib/design_system_showoff_web/live/showcase_live.ex` if the change affects:

- Assigns in `mount/3` (new props, changed stub data)
- Event handlers (`handle_event` clauses)
- How the component is called in the template (new attrs passed)
- Keep stub data -- no real backend

Run tests again: ALL tests should **PASS** (green phase) -- both the updated ones and all others.

**Checkpoint**: commit the implementation:
```
git add lib/design_system_showoff_web/components/$ARGUMENTS.ex
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
- **FUNCTION COMPONENTS** -- update the component module in `components/`; the showcase page only calls components
- **SINGLE LIVEVIEW** -- state management stays in `ShowcaseLive`, components are stateless
- **DON'T BREAK OTHERS** -- other components must still pass their tests
- **TEST FIRST** -- update tests before updating code
- **UPDATE THE DB** -- always update the living memory row after changes
- **ATOMIC COMMITS** -- small, logical commits at each phase

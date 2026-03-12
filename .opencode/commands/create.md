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

## Step 2.5: Design Review -- ASSERTION DIALOGUE

**Do NOT proceed to implementation yet.** The failing tests are the design spec. Walk through
each test assertion ONE AT A TIME with the designer, turning each into a conversation that
refines the component's design.

### How the dialogue works

For each test you wrote, present the assertion as a plain-language statement and ask the
designer to react. Go in this order:

**1. Start with the basics (existence & structure)**

> **Assertion 1:** "$ARGUMENTS will have its own section on the showcase page."
>
> Does this need a title? A description? Any special layout container?

Wait for the designer to respond. Update the test if they refine it.

**2. Walk through main use cases (initial state & core interactions)**

For each core behavior test, present it as:

> **Assertion N:** "When the user [does X], the component will [do Y]."
>
> Is this the main use case you're imagining? What should the user see before they interact?
> What happens right after?

Wait for each response. This is where designers often discover:
- Missing intermediate states ("oh, it should show a loading state first")
- Unclear transitions ("actually it should animate, not just appear")
- Implicit assumptions ("I assumed it would reset when you click away")

**3. Probe for edge cases**

After covering the main use cases, explicitly ask:

> We've covered the happy path. Let me ask about some edges:
> - What happens when [empty state / no data]?
> - What happens when [too many items / overflow]?
> - What happens when [user double-clicks / rapid interaction]?
> - What happens on [mobile / small viewport]?
>
> Any of these worth capturing as assertions?

Add tests for any edge cases the designer cares about.

**4. Confirm styling intent**

> **Styling:** This will use these DaisyUI classes: [list key classes].
>
> Does this feel right for the visual weight and hierarchy you want?

**5. Recap the full assertion list**

Once all assertions are discussed individually, present the final compiled list:

> Here's the complete set of assertions for **$ARGUMENTS**:
>
> 1. [assertion]
> 2. [assertion]
> ...
>
> **All good? Or want to adjust anything before I lock these in?**

### Iteration rules

- If the designer changes their mind on a previous assertion, update that test immediately
- Re-run tests after changes to confirm they still fail (red)
- Don't rush -- the whole point is to help the designer think through the design thoroughly
- Only proceed when the designer explicitly confirms the final list

Once confirmed, checkpoint the tests:
```
git add test/design_system_showoff_web/live/showcase_live_test.exs
git commit -m "test: add failing tests for $ARGUMENTS component"
```

## Step 3: Build the component

### 3a: Create the function component module

Create a new file at `lib/design_system_showoff_web/components/$ARGUMENTS.ex`:

- Define a module: `DesignSystemShowoffWeb.Components.<PascalName>`
- `use Phoenix.Component`
- Declare every prop with `attr` — include type, required/optional, defaults, and allowed values
- Use `slot` for any composable content areas
- Define the component function (e.g., `def metric_tile(assigns)`) with HEEx markup
- Use DaisyUI classes from the theme (see `.opencode/design-tokens.md`)
- Every interactive element MUST have a unique DOM `id`
- Keep the component **stateless** — no `handle_event` here, use `phx-click` attrs that the parent handles

### 3b: Wire it into the showcase page

Update `lib/design_system_showoff_web/live/showcase_live.ex`:

- `import DesignSystemShowoffWeb.Components.<PascalName>` at the top
- Add any new assigns in `mount/3`
- Add `handle_event` clauses for interactions
- Add a section in the `render/1` template that CALLS the component (e.g., `<.component_name ... />`)
- Use **stub data only** — define it as a module attribute like `@stub_table_data`
- The showcase page should NOT contain raw component markup — only `<.component_name />` calls

Run the tests again: `mix test test/design_system_showoff_web/live/showcase_live_test.exs`
They should **PASS** (green phase).

**Checkpoint**: commit the implementation:
```
git add lib/design_system_showoff_web/components/$ARGUMENTS.ex
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
- **FUNCTION COMPONENTS** -- every component gets its own module in `components/` with `attr`/`slot` declarations; showcase page only calls them
- **SINGLE LIVEVIEW** -- state management stays in `ShowcaseLive`, components are stateless
- **DAISY UI** -- use only DaisyUI classes from the existing themes
- **UNIQUE IDS** -- every interactive element needs a unique DOM id
- **TEST FIRST** -- tests must exist and fail before the component code is written
- **ATOMIC COMMITS** -- small, logical commits at each phase (tests, implementation, DB)

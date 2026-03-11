---
name: ideate
description: Brainstorm and plan a component design (no code)
arguments: component_concept
agent: designer
---

The designer wants to **IDEATE** on: `$ARGUMENTS`

## Git note

Ideation does NOT require a branch. No code files will be modified.
The only possible write is a draft row in the SQLite database.

If you are currently on a feature branch with uncommitted work, warn the designer
and suggest they `/checkpoint` first before ideating, but do NOT switch branches
or touch any code files.

## This is a brainstorm session -- NO CODE CHANGES

### Step 1: Review what exists

Open `.opencode/design_system.db` and query:
```sql
SELECT name, category, description, daisy_classes FROM design_components ORDER BY name;
```

Show the designer what already exists in the system so they can build on it.

### Step 2: Explore the concept

Discuss `$ARGUMENTS` with the designer:

- **What problem does this component solve?** What user action or information display does it support?
- **What are the interaction states?** (idle, hover, active, loading, disabled, error, success)
- **What data does it need?** Define the stub data shape (keep it simple)
- **How does it relate to existing components?** Can it reuse patterns from CalendarDatepicker, LoadingButton, or DataTable?

### Step 3: Sketch a test plan

Write out (but do NOT create) what the tests would look like:

- "It should render a section with id `#<component>-section`"
- "It should display <initial state>"
- "When <interaction>, it should <outcome>"
- "The <element> should have DaisyUI class `<class>`"

Present these as a numbered list so the designer can review and refine.

### Step 4: Identify DaisyUI classes

Reference `.opencode/design-tokens.md` and suggest which DaisyUI component classes would be appropriate:
- Layout classes (card, collapse, drawer, etc.)
- Interactive classes (btn, toggle, checkbox, etc.)
- Feedback classes (alert, badge, loading, progress, etc.)
- Color variants (primary, secondary, accent, success, warning, error, etc.)

### Step 5: Optionally save the idea

If the designer is happy with the concept, insert a draft row:

```sql
INSERT INTO design_components
  (name, status, category, description, props, daisy_classes, commentary)
VALUES
  ('$ARGUMENTS', 'draft', '<category>', '<description>', '<props_json>', '<suggested_classes>',
   '<commentary_with_test_plan>');
```

This saves the idea in the living memory for later `/create` execution.

If the database was modified, commit it:
```
git add .opencode/design_system.db
git commit -m "chore: save draft idea for $ARGUMENTS component"
```

## Constraints

- **DO NOT** write any code, modify any `.ex` or `.exs` files, or create feature branches
- **DO NOT** touch showcase_live.ex or any test files
- **ONLY** discuss, plan, and optionally insert a draft row into the database
- Keep the conversation focused on design thinking and test planning

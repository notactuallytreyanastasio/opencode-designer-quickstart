# Design System Showoff

A designer-friendly component playground built on Phoenix LiveView and DaisyUI. Designers build, iterate, and ship components using natural language — the AI agent handles git, servers, tests, and PRs invisibly.

Built for [OpenCode](https://opencode.ai).

## What This Is

Designers open OpenCode in this repo and are prompted:

> **What would you like to do?**
> - `/create <name>` — Build a new component
> - `/ideate <name>` — Brainstorm a component idea
> - `/update <name>` — Modify an existing component

They can also just talk naturally — "let's build a tooltip" triggers the create workflow automatically.

The AI agent manages everything else: branching, test-first development, screenshots, checkpoints, and pull requests. Designers never touch git, never run commands, never worry about the server.

## How It Works

### The Workflow

```
Designer says "let's build a tooltip"
        |
        v
  Agent branches from main (component/tooltip)
        |
        v
  Agent writes failing tests (red phase)
        |
        v
  DESIGN REVIEW: Agent presents test assertions
  as a plain-language checklist and WAITS for
  the designer to confirm the intent
        |
        v
  Agent builds the component (green phase)
        |
        v
  Agent screenshots in light + dark themes
  and shows them to the designer
        |
        v
  Designer says "ship it"
        |
        v
  Agent runs precommit, pushes, creates PR
  with screenshot placeholders
```

### Key Principles

- **Test-first** — Tests are written before code. The failing tests ARE the design spec. The designer reviews and approves them before implementation begins.
- **Visual feedback** — After tests go green, Playwright captures screenshots in both themes so the designer can see the result immediately.
- **Main is protected** — All work happens on feature branches. A runtime plugin hook blocks commits, pushes, and destructive operations on main/master.
- **One topic per branch** — Each component gets its own branch. If direction changes, the agent checkpoints and starts fresh.
- **Living memory** — A SQLite database tracks every component (name, status, category, DaisyUI classes, test file, source location, design notes). The agent queries it to know what exists.
- **Invisible git** — Designers say "save this" and the agent translates to atomic commits. They say "ship it" and the agent creates a PR. They never see a git command.

## Architecture

```
.opencode/
  agents/designer.md         # Designer agent — intent detection, guardrails, workflows
  commands/
    create.md                 # CREATE workflow (test-first, design review, screenshot)
    update.md                 # UPDATE workflow (same phases)
    ideate.md                 # IDEATE workflow (brainstorm only, no code)
    checkpoint.md             # CHECKPOINT workflow (save progress)
    done.md                   # DONE workflow (precommit, push, PR)
  plugins/
    designer-guardrails.ts    # Boot plugin + runtime git guardrails
  scripts/
    screenshot.ts             # Playwright screenshot script (light + dark themes)
  design-tokens.md            # DaisyUI theme reference (colors, classes)
  design_system.db            # SQLite living memory (created at runtime)

lib/.../live/showcase_live.ex # ALL components live here (single LiveView)
test/.../showcase_live_test.exs # ALL component tests

screenshots/                  # Auto-generated component screenshots
```

### The Plugin (`designer-guardrails.ts`)

Runs on every OpenCode session start:

1. Initializes the SQLite living memory database
2. Seeds existing components (if table is empty)
3. Compiles the project and runs migrations
4. Starts the Phoenix server (if port 4000 is free)
5. Shows the designer what components exist and prompts for action

Also provides a `tool.execute.before` hook that blocks:
- Commits/pushes to main/master
- Force pushes
- `git add .` / `-A` / `-u` (must use specific files)
- Hard resets on protected branches
- Deleting protected branches

### The Agent (`designer.md`)

A primary-mode agent that:
- Detects designer intent from natural language (create/update/ideate/checkpoint/done)
- Executes the correct command workflow step-by-step
- Translates designer language to git operations ("save this" → commit, "ship it" → PR)
- Manages branch lifecycle invisibly
- Queries and updates the living memory database
- Takes and displays screenshots after green phase

### Screenshots (`screenshot.ts`)

A Playwright script that captures component sections from the running showcase:

```bash
# Single component (both themes)
bun run .opencode/scripts/screenshot.ts datepicker

# All components
bun run .opencode/scripts/screenshot.ts all

# Full page
bun run .opencode/scripts/screenshot.ts all --full-page
```

Captures each component section by its DOM id (`#<name>-section`) in both light (Phoenix orange) and dark (Elixir purple) themes.

## Components

The showcase currently includes:

| Component | Category | Description |
|---|---|---|
| Calendar Datepicker | input | Month-navigable calendar with day selection and today highlighting |
| Loading Button | feedback | Button with loading spinner state and reset control |
| Data Table | display | Zebra-striped table with color-coded status badges |

Each component has:
- Full test coverage in `showcase_live_test.exs`
- Screenshots in both themes in `screenshots/`
- A row in the SQLite living memory database
- Stub data only — no real backend

## DaisyUI Themes

Two custom themes defined in `assets/css/app.css`:

- **Light (Phoenix Orange)** — Warm orange primary, near-white base
- **Dark (Elixir Purple)** — Vivid purple primary, dark blue-gray base

Full color tokens and class reference in `.opencode/design-tokens.md`.

## Setup

```bash
mix setup                    # Install deps, create DB, build assets
mix phx.server               # Start the server
```

Visit [localhost:4000/showcase](http://localhost:4000/showcase) to see the component gallery.

For the designer workflow, open this directory in OpenCode — the boot plugin handles everything automatically.

### Screenshot Dependencies

The screenshot script requires Playwright and Chromium:

```bash
cd .opencode && bun install  # Installs playwright
bunx playwright install chromium
```

## Development

- `mix test` — Run all tests
- `mix precommit` — Full quality check (compile with warnings-as-errors, format, test)
- `bun run .opencode/scripts/screenshot.ts all` — Regenerate all screenshots

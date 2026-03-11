import { Database } from "bun:sqlite";
import { join } from "path";

// ---------------------------------------------------------------------------
// Designer Guardrails Plugin
//
// On every OpenCode session start this plugin:
//   1. Initializes the SQLite "living memory" database
//   2. Seeds the 3 existing showcase components (if table is empty)
//   3. Compiles the Elixir project and runs migrations
//   4. Starts the Phoenix server (if port 4000 is free)
//   5. Shows the designer what's available and prompts for action
// ---------------------------------------------------------------------------

const DB_PATH = join(import.meta.dir, "..", "design_system.db");
const SHOWCASE_URL = "http://localhost:4000/showcase";

// -- SQLite helpers ----------------------------------------------------------

function initDatabase(): Database {
  const db = new Database(DB_PATH, { create: true });

  db.run(`
    CREATE TABLE IF NOT EXISTS design_components (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      name            TEXT    NOT NULL UNIQUE,
      status          TEXT    DEFAULT 'active',
      category        TEXT,
      description     TEXT,
      props           TEXT,
      daisy_classes   TEXT,
      test_file       TEXT,
      source_location TEXT,
      commentary      TEXT,
      created_at      TEXT    DEFAULT (datetime('now')),
      updated_at      TEXT    DEFAULT (datetime('now'))
    )
  `);

  return db;
}

function seedIfEmpty(db: Database) {
  const count = db
    .query("SELECT COUNT(*) as cnt FROM design_components")
    .get() as { cnt: number };

  if (count.cnt > 0) return;

  const insert = db.prepare(`
    INSERT INTO design_components
      (name, status, category, description, props, daisy_classes, test_file, source_location, commentary)
    VALUES
      (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const seed = db.transaction(() => {
    insert.run(
      "CalendarDatepicker",
      "active",
      "input",
      "Month-navigable calendar datepicker with day selection, today highlighting, and selected date display.",
      JSON.stringify({
        current_month: "Date (beginning of month)",
        selected_date: "Date | nil",
        calendar_weeks: "list of week lists",
      }),
      "card bg-base-200 shadow-lg btn btn-ghost btn-sm btn-circle btn-outline btn-primary btn-active",
      "test/design_system_showoff_web/live/showcase_live_test.exs",
      "lib/design_system_showoff_web/live/showcase_live.ex:L77-L149",
      JSON.stringify({
        notes: [
          "Uses calendar_weeks/1 helper to build grid with leading/trailing nils",
          "Sunday-start week layout",
          "Out-of-month days rendered at 30% opacity",
        ],
      }),
    );

    insert.run(
      "LoadingButton",
      "active",
      "feedback",
      "Button that shows a loading spinner and text change on click, with a reset button to stop.",
      JSON.stringify({
        loading: "boolean",
      }),
      "btn btn-primary btn-disabled loading loading-spinner loading-sm btn-ghost",
      "test/design_system_showoff_web/live/showcase_live_test.exs",
      "lib/design_system_showoff_web/live/showcase_live.ex:L152-L186",
      JSON.stringify({
        notes: [
          "Disabled attribute set alongside btn-disabled class",
          "Reset button only visible during loading state",
          "Text toggles between 'Submit' and 'Loading'",
        ],
      }),
    );

    insert.run(
      "DataTable",
      "active",
      "display",
      "Zebra-striped data table with 5 stub rows showing Name, Role, and Status columns with color-coded badges.",
      JSON.stringify({
        table_data: "list of maps with id, name, role, status fields",
      }),
      "card bg-base-200 shadow-lg table table-zebra badge badge-success badge-warning badge-ghost badge-neutral",
      "test/design_system_showoff_web/live/showcase_live_test.exs",
      "lib/design_system_showoff_web/live/showcase_live.ex:L188-L218",
      JSON.stringify({
        notes: [
          "Status badge colors: Active=success, Away=warning, Offline=ghost",
          "badge_class/1 helper maps status strings to DaisyUI badge variants",
          "Stub data defined as module attribute @stub_table_data",
        ],
      }),
    );
  });

  seed();
}

// -- Git guardrail helpers ---------------------------------------------------

const PROTECTED_BRANCHES = ["main", "master"];

async function getCurrentBranch(
  $: any,
  directory: string,
): Promise<string> {
  try {
    const result = await $`git branch --show-current`.cwd(directory).text();
    return result.trim();
  } catch {
    return "unknown";
  }
}

/**
 * Inspects a shell command string for dangerous git operations.
 * Returns a rejection reason string if blocked, or null if safe.
 */
function checkGitCommand(
  cmd: string,
  currentBranch: string,
): string | null {
  const trimmed = cmd.trim();

  // Only inspect git commands
  if (!trimmed.startsWith("git ")) return null;

  const onProtected = PROTECTED_BRANCHES.includes(currentBranch);

  // Block: git commit on main/master
  if (onProtected && trimmed.startsWith("git commit")) {
    return `BLOCKED: Cannot commit directly to '${currentBranch}'. Create a feature branch first (component/<name> or update/<name>).`;
  }

  // Block: git push to main/master
  if (
    onProtected &&
    trimmed.startsWith("git push") &&
    !trimmed.includes("--set-upstream") &&
    !trimmed.includes("-u ")
  ) {
    // Allow pushing the current feature branch with -u, block pushing main
    if (
      !trimmed.includes(`origin ${currentBranch}`) ||
      PROTECTED_BRANCHES.some((b) => trimmed.includes(`origin ${b}`))
    ) {
      return `BLOCKED: Cannot push directly to '${currentBranch}'. Work on a feature branch.`;
    }
  }

  // Block: force push anywhere
  if (trimmed.includes("--force") || trimmed.includes(" -f")) {
    // Allow -f in non-push contexts (e.g., git branch -f is unusual but less dangerous)
    if (trimmed.startsWith("git push")) {
      return "BLOCKED: Force push is not allowed. Resolve conflicts instead.";
    }
  }

  // Block: git add . / git add -A / git add -u (must use specific files)
  if (/^git add\s+(\.|--all|-A|-u)\s*$/.test(trimmed)) {
    return "BLOCKED: Use specific file paths with 'git add' instead of '.', '-A', or '-u'.";
  }

  // Block: destructive resets on protected branches
  if (onProtected && trimmed.includes("git reset --hard")) {
    return `BLOCKED: Cannot hard reset on '${currentBranch}'.`;
  }

  // Block: deleting protected branches
  if (trimmed.startsWith("git branch -D") || trimmed.startsWith("git branch -d")) {
    for (const b of PROTECTED_BRANCHES) {
      if (trimmed.includes(b)) {
        return `BLOCKED: Cannot delete protected branch '${b}'.`;
      }
    }
  }

  return null;
}

// -- Port check --------------------------------------------------------------

async function isPortFree(port: number): Promise<boolean> {
  try {
    const proc = Bun.spawn(["lsof", "-i", `:${port}`, "-t"], {
      stdout: "pipe",
      stderr: "pipe",
    });
    const output = await new Response(proc.stdout).text();
    await proc.exited;
    return output.trim() === "";
  } catch {
    return true;
  }
}

// -- Plugin export (named export, returns hooks object) ----------------------

export const DesignerGuardrails = async ({
  client,
  $,
  directory,
}: {
  project: any;
  client: any;
  $: any;
  directory: string;
  worktree: string;
}) => {
  return {
    // Boot: fires when a new session is created
    "session.created": async () => {
      // 1. Init SQLite living memory
      const db = initDatabase();
      seedIfEmpty(db);

      const componentCount = db
        .query("SELECT COUNT(*) as cnt FROM design_components")
        .get() as { cnt: number };

      // Grab component names for context
      const components = db
        .query(
          "SELECT name, status, category, description FROM design_components ORDER BY name",
        )
        .all() as Array<{
        name: string;
        status: string;
        category: string;
        description: string;
      }>;

      db.close();

      // 2. Compile the project and run migrations
      await client.tui.showToast({
        body: { message: "Compiling project and running migrations..." },
      });

      try {
        await $`mix deps.get --quiet`.cwd(directory);
        await $`mix compile --no-optional-deps`.cwd(directory);
        await $`mix ecto.create --quiet`.cwd(directory).catch(() => {});
        await $`mix ecto.migrate --quiet`.cwd(directory);
      } catch (err: any) {
        await client.tui.showToast({
          body: {
            message: `Build step failed: ${err.message}`,
            variant: "error",
          },
        });
      }

      // 3. Start Phoenix server if port 4000 is free
      const portFree = await isPortFree(4000);
      if (portFree) {
        // Fire and forget -- server runs in background
        $`mix phx.server`.cwd(directory).catch(() => {});
        await client.tui.showToast({
          body: {
            message: `Server starting at ${SHOWCASE_URL}`,
            variant: "success",
          },
        });
      } else {
        await client.tui.showToast({
          body: {
            message: "Port 4000 in use -- server assumed running",
          },
        });
      }

      // 4. Build the component inventory for context
      const componentList = components
        .map(
          (c) =>
            `  - ${c.name} [${c.status}] (${c.category}): ${c.description}`,
        )
        .join("\n");

      // 5. Pre-fill the prompt with a greeting so the designer sees what to do
      await client.tui.appendPrompt({
        body: {
          text: [
            `Design System ready! ${componentCount.cnt} components tracked.`,
            `Open the showcase: ${SHOWCASE_URL}`,
            ``,
            `Components:`,
            componentList,
            ``,
            `What would you like to do?`,
            `  /create <name>  -- Build a new component`,
            `  /ideate <name>  -- Brainstorm a component idea`,
            `  /update <name>  -- Modify an existing component`,
          ].join("\n"),
        },
      });
    },

    // Git guardrails: intercept shell commands before execution
    "tool.execute.before": async (event: {
      tool: string;
      input: Record<string, unknown>;
    }) => {
      // Only inspect shell/bash tool calls
      if (event.tool !== "shell" && event.tool !== "bash") return;

      const cmd = (event.input.command as string) || "";
      if (!cmd.trim().startsWith("git ")) return;

      const branch = await getCurrentBranch($, directory);
      const rejection = checkGitCommand(cmd, branch);

      if (rejection) {
        await client.tui.showToast({
          body: { message: rejection, variant: "error" },
        });
        // Return an object to block execution
        return { blocked: true, reason: rejection };
      }
    },
  };
};

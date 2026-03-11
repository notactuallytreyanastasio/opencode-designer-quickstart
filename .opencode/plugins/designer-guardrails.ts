import { Database } from "bun:sqlite";
import { join } from "path";

// ---------------------------------------------------------------------------
// Designer Guardrails Plugin
//
// On every OpenCode session start this plugin:
//   1. Initializes the SQLite "living memory" database
//   2. Seeds the 3 existing showcase components (if table is empty)
//   3. Compiles the Elixir project
//   4. Starts the Phoenix server (if port 4000 is free)
//   5. Prompts the designer: CREATE, IDEATE, or UPDATE?
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
  const count = db.query("SELECT COUNT(*) as cnt FROM design_components").get() as { cnt: number };

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

// -- Plugin export -----------------------------------------------------------

export default function designerGuardrails({
  project,
  client,
  $,
  directory,
}: {
  project: any;
  client: any;
  $: any;
  directory: string;
  worktree: string;
}) {
  // Boot: session.created
  client.on("session.created", async () => {
    // 1. Init SQLite
    const db = initDatabase();
    seedIfEmpty(db);

    const componentCount = db.query("SELECT COUNT(*) as cnt FROM design_components").get() as { cnt: number };
    db.close();

    // 2. Compile the project
    client.tui.showToast(`Compiling project...`);
    try {
      await $`mix deps.get --quiet`.cwd(directory);
      await $`mix compile --no-optional-deps`.cwd(directory);
    } catch (err: any) {
      client.tui.showToast(`Compile failed: ${err.message}`);
    }

    // 3. Start Phoenix server if port 4000 is free
    const portFree = await isPortFree(4000);
    if (portFree) {
      // Fire and forget -- server runs in background
      $`mix phx.server`.cwd(directory).catch(() => {});
      client.tui.showToast(`Phoenix server starting at ${SHOWCASE_URL}`);
    } else {
      client.tui.showToast(`Port 4000 already in use -- server assumed running`);
    }

    // 4. Inject context about existing components
    const summary = [
      `Design System Living Memory: ${componentCount.cnt} components tracked in SQLite.`,
      `Showcase URL: ${SHOWCASE_URL}`,
      ``,
      `To get started, use one of these commands:`,
      `  /create <component_name> - Build a new component (test-first)`,
      `  /ideate <concept>        - Brainstorm a component design`,
      `  /update <component_name> - Modify an existing component`,
    ].join("\n");

    await client.session.prompt(summary, { noReply: true });

    // 5. Prompt the designer
    client.tui.appendPrompt(
      "Do you want to CREATE, IDEATE, or UPDATE a component? (use /create, /ideate, or /update)"
    );
  });
}

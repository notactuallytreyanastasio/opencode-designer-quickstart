import { chromium } from "playwright";
import { join } from "path";
import { mkdirSync } from "fs";

// ---------------------------------------------------------------------------
// Screenshot Script
//
// Takes a screenshot of a specific component section on the showcase page.
// Usage: bun run .opencode/scripts/screenshot.ts <component-id> [--full-page]
//
// Examples:
//   bun run .opencode/scripts/screenshot.ts datepicker
//   bun run .opencode/scripts/screenshot.ts loading-button
//   bun run .opencode/scripts/screenshot.ts data-table
//   bun run .opencode/scripts/screenshot.ts all            # screenshots every section
//   bun run .opencode/scripts/screenshot.ts all --full-page # full page screenshot
// ---------------------------------------------------------------------------

const SHOWCASE_URL = "http://localhost:4000/showcase";
const SCREENSHOTS_DIR = join(import.meta.dir, "..", "..", "screenshots");
const THEMES = ["light", "dark"] as const;

async function ensureServerRunning(): Promise<boolean> {
  try {
    const res = await fetch(SHOWCASE_URL);
    return res.ok;
  } catch {
    return false;
  }
}

async function screenshotComponent(
  componentId: string,
  fullPage: boolean = false,
): Promise<string[]> {
  const serverUp = await ensureServerRunning();
  if (!serverUp) {
    console.error(
      `ERROR: Phoenix server not running at ${SHOWCASE_URL}. Start it first.`,
    );
    process.exit(1);
  }

  mkdirSync(SCREENSHOTS_DIR, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const savedPaths: string[] = [];

  try {
    for (const theme of THEMES) {
      const context = await browser.newContext({
        viewport: { width: 1280, height: 900 },
        colorScheme: theme === "dark" ? "dark" : "light",
      });
      const page = await context.newPage();

      // Set theme attribute for DaisyUI
      await page.goto(SHOWCASE_URL, { waitUntil: "networkidle" });
      await page.evaluate(
        (t) => document.documentElement.setAttribute("data-theme", t),
        theme,
      );
      // Brief pause for theme to apply
      await page.waitForTimeout(300);

      if (componentId === "all" && fullPage) {
        // Full page screenshot
        const path = join(SCREENSHOTS_DIR, `showcase-${theme}-full.png`);
        await page.screenshot({ path, fullPage: true });
        savedPaths.push(path);
        console.log(`  saved: ${path}`);
      } else if (componentId === "all") {
        // Screenshot each section individually
        const sections = await page.$$("[id$='-section']");
        for (const section of sections) {
          const id = await section.getAttribute("id");
          if (!id) continue;
          const name = id.replace("-section", "");
          const path = join(SCREENSHOTS_DIR, `${name}-${theme}.png`);
          await section.screenshot({ path });
          savedPaths.push(path);
          console.log(`  saved: ${path}`);
        }
      } else {
        // Screenshot a specific component section
        const sectionId = componentId.endsWith("-section")
          ? componentId
          : `${componentId}-section`;

        const section = await page.$(`#${sectionId}`);
        if (!section) {
          console.error(
            `ERROR: Section #${sectionId} not found on the page.`,
          );
          await context.close();
          continue;
        }

        const path = join(SCREENSHOTS_DIR, `${componentId}-${theme}.png`);
        await section.screenshot({ path });
        savedPaths.push(path);
        console.log(`  saved: ${path}`);
      }

      await context.close();
    }
  } finally {
    await browser.close();
  }

  return savedPaths;
}

// -- Main -------------------------------------------------------------------

const args = process.argv.slice(2);
const componentId = args[0];
const fullPage = args.includes("--full-page");

if (!componentId) {
  console.error("Usage: bun run screenshot.ts <component-id|all> [--full-page]");
  console.error("");
  console.error("Examples:");
  console.error("  bun run screenshot.ts datepicker");
  console.error("  bun run screenshot.ts loading-button");
  console.error("  bun run screenshot.ts all");
  console.error("  bun run screenshot.ts all --full-page");
  process.exit(1);
}

console.log(`Screenshotting: ${componentId} (both themes)`);
const paths = await screenshotComponent(componentId, fullPage);

if (paths.length > 0) {
  console.log(`\nDone! ${paths.length} screenshot(s) saved to screenshots/`);
} else {
  console.error("\nNo screenshots were saved.");
  process.exit(1);
}

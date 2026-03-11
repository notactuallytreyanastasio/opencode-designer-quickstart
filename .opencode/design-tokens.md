# Design Tokens

Reference for the two DaisyUI themes configured in this project.
All values are from `assets/css/app.css`.

---

## Light Theme (default) -- "Phoenix Orange"

| Token | Value | Description |
|---|---|---|
| `--color-base-100` | `oklch(98% 0 0)` | Page background, near-white |
| `--color-base-200` | `oklch(96% 0.001 286.375)` | Card/section background |
| `--color-base-300` | `oklch(92% 0.004 286.32)` | Borders, dividers |
| `--color-base-content` | `oklch(21% 0.006 285.885)` | Default text, near-black |
| `--color-primary` | `oklch(70% 0.213 47.604)` | **Warm orange** -- buttons, links, accents |
| `--color-primary-content` | `oklch(98% 0.016 73.684)` | Text on primary bg |
| `--color-secondary` | `oklch(55% 0.027 264.364)` | Muted blue-gray |
| `--color-secondary-content` | `oklch(98% 0.002 247.839)` | Text on secondary bg |
| `--color-accent` | `oklch(0% 0 0)` | Black |
| `--color-accent-content` | `oklch(100% 0 0)` | White (on black accent) |
| `--color-neutral` | `oklch(44% 0.017 285.786)` | Neutral gray |
| `--color-neutral-content` | `oklch(98% 0 0)` | Text on neutral bg |
| `--color-info` | `oklch(62% 0.214 259.815)` | Blue, informational |
| `--color-success` | `oklch(70% 0.14 182.503)` | Green, positive states |
| `--color-warning` | `oklch(66% 0.179 58.318)` | Amber/orange, caution |
| `--color-error` | `oklch(58% 0.253 17.585)` | Red, errors/destructive |

**Radius & sizing**: `--radius-box: 0.5rem`, `--radius-field: 0.25rem`, `--border: 1.5px`

---

## Dark Theme -- "Elixir Purple"

| Token | Value | Description |
|---|---|---|
| `--color-base-100` | `oklch(30.33% 0.016 252.42)` | Page background, dark blue-gray |
| `--color-base-200` | `oklch(25.26% 0.014 253.1)` | Card/section background, darker |
| `--color-base-300` | `oklch(20.15% 0.012 254.09)` | Borders, dividers, darkest |
| `--color-base-content` | `oklch(97.807% 0.029 256.847)` | Default text, near-white |
| `--color-primary` | `oklch(58% 0.233 277.117)` | **Vivid purple** -- buttons, links |
| `--color-primary-content` | `oklch(96% 0.018 272.314)` | Text on primary bg |
| `--color-secondary` | `oklch(58% 0.233 277.117)` | Same vivid purple |
| `--color-secondary-content` | `oklch(96% 0.018 272.314)` | Text on secondary bg |
| `--color-accent` | `oklch(60% 0.25 292.717)` | Lighter purple accent |
| `--color-accent-content` | `oklch(96% 0.016 293.756)` | Text on accent bg |
| `--color-neutral` | `oklch(37% 0.044 257.287)` | Dark neutral |
| `--color-neutral-content` | `oklch(98% 0.003 247.858)` | Text on neutral bg |
| `--color-info` | `oklch(58% 0.158 241.966)` | Blue, informational |
| `--color-success` | `oklch(60% 0.118 184.704)` | Teal-green, positive |
| `--color-warning` | `oklch(66% 0.179 58.318)` | Amber, caution |
| `--color-error` | `oklch(58% 0.253 17.585)` | Red, errors |

**Radius & sizing**: same as light theme

---

## DaisyUI Component Classes Quick Reference

### Layout
- `card` + `card-body` -- bordered container with padding
- `collapse` + `collapse-arrow` -- expandable sections
- `divider` -- horizontal rule with optional text
- `drawer` -- side panel layout
- `navbar` -- top navigation bar

### Buttons
- `btn` -- base button
- `btn-primary` / `btn-secondary` / `btn-accent` / `btn-neutral` -- color variants
- `btn-info` / `btn-success` / `btn-warning` / `btn-error` -- semantic variants
- `btn-ghost` / `btn-outline` / `btn-link` -- style variants
- `btn-sm` / `btn-lg` / `btn-xs` -- size variants
- `btn-circle` / `btn-square` -- shape variants
- `btn-disabled` -- disabled state

### Data Display
- `table` + `table-zebra` -- striped table
- `badge` -- small label/tag
- `badge-primary` / `badge-success` / `badge-warning` / `badge-error` / `badge-ghost` -- badge colors
- `stat` -- statistic display block
- `avatar` -- user image container
- `kbd` -- keyboard key indicator

### Feedback
- `alert` -- notification banner
- `loading` + `loading-spinner` / `loading-dots` / `loading-ring` -- loading indicators
- `loading-sm` / `loading-md` / `loading-lg` -- loading sizes
- `progress` -- progress bar
- `tooltip` -- hover tooltip
- `toast` -- floating notification

### Forms
- `input` -- text input
- `select` -- dropdown select
- `textarea` -- multi-line input
- `checkbox` -- checkbox
- `toggle` -- switch toggle
- `range` -- slider
- `file-input` -- file upload
- `input-bordered` / `input-primary` -- input variants

### Modifiers
- `shadow-lg` / `shadow-md` / `shadow-sm` -- shadow depths
- `bg-base-200` / `bg-base-300` -- background levels
- `text-base-content/60` -- text with opacity
- `opacity-30` -- element opacity
- `gap-1` / `gap-2` / `gap-4` -- flexbox/grid gaps

### Theme-Aware Patterns

Always prefer semantic DaisyUI classes over raw Tailwind colors:
- Use `btn-primary` not `bg-orange-500` -- it adapts to light/dark theme
- Use `text-base-content` not `text-gray-900` -- it adapts to theme
- Use `bg-base-200` not `bg-gray-100` -- it adapts to theme
- Use `badge-success` not `bg-green-500 text-white` -- it adapts to theme

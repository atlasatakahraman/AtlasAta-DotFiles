# AtlasAta Caelestia Fidelity

A warm, earthy light theme for Spotify via [Spicetify](https://spicetify.app). Preserves the default Spotify layout with the **Caelestia** design system palette — parchment backgrounds, deep umber accents, and a refined text hierarchy for a reading-friendly, premium listening experience.

## Screenshot

> Screenshot will be added soon.

## Color Palette

| Element            | Hex       | Role                        |
| :----------------- | :-------- | :-------------------------- |
| `text`             | `#1c1b1a` | Primary text                |
| `subtext`          | `#4a473e` | Secondary / muted text      |
| `main`             | `#fdf8f5` | Main background             |
| `sidebar`          | `#f7f3f0` | Sidebar background          |
| `player`           | `#f2edea` | Player bar background       |
| `card`             | `#ece7e4` | Card / hover surface        |
| `selected-row`     | `#e8e2d7` | Selected row highlight      |
| `button`           | `#3b3628` | Primary button accent       |
| `button-active`    | `#524d3d` | Active button state         |
| `button-disabled`  | `#ccc6bb` | Disabled / seekbar track    |
| `tab-active`       | `#3b3628` | Active tab indicator        |
| `notification`     | `#3b3628` | Toast background            |
| `notification-error` | `#ba1a1a` | Error toast background   |

## Extended Palette

The `user.css` includes **70+ CSS custom properties** (`--caelestia-*`) covering:

- **5-level surface hierarchy** — lowest through highest
- **Primary / Secondary / Tertiary** color families with on-color and container variants
- **Text hierarchy** — text, subtext1, subtext0, overlay2–0
- **14 accent colors** — rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
- **Semantic colors** — error, success, link, positive, negative, neutral
- **Design tokens** — transitions (fast/normal/slow), border radii (sm/md/lg/xl)

## Features

- 🎨 **Default layout** — No structural CSS changes, pure color refinement
- 🌿 **Warm light palette** — Easy on the eyes with earthy, natural tones
- 📜 **Thin styled scrollbars** — Blends with the warm surface palette
- ✨ **Subtle transitions** — Smooth hover/active states on buttons, cards, and rows
- 🎯 **Accessible focus rings** — Visible keyboard navigation with primary accent
- 🔔 **Polished notifications** — Rounded toasts with warm shadows

## Installation

### From the Theme Folder

1. Copy the `CaelestiaFidelity` folder to your Spicetify themes directory:

   **Linux / macOS:**
   ```bash
   cp -r CaelestiaFidelity ~/.config/spicetify/Themes/
   ```

   **Windows (PowerShell):**
   ```powershell
   Copy-Item -Recurse CaelestiaFidelity "$env:APPDATA\spicetify\Themes\"
   ```

2. Set the theme and color scheme:
   ```bash
   spicetify config current_theme CaelestiaFidelity color_scheme CaelestiaFidelity
   ```

3. Apply:
   ```bash
   spicetify apply
   ```

### From the ZIP

1. Extract `CaelestiaFidelity.zip`
2. Follow the steps above starting from step 1

## Info

### CaelestiaFidelity

Part of the **AtlasAta Caelestia** design system — a multi-application color palette for terminals, browsers, desktop environments, and music players.

By [@atlasatakahraman](https://github.com/atlasatakahraman)

## License

MIT

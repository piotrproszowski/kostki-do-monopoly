# Kostki do Monopoly - AI Coding Instructions

## Project Overview

Standalone, framework-free 3D dice roller web application with no build step. Pure HTML/CSS/JS + optional Python HTTP server for local testing.

## Architecture

### No-Framework Philosophy

- **Zero dependencies**: Vanilla JS, no bundler, no transpilation
- **Direct browser execution**: Open `index.html` or serve via Python HTTP server
- **Single responsibility per file**: `index.html` (structure), `style.css` (3D visuals), `script.js` (dice logic)

### 3D Rendering Approach

- **CSS 3D transforms** create dice illusion (NOT Canvas/WebGL)
- Each die is a 6-face cube with `.face` divs positioned via `translateZ(50px)` + rotations
- Dots are `.dot` divs positioned in 3x3 grid (9 positions, selectively visible per face)
- Face-to-number mapping in `diceFaces` object (e.g., face 1 = center dot only)

### State Management Pattern

```javascript
// Global state (acceptable for this scope)
let currentDice1 = 1;
let currentDice2 = 1;

// Update flow: rollBothDice() → setTimeout(800ms) → updateDiceDisplay() → updateResults()
```

## Development Workflows

### Running Locally

```bash
# Preferred method (custom server with network access)
npm start  # or python3 server.py

# Alternative (basic HTTP server)
npm run serve  # or python3 -m http.server 8000
```

**Custom server benefits** (`server.py`):

- Auto-opens browser after 1.5s delay
- Shows network IP for mobile testing (same WiFi required)
- No-cache headers for instant CSS/JS updates during dev

### Testing Changes

1. Save file → browser auto-reloads if using live-server (not default setup)
2. Otherwise, manual `Cmd+R` refresh (cache disabled by server)
3. Test on mobile via network IP (output by `server.py`)

## Project-Specific Conventions

### Polish Language in UI

- All user-facing text is **Polish** (button labels, README, comments-in-UI)
- Code internals (variables, functions) remain **English** per clean code principles
- Example: `<button>Rzuć kostkami!</button>` but `function rollBothDice()`

### Animation Timing Contract

- `rolling` class triggers 0.8s CSS animation (defined in `@keyframes roll`)
- JavaScript `setTimeout(800)` **MUST** match CSS duration to avoid flicker
- Disable button during animation to prevent race conditions

### Dice Face Mapping (Critical)

Standard die opposite faces sum to 7:

```javascript
const faceNumbers = {
  front: 1,
  back: 6, // opposite faces
  right: 2,
  left: 5,
  top: 3,
  bottom: 4,
};
```

**Do not change** without recalculating all dot positions in `diceFaces`.

### Event Handling Pattern

Multiple trigger methods for accessibility:

- Button click
- Keyboard: Space/Enter (via `handleKeyPress`)
- Touch/click on dice itself (mobile UX)
- Double-click on dice (power user feature)

All route through single `rollBothDice()` function (DRY principle).

## Common Modification Scenarios

### Adding Sound Effects

Uncommented stub exists in `script.js`:

```javascript
// function playRollSound() {
//   const audio = new Audio('roll-sound.mp3');
```

1. Add `.mp3` file to root directory
2. Uncomment function
3. Call from `rollBothDice()` before `setTimeout`

### Changing Animation Speed

Modify **both** locations:

- CSS: `.dice.rolling { animation: roll 0.8s ease-out; }`
- JS: `setTimeout(() => { ... }, 800);`

### Responsive Breakpoints

Single breakpoint at `768px` (tablet/mobile):

- Reduces dice size from 100px → 80px
- Adjusts `translateZ` from 50px → 40px accordingly
- Stacks result display vertically

## Deployment

### GitHub Pages (Recommended)

```bash
# No build step required - push to gh-pages branch
git subtree push --prefix . origin gh-pages
```

Set repository homepage in `package.json` for correct URLs.

### Static Hosting (Vercel/Netlify)

- Root directory: `/`
- Build command: (none)
- Output directory: `/`
- Deploy entire repo as-is

## Debugging Tips

### Dice Not Showing Correct Numbers

1. Check `diceFaces` object matches face numbering
2. Verify `rotations` object in `updateDiceDisplay()` shows correct face
3. Use browser DevTools 3D view: Inspect → Layers tab

### Animation Glitches

- Ensure `transform-style: preserve-3d` on `.dice` element
- Parent containers must not use `overflow: hidden` (breaks 3D context)
- Check `perspective` value on `body` (1000px default)

### Mobile Touch Not Working

- iOS Safari requires `touchstart` handler (already implemented)
- Add `touch-action: manipulation` to `.dice` if gestures interfere

## Files You Should Rarely Touch

- `package.json`: Only update if adding actual npm dependencies (none currently)
- `.devcontainer/`: GitHub Codespaces config (external to app logic)
- `server.py`: Production-ready unless changing ports/headers

## Performance Notes

- No performance bottlenecks expected (DOM manipulation is minimal)
- Animation runs on GPU via CSS transforms (efficient)
- Avoid adding `await` in animation loop - breaks timing contract

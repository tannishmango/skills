# HTML Walkthrough Patterns

Structural patterns for building multi-section interactive walkthrough artifacts. These are implementation building blocks — they say nothing about visual design, which is always subject-specific.

## Contents

- [File Structure](#file-structure) - The skeleton every walkthrough shares
- [Section Navigation](#section-navigation) - Sidebar, top nav, and progress tracking
- [Section Switching](#section-switching) - JS pattern for showing/hiding sections
- [Interactive Components](#interactive-components) - Quizzes, toggles, reveals, builders
- [Copyable Outputs](#copyable-outputs) - Making generated content copyable
- [Delivery](#delivery) - File naming and opening

---

## File Structure

Every walkthrough is a single HTML file with this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <!-- fonts from Google Fonts CDN or similar -->
  <!-- all CSS inline in <style> tag -->
</head>
<body>
  <!-- sticky header with title and progress -->
  <header>...</header>

  <!-- two-column layout: nav + main -->
  <div class="layout">
    <nav>...</nav>      <!-- section list with active/done states -->
    <main>...</main>    <!-- section panels, one active at a time -->
  </div>

  <!-- all JS inline in <script> tag at bottom -->
</body>
</html>
```

No external JS frameworks required. Vanilla JS is sufficient and preferred for simplicity.

If a section needs richer interactivity (e.g., a live code editor, a chart), CDN-loaded libraries are acceptable. Always use a pinned CDN URL, never `latest`.

## Section Navigation

### Sidebar Pattern (recommended for 5+ sections)

```html
<nav class="nav">
  <!-- optional group labels -->
  <div class="nav-group-label">Overview</div>

  <!-- nav items: active, done, pending states -->
  <div class="nav-item active" onclick="goTo(0)">
    <span class="nav-indicator"></span>
    Section Title
  </div>
  <div class="nav-item done" onclick="goTo(1)">...</div>
  <div class="nav-item" onclick="goTo(2)">...</div>
</nav>
```

Nav items should have three visual states:
- **Active**: currently visible section
- **Done**: visited, not current
- **Pending**: not yet visited

### Progress Bar

A thin bar at the top of the content area showing how far through the walkthrough the user is. Update it in `goTo()`.

```js
function updateProgress() {
  const pct = Math.round((visited.size / totalSections) * 100);
  document.getElementById('progress-fill').style.width = pct + '%';
}
```

### Prev/Next Buttons

Every section should have navigation buttons at the bottom. The first section has only "Next", the last has only "Back" (or "Start Over").

## Section Switching

```js
let currentSection = 0;
const totalSections = N; // set to actual count
const visited = new Set([0]);

function goTo(n) {
  // hide current
  document.getElementById(`section-${currentSection}`).classList.remove('active');
  document.getElementById(`nav-${currentSection}`).classList.remove('active');
  document.getElementById(`nav-${currentSection}`).classList.add('done');

  // show new
  currentSection = n;
  visited.add(n);
  document.getElementById(`section-${n}`).classList.add('active');
  document.getElementById(`nav-${n}`).classList.add('active');
  document.getElementById(`nav-${n}`).classList.remove('done');

  updateProgress();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}
```

CSS for section visibility:

```css
.section { display: none; }
.section.active { display: block; }
```

Add a subtle entrance animation to `.section.active` for polish:

```css
.section.active {
  animation: fadeIn 0.2s ease;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

## Interactive Components

These are the building blocks for interactive moments. Adapt their visual style to your design — the logic is what matters.

### Scenario Quiz (click to check answer)

```html
<div class="scenario" onclick="checkScenario(this, true)">
  <div class="check-indicator"></div>
  <div class="scenario-text">Scenario description here</div>
</div>
```

```js
function checkScenario(el, isCorrect) {
  // clear other selections
  document.querySelectorAll('.scenario').forEach(s => s.classList.remove('selected'));
  el.classList.add('selected');

  // show feedback
  const fb = document.getElementById('scenario-feedback');
  fb.style.display = 'block';
  fb.className = isCorrect ? 'feedback correct' : 'feedback incorrect';
  fb.textContent = isCorrect ? '✓ Correct. ...' : '✗ Not quite. ...';
}
```

### Reveal / Audit Pattern (hidden content shown on button click)

```html
<div class="reveal-target" id="reveal-1" style="display: none;">
  <!-- content revealed after button click -->
</div>
<button onclick="reveal('reveal-1')">Run Audit → Reveal</button>
```

```js
function reveal(id) {
  document.getElementById(id).style.display = 'block';
}
```

### Toggle Builder (include/exclude sections, live preview updates)

```html
<div class="toggle-row" data-key="context" onclick="toggleItem(this)">
  <div class="toggle-check"></div>
  <div class="toggle-label">Section Name</div>
  <div class="toggle-note">always included</div>
</div>
```

```js
function toggleItem(el) {
  el.classList.toggle('included');
  el.querySelector('.toggle-check').textContent =
    el.classList.contains('included') ? '✓' : '';
  updatePreview();
}

function updatePreview() {
  const included = [...document.querySelectorAll('.toggle-row.included')]
    .map(el => el.dataset.key);
  document.getElementById('preview').innerHTML = buildPreview(included);
}
```

### Preset Switcher (small / medium / large, or other discrete modes)

```html
<div class="preset-btn active" onclick="setPreset('small')">Small</div>
<div class="preset-btn" onclick="setPreset('medium')">Medium</div>
<div class="preset-btn" onclick="setPreset('large')">Large</div>
```

```js
function setPreset(size) {
  document.querySelectorAll('.preset-btn').forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');

  const configs = {
    small:  ['a', 'b'],
    medium: ['a', 'b', 'c'],
    large:  ['a', 'b', 'c', 'd', 'e']
  };

  document.querySelectorAll('.toggle-row').forEach(row => {
    const include = configs[size].includes(row.dataset.key);
    row.classList.toggle('included', include);
    row.querySelector('.toggle-check').textContent = include ? '✓' : '';
  });

  updatePreview();
}
```

### Expandable Cards (click to expand detail)

```html
<div class="card" onclick="this.classList.toggle('expanded')">
  <div class="card-title">Card Title</div>
  <div class="card-summary">Brief summary always visible</div>
  <div class="card-detail"><!-- shown only when expanded --></div>
</div>
```

```css
.card-detail { display: none; }
.card.expanded .card-detail { display: block; }
```

## Copyable Outputs

When a section produces output the user might want to copy (a prompt, a command, a config):

```html
<div class="output-block">
  <div class="output-header">
    <span class="output-label">Generated Output</span>
    <button class="copy-btn" onclick="copyOutput(this, 'output-content')">Copy</button>
  </div>
  <pre id="output-content">...</pre>
</div>
```

```js
function copyOutput(btn, targetId) {
  const text = document.getElementById(targetId).textContent;
  navigator.clipboard.writeText(text).then(() => {
    btn.textContent = 'Copied!';
    setTimeout(() => { btn.textContent = 'Copy'; }, 2000);
  });
}
```

## Delivery

### File naming

```
/tmp/[subject-slug]-walkthrough.html
```

Examples:
- `/tmp/give-me-a-prompt-walkthrough.html`
- `/tmp/alembic-migrations-walkthrough.html`
- `/tmp/conflict-detection-walkthrough.html`

### Opening

```bash
open /tmp/[subject-slug]-walkthrough.html
```

Tell the user the file path explicitly so they can reopen it.

### File size

A typical walkthrough is 600–1500 lines of HTML. Under 600 lines often means too little interactivity. Over 2000 lines often means the design is over-engineered or the scope is too large.

If the subject is very large, consider splitting into multiple walkthroughs rather than one enormous file.

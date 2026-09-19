# 🎨 design.md — UI/UX Guidelines & Visual Design System

## SafeLife Design System

### 1. Overall UI Stack

| Share | Style | Where it applies |
|---|---|---|
| **80%** | **Material 3** | Foundation of the whole product: components, color roles, typography, shapes, navigation, motion |
| **15%** | **Minimalism** | Visual philosophy layered on top: whitespace, restraint, one focus per screen, especially in emergency and triage flows |
| **5%** | **Bento Dashboard** | **Admin Analytics only** (Flutter Web): modular tile grid for KPIs, charts, and the heat map |

**How to read the percentages:** they describe how much each style shapes the look and feel, not screen counts. Material 3 is the default answer to any design question. Minimalism decides *what to leave out*. Bento is a special layout used in one place and must not leak into the user-facing mobile app.

**Conflict rule (highest priority first):**
1. Emergency clarity and speed (never sacrificed for style)
2. Material 3
3. Minimalism
4. Bento

### 2. UI/UX Principles

- Calm and clear. Users may be panicking, so **fewer taps and fewer words**.
- The **SOS button is always reachable** from the home screen and large enough to hit under stress.
- **Bangla-first** interface with an English toggle.
- Mobile-first and one-hand friendly, with critical actions in the thumb zone.
- Accessibility: touch targets of at least 48 dp, scalable text, high contrast, haptic/voice feedback, and simple wording for elderly users.
- Every emergency flow has a visible **Cancel / I'm safe** action and a **countdown** to prevent false alarms.
- A persistent, obvious indicator whenever location is being shared, with a one-tap stop.
- Reusable components (SOS button, risk badge, contact card, status timeline, KPI tile) and consistent behavior across screens.

### 3. Material 3 Guidelines (80%)

Material 3 is the base for every screen, in both the mobile app and the admin panel.

**Foundation**
- Enable it with `useMaterial3: true` and generate the palette with `ColorScheme.fromSeed(seedColor: ...)`. Support light and dark schemes.
- Use **color roles** (`primary`, `onPrimary`, `primaryContainer`, `secondary`, `tertiary`, `surface`, `surfaceContainer*`, `error`, `outline`) instead of hard-coded hex values in widgets.
- Use the M3 type scale (`displaySmall` to `labelSmall`) through `Theme.of(context).textTheme`.
- Use M3 shapes: rounded corners (about 12–28 dp depending on component) and tonal surfaces instead of heavy shadows.

**Component choices**

| Need | Use |
|---|---|
| Primary bottom navigation | `NavigationBar` (mobile) |
| Large-screen navigation (admin) | `NavigationRail` or `NavigationDrawer` |
| Main actions | `FilledButton`; secondary: `FilledButton.tonal`, `OutlinedButton`; tertiary: `TextButton` |
| SOS button | Custom large circular/rounded element built from M3 tokens (`error` / `errorContainer` roles) |
| Lists, contacts, history | `Card` (filled/outlined), `ListTile` |
| Selections in triage | `SegmentedButton`, `Chip`, `Switch`, `RadioListTile` |
| Feedback | `SnackBar`, `AlertDialog` / bottom sheets; progress: `LinearProgressIndicator`, `CircularProgressIndicator` |
| Top bars | `AppBar` / `SliverAppBar.medium` |

**Motion:** short, purposeful M3 transitions (200–300 ms). Reduce or skip animation in critical flows, and respect the system "reduce motion" setting.

### 4. Minimalism Guidelines (15%)

Minimalism is applied as discipline on top of Material 3, not as a separate look.

- **One primary action per screen.** In emergency flows, the primary action is the only prominent element.
- **Generous whitespace** and a clear vertical rhythm (8 dp spacing grid).
- **Restrained color:** neutral surfaces by default; the brand color and the alert colors are reserved for actions and risk states, so they carry meaning when they appear.
- **Low elevation, flat surfaces**, no decorative gradients, textures, or stacked shadows.
- **Few, familiar icons** with short labels. Do not use icons alone for critical actions.
- **Plain, short copy** in Bangla and English. Instructions in emergency screens should read in a glance.
- **Progressive disclosure:** show detail (medical history, alert logs) only when the user asks for it.
- Triage questionnaires: **one question per screen** or a very short list, big tap targets, no clutter.
- Remove any element that does not help the user act, understand, or feel safe.

### 5. Bento Dashboard for Admin Analytics (5%)

Used **only** for the admin analytics dashboard (Flutter Web). It is not used in the user app or the responder panel.

**Concept:** a modular grid of rounded tiles of different sizes, each answering one question at a glance.

**Layout (desktop, 4-column grid):**

```
┌──────────┬──────────┬──────────┬──────────┐
│ Total    │ Active   │ Patients │ Avg Resp.│
│ Users    │ Users    │          │ Time     │
├──────────┴──────────┼──────────┴──────────┤
│                     │ Cases by Type       │
│  Emergency Heat Map │ Safety|Heart|Stroke │
│        (2x2)        ├─────────────────────┤
│                     │ Response Time Trend │
├─────────────────────┼──────────┬──────────┤
│ Incident by Area    │ Alert    │ Ambulance│
│ (2x1)               │ Levels   │ Status   │
└─────────────────────┴──────────┴──────────┘
```

**Tile content**

| Tile | Size | Content |
|---|---|---|
| Total / Active users, Registered patients | 1x1 | Big number, small trend delta |
| Average response time | 1x1 | Big number, unit, trend |
| Emergency heat map | 2x2 (hero) | Map with density overlay (implementation **TBD**) |
| Cases by type | 2x1 | Women Safety vs. Heart Attack vs. Stroke: bar or donut |
| Response time trend | 2x1 | Line chart over time |
| Incident distribution by area | 2x1 | Ranked bars or small map |
| Alert levels | 1x1 | Counts for Levels 1–4 |
| Ambulance status | 1x1 | Requested / Accepted / On The Way / Arrived counts |

**Bento rules**
- Tiles use M3 surface roles (`surfaceContainer` / `surfaceContainerLow`), a **20–24 dp corner radius**, **12–16 dp gaps**, and **no heavy shadows**.
- Each tile has one clear title, one main visualization, and generous inner padding (16–20 dp). No more than two data ideas per tile.
- The hero tile (heat map) is the largest; KPI tiles stay small and quiet.
- Responsive: 4 columns on wide screens, 2 columns on tablets, 1 column on narrow screens. Tiles reflow rather than shrink.
- Use color sparingly and consistently: the same case type has the same color in every tile.
- Charts use accessible palettes with labels or patterns, not color alone.
- Implementation options (**verify current versions**): a `GridView` with a custom layout or a staggered-grid package, plus a charting package such as `fl_chart`.
- Admin data must be **anonymized or aggregated**. No personal medical details appear on dashboard tiles.

### 6. Color & Theme

Generated from one seed via `ColorScheme.fromSeed`. The values below are the intended results and can be adjusted freely.

| Role | Suggested value |
|---|---|
| Seed / Primary | `#C2185B` (deep rose, safety and care) |
| Secondary | `#1565C0` (calm blue, medical trust) |
| Accent / Tertiary | `#FF6F00` (attention) |
| Background / Surface | `#FFF8F9` / `#FFFFFF` (dark: `#121212` / `#1E1E1E`) |
| Text | `#1B1B1F` primary, `#5F6368` secondary (inverted in dark mode) |
| Success | `#2E7D32` |
| Warning | `#F9A825` |
| Error / Critical | `#D32F2F` |

**Risk-level colors** (custom `ThemeExtension`): Low = green, Medium = yellow, High = orange, Critical = red. **Never rely on color alone.** Pair each with a label or icon.

**Minimalism note:** the primary rose color appears only on key actions (SOS, primary buttons, active navigation). Most of the interface stays neutral.

**Light & Dark theme support:** yes (light, dark, and system). Verify contrast in both.

### 7. Fonts & Typography

- **Primary font family:** Hind Siliguri (Bangla and Latin support). Fallback: Noto Sans Bengali / Roboto.
- **Mapped to the M3 type scale:**

| Use | M3 style | Size / weight |
|---|---|---|
| Screen title (H1) | `headlineMedium` | 28 sp, Bold |
| Section title (H2) | `titleLarge` | 22 sp, SemiBold |
| Card title (H3) | `titleMedium` | 18 sp, SemiBold |
| Body | `bodyLarge` | 16 sp, Regular, line height 1.4–1.5 |
| Caption / helper | `bodySmall` | 13 sp, Regular |
| Buttons / labels | `labelLarge` | 14–16 sp, Medium |
| Dashboard KPI numbers | `displaySmall` | 36 sp, Bold (admin only) |

- **Emergency screens:** minimum 18 sp for key instructions.
- **Font weights:** Regular (400), Medium (500), SemiBold (600), Bold (700).
- Respect the system font-scale setting up to at least 1.5x without breaking layouts.

### 8. Memory (UI Preferences)

Persist locally (`shared_preferences`) and sync to the profile where useful:
- Theme mode (light / dark / system)
- Language (Bangla / English)
- Large-text / accessibility mode
- SOS trigger preferences (countdown length, shake enabled, etc.)
- Last-used tab and layout state
- Admin dashboard: preferred date range and tile visibility (optional)
- Onboarding and permission-explainer completion

### 9. Design Checklist

Before merging any UI work, confirm:
- [ ] Uses Material 3 components and color roles (no stray hex values)
- [ ] One clear primary action; no unnecessary elements (minimalism)
- [ ] Bento layout used **only** in the admin analytics dashboard
- [ ] Touch targets are at least 48 dp; text scales; contrast passes in light and dark
- [ ] Works in Bangla and English without overflow
- [ ] Emergency flows have Cancel / I'm safe, a countdown, and a location-sharing indicator
- [ ] Risk states use color plus text or icon

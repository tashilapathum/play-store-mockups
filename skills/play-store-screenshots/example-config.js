/**
 * Example config.js for "FocusFlow" — a productivity/focus timer app.
 * Copy this to config.js in your generated project and modify it.
 *
 * This example shows:
 *  - 5 phone slides all using the standard text-top layout
 *  - Feature graphic using the gradient style
 *  - Dark theme
 *  - Copy kept in a COPY table, localized into English + Spanish
 *    (for a single-locale project, keep only the `en` block)
 */

// One row per slide: [label, headline, subtext]; fg: [headline, subtext].
// A locale only needs the rows that differ — missing ones fall back to en.
const COPY = {
  en: {
    "hero":          ["FOCUS DIFFERENTLY", "Deep work.\nNo distractions.", ""],
    "flow-sessions": ["FLOW SESSIONS", "25 minutes.\nThen breathe.", "Pomodoro-style sessions built around how your brain actually works."],
    "stats":         ["WEEKLY INSIGHTS", "See what's\nactually working.", "Visualize your focus streaks and spot your most productive hours."],
    "block":         ["DISTRACTION BLOCKING", "The apps\ncan wait.", "Block any app during focus sessions. One tap, no willpower needed."],
    "widgets":       ["HOME SCREEN WIDGETS", "Your streak.\nRight there.", ""],
    fg:              ["Focus like you mean it", "Available on Google Play"],
  },
  es: {
    "hero":          ["CONCÉNTRATE DISTINTO", "Trabajo profundo.\nCero distracciones.", ""],
    "flow-sessions": ["SESIONES DE FLUJO", "25 minutos.\nLuego respira.", "Sesiones tipo Pomodoro pensadas para cómo funciona tu mente."],
    "stats":         ["RESUMEN SEMANAL", "Mira qué\nfunciona de verdad.", "Visualiza tus rachas y tus horas más productivas."],
    "block":         ["BLOQUEO DE APPS", "Las apps\npueden esperar.", "Bloquea cualquier app mientras te concentras. Un toque y listo."],
    "widgets":       ["WIDGETS", "Tu racha.\nAhí mismo.", ""],
    fg:              ["Concéntrate de verdad", "Disponible en Google Play"],
  },
};

// Builds { locale: value } maps from COPY. Names must not clash with index.html globals.
const copyMap = (id, i) => Object.fromEntries(
  Object.entries(COPY).filter(([, c]) => c[id]).map(([loc, c]) => [loc, c[id][i]])
);
const slideOf = (id, base) => ({ id, ...base,
  label: copyMap(id, 0), headline: copyMap(id, 1), subtext: copyMap(id, 2) });


const config = {
  app: {
    name: "FocusFlow",
    icon: "screenshots/app-icon.png",
  },

  brand: {
    primary: "#7C3AED",       // violet — dominant brand color
    secondary: "#4F46E5",     // indigo — gradient partner
    background: "#0D0D0D",    // near-black canvas
    surface: "#1A1A2E",       // dark surface for cards
    text: "#FFFFFF",          // white headlines
    textMuted: "#A1A1AA",     // muted labels
    accent: "#F59E0B",        // amber — CTA / highlight
  },

  theme: "dark-bold",

  device: {
    color: "black",
  },

  slides: [
    slideOf("hero",          { layout: "text-top", screenshot: "screenshots/screen-timer.png" }),
    slideOf("flow-sessions", { layout: "text-top", screenshot: "screenshots/screen-sessions.png" }),
    slideOf("stats",         { layout: "text-top", screenshot: "screenshots/screen-stats.png" }),
    slideOf("block",         { layout: "text-top", screenshot: "screenshots/screen-block.png" }),
    slideOf("widgets",       { layout: "text-top", screenshot: "screenshots/screen-widget.png" }),
  ],

  featureGraphic: {
    headline: copyMap("fg", 0),
    subtext:  copyMap("fg", 1),
    style: "gradient",
  },

  tablet: {
    enabled: false,
    sizes: ["10-inch"],
  },

  locales: ["en", "es"],
};

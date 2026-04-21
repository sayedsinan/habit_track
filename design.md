# App Design System & Color Palette

This document outlines the core design tokens and color palette for the application, specifically inspired by the clean, sophisticated, and warm aesthetics of the Claude UI.

## Overview
The design prioritizes readability, minimalism, and a warm, inviting feel. Instead of using harsh pure blacks (`#000000`), pure whites (`#FFFFFF`), or cold blue-grays, this palette utilizes **warm grays**, **eggshell/paper tones**, and a **signature terracotta/peach accent** to create a highly premium and comfortable reading experience.

---

## 🎨 Color Palette

### 🌞 Light Mode
_A bright, clean, and paper-like aesthetic._

| Token | Color (Hex) | Description |
| :--- | :--- | :--- |
| **Background (Main)** | `#FDFBF7` | A very warm, off-white (paper-like) background for the main canvas. |
| **Surface (Cards/Inputs)**| `#F3F2EF` | A slightly darker warm gray for cards, input fields, and elevated elements. |
| **Primary Text** | `#1F1E1C` | Soft charcoal. High contrast for readability without the harshness of pure black. |
| **Secondary Text** | `#696763` | Muted, warm medium-gray for subtitles, timestamps, and placeholder text. |
| **Border / Divider** | `#E6E4DF` | Subtle borders to separate content without creating visual noise. |
| **Primary Accent** | `#DA7756` | The signature terracotta/peach accent color for primary buttons and active states. |
| **Secondary Accent / Link**| `#3A6962` | A sophisticated muted sage/teal used for secondary actions or links. |
| **Error / Destructive** | `#B73D35` | A muted red for error states to maintain the sophisticated muted tone. |

### 🌙 Dark Mode
_A deep, warm, and comfortable dark aesthetic. Avoids pure black._

| Token | Color (Hex) | Description |
| :--- | :--- | :--- |
| **Background (Main)** | `#1F1E1C` | The primary background. Matches the primary text of light mode. Very dark warm charcoal. |
| **Surface (Cards/Inputs)**| `#2D2C2A` | Elevated surface background for inputs, chat bubbles, and modal cards. |
| **Primary Text** | `#F3F2EF` | Warm off-white. Easy on the eyes for long reading sessions. |
| **Secondary Text** | `#A3A19D` | Lighter warm gray for secondary information and placeholders. |
| **Border / Divider** | `#3C3B39` | Subtle delineations between dark components. |
| **Primary Accent** | `#E28A6F` | A slightly brightened terracotta/peach for better contrast on dark backgrounds. |
| **Secondary Accent / Link**| `#588B83` | Lightened sage/teal for dark mode readibility. |
| **Error / Destructive** | `#D45B53` | Softened red for standard contrast accessibility. |

---

## 📐 Typography & Spacing

To fully match the sophisticated feel:

- **Typefaces:** 
  - *Primary (Sans-serif):* `Inter`, `System UI`, or `Geist` (for extreme clarity and modern feel).
  - *Serif (Optional for long reading):* `Fraunces` or `Merriweather` (for a more editorial look, often used in Claude's long-form output).
- **Line Height:** 
  - Standardize on `1.5` or `1.6` for optimal text readability.
- **Border Radius:** 
  - Use smooth, subtle rounding. e.g., `8px` or `12px` for cards and input fields. Avoid overly pill-shaped buttons unless specifically desired for a friendly touch.
- **Shadows:** 
  - Keep drop shadows exceptionally faint and diffuse, preferring borders or slight background color contrast to delineate hierarchy.

---

## 🧩 Usage Guidelines

1. **Hierarchy over decoration:** Use the accent color sparingly. Only apply the `Primary Accent` to the most important call-to-action (CTA) on the screen (e.g., the "Send" button in a chat interface, or "Save" in a form).
2. **Embrace whitespace:** Ensure there is ample padding around text blocks and between distinct sections. Clutter destroys the premium feel.
3. **Soft transitions:** When switching themes or hovering over elements, use subtle CSS transitions (`transition: all 0.2s ease-in-out;`) to make the interface feel responsive and alive.

---
name: PSUT Internship Portal
description: Campus in motion, purposeful workspaces.
colors:
  primary: "#003e73"
  blue: "#0078b5"
  sky: "#76c8ec"
  night: "#071f32"
  ink: "#102838"
  paper: "#ffffff"
  editorial-background: "#f7f8f8"
  editorial-pale: "#d7ecf6"
  editorial-muted: "#506779"
  workspace-background: "#f3f6f8"
  workspace-pale: "#e7f2f8"
  workspace-muted: "#526777"
  workspace-line: "#e3e9ed"
  student-background: "#f5f6f8"
  student-ink: "#17232d"
  student-muted: "#62717e"
  student-line: "#dde3e9"
typography:
  display:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "clamp(42px, 4.7vw, 68px)"
    fontWeight: 750
    lineHeight: 1.08
    letterSpacing: "-0.04em"
  headline:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "clamp(36px, 4.5vw, 64px)"
    fontWeight: 750
    lineHeight: 1.12
    letterSpacing: "-0.04em"
  workspace-title:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "clamp(27px, 2.5vw, 39px)"
    fontWeight: 750
    lineHeight: 1.2
    letterSpacing: "-0.035em"
  body:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.65
  workspace-body:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.6
rounded:
  navigation: "12px"
  tile: "14px"
  media: "16px"
  pill: "40px"
spacing:
  editorial-gutter: "clamp(24px, 5vw, 80px)"
  editorial-section: "clamp(72px, 8vw, 128px)"
  workspace-gutter: "36px"
  panel-gap: "20px"
  student-rail: "84px"
  student-card-gap: "18px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.paper}"
    rounded: "{rounded.pill}"
    padding: "11px 18px"
  button-primary-hover:
    backgroundColor: "{colors.blue}"
  button-light:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.primary}"
    rounded: "{rounded.pill}"
    padding: "11px 18px"
  button-light-hover:
    backgroundColor: "{colors.sky}"
    textColor: "{colors.primary}"
  workspace-panel:
    backgroundColor: "{colors.paper}"
    rounded: "{rounded.media}"
    padding: "24px"
---

# Design System: PSUT Internship Portal

## Homepage implementation, 22 October 2026

The public homepage now follows the user-selected Armenia Travel reference: a full-width campus film with deep lower curves, a low editorial title, dark photographic campus chapter, pill role tabs, white rounded photograph cards, sky opportunity chapter, a rotating draggable fact deck, campus cinema and an oversized PSUT footer. The existing role workspaces keep the system documented below.

`Content/campus-home.css` is the public-page visual authority, loaded only by `Public.Master`. It keeps PSUT navy `#003e73`, blue `#0078b5`, sky `#76c8ec`, pale `#d7ecf6`, night `#071f32`, paper and Manrope. Its equal outer gutter is 22px on phones and 3.1vw on desktops. The user specifically requested repeated draggable cards; these are intentional exceptions to generic card-avoidance guidance. Neutral photographic scrims are used for legibility, with no decorative gradients, glass or resting shadows.

The short enhanced campus loop is pausable; the full film loads in an accessible dialog on request. The film retains its panoramic aspect ratio, uses cover cropping and a high-resolution campus poster, and pauses when offscreen, in a hidden tab or behind a dialog. Reduced motion disables autoplay, reveals and decorative transforms while retaining all content and native scrolling. Photograph and fact rails support pointer dragging, native touch, arrows and keyboard movement. Full source attribution and video limitations are in `HOMEPAGE.md`.

## Overview

**Creative North Star: "Campus in motion, purposeful workspaces"**

Extend the supplied PSUT identity into student, company, academic and coordinator workspaces. Authentic campus photography, institutional blue and self-hosted Manrope connect a generous editorial homepage to compact operational screens. The homepage expresses movement through film framing and draggable editorial rails; authenticated workspaces bring the same identity to decisions and records.

The visual authority is the supplied PSUT homepage and its existing design document. Armenia Travel informs scroll choreography and editorial rails; Dashboard V14 informs compact navigation and information density. Neither reference replaces PSUT branding.

**Key Characteristics:**

- Authentic PSUT photography and institutional blue.
- Generous curved media with pill actions.
- Compact, shared role workspaces with clear data hierarchy.
- Motion that supports exploration and respects reduced motion.

## Colors

Primary navy anchors institutional content, selected navigation and principal actions. Blue provides hover emphasis and visible focus. Sky highlights photographic chapters and light action states. Night supports dark editorial photography; ink carries readable operational text.

Paper is the shared panel surface. Editorial and workspace background, pale and muted tokens intentionally retain their observed contextual values. Workspace line separates table rows, shell regions and metrics. Semantic pending, approved and rejected badges also use written status labels; color is supplementary.

**The PSUT Identity Rule.** Keep the institutional palette and authentic university imagery across roles; role differences come from content and permissions.

## Typography

Use the self-hosted variable Manrope asset (`PSUTInternship/Assets/manrope-variable.ttf`, weights 200–800), with Arial and sans-serif fallbacks. Bold, tightly tracked headings balance their wraps; body text has comfortable leading. The legacy font file is not the body-font authority.

Editorial display and headline roles belong to the homepage. Workspace titles use the smaller operational scale; section headings, metrics and table content create the next levels of hierarchy. Numeric metrics and decision totals use tabular numerals. Desktop workspace navigation uses 13px labels, top pills 12px, and table cells 12px; responsive overrides are contextual rather than a new global type scale.

## Layout

The homepage uses the editorial gutter and section spacing, photographic splits and horizontal fact, opportunity and photo rails. At 760px editorial splits stack and rails remain horizontally scrollable. Keep page overflow contained within each rail.

Company, academic and coordinator workspaces retain the shared 216px sidebar, 94px top bar and 1560px main width. At 1150px the sidebar contracts to 78px. At 680px it becomes a toggleable drawer below the sticky top bar. The student workspace is a separate route family with an 84px icon rail and no top navbar. At 640px its rail becomes a fixed bottom navigation with visible labels. Main content is a flexible card grid; dashboard metrics shift from four columns to two, then overview panels stack.

The workspace first viewport pairs a role-specific heading with an authentic campus photo summary, a decision panel and current metrics. Activity tables use internal horizontal overflow when needed. This is the shared workspace pattern, not a requirement for unrelated editorial pages.

The student dashboard borrows the supplied Vertix reference's quiet gray canvas, bordered white cards and compact activity hierarchy, while keeping PSUT blue, campus imagery and actual application data. Opportunities, My applications, Apply and Profile share the same rail, font and card system. Card entrances are staggered and subtle; charts reveal once on load. Reduced motion removes all entrance effects. Forms retain their real field labels, saved student prefilling and submission actions.

## Elevation & Depth

Prefer photographic scale, tonal layering and quiet borders over raised cards. Ordinary workspace panels are flat. Account menus and mobile drawers use soft shadows to explain overlap; the homepage tilted fact deck uses restrained offset shadow. Preserve readable overlays on photographs instead of placing raw text over uncontrolled image detail.

## Shapes

Use gently curved media and panels, smaller navigation and action-tile corners, and pill actions. The hero film changes from full bleed to a broad rounded inset frame during scroll. The exact animated radius belongs to that film behavior, not the static media token. Keep outlined SVG icons consistent: rounded strokes, no unrelated icon family.

## Components

Primary actions are navy pills with a blue hover state. A light variant supports dark photographs and gains sky on hover. Workspace primary actions have a minimum 44px height; the editorial primary pill is 52px high with 15px 24px padding. Focus uses a visible blue outline with offset, independent of hover.

Side navigation combines icons and text, pale hover surfaces and a navy active state. Top section pills use an ink active state on a pale track. Selection must be conveyed programmatically. The mobile drawer stays hidden until opened; opening moves focus to its first navigation item and Escape closes it and returns focus to the menu control. Search and status filtering sit with activity tables; searches have accessible names and result counts. Neutral, pending, approved and rejected tags retain text labels. White cards carry opportunities, people or decisions without decorative shadows.

Film framing is scroll linked: the full-bleed campus film contracts horizontally and vertically, its corners broaden and its scale settles. Playback remains pausable. Reduced motion presents a stable rounded film without the scroll travel. Fact, opportunity, photo and quick-action rails support mouse dragging, native touch panning with touch-action:auto and keyboard movement; keep explicit rail controls where supplied. Dragging suppresses accidental link activation only after horizontal movement begins. Reduced motion removes inertial rail travel and decorative transforms.

**The Truthful Workspace Rule.** Render authenticated records, real zero states and explicit unavailable states. A dash indicating unavailable access is not a zero. Label isolated preview data as illustrative; do not borrow its figures for production.

## Do's and Don'ts

- Do preserve authentic PSUT campus photography and supplied logo assets.
- Do retain a clear hierarchy from role-specific heading to current decisions and activity.
- Do provide visible keyboard focus, accessible names and reduced-motion behavior.
- Do distinguish unavailable data, genuine empty data and illustrative previews.
- Don't invent statistics to fill a dashboard.
- Don't introduce a separate brand or palette for each role.
- Don't require dragging or animation to reach essential content.
- Don't hide keyboard-focusable controls with opacity alone.


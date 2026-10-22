# PSUT homepage QA — 22 October 2026

final result: passed

Scope: the public Web Forms homepage, adapted to the user's Armenia Travel visual reference with PSUT identity, authentic campus media, transitions and draggable cards. It is an adaptation for a university internship portal, with different content and actions from a tourism site.

## Visual evidence

Reference: `.taste-skill/reference/desktop-fold.jpg` and `desktop-page-01.jpg` through `desktop-page-03.jpg`.
Implementation: `.taste-skill/final/` contains the fold and complete page contact sheets at 1440 × 900, 768 × 1024 and 390 × 844, captured from the actual IIS Express route. Every final screenshot was opened for review.
Combined comparisons: `.taste-skill/comparison-final.jpg` compares both first screens at 1440 × 900; `.taste-skill/comparison-cards.jpg` compares the rotating fact decks at equal screenshot scale. The focused deck comparison checks the card treatment that the user specifically requested. The source has an active cookie banner in its full-page capture; this is irrelevant to the requested PSUT design and was not recreated.

The broad curved film, low title/support composition, pale-to-dark chapter transition, generous rounded image cards and rotating deck carry over. PSUT palette, Manrope, official imagery, internship copy, role tabs, portal actions and footer are deliberate content/brand adaptations.

## Fixes and verification

The first inspection identified 8 failure categories: long headings, a caption classified as an eyebrow, a coloured video scrim, a menu character classified as an emoji, clipped tablet card text and small mobile labels. The final build removes the caption, uses a neutral legibility scrim, shortens headings, uses a CSS menu mark / text control, rearranges tablet opportunity cards and raises readable labels. Final screenshots confirm all headings fit at most two lines and the phone action stays on the first screen.

| Check | Original committed homepage | Final homepage |
|---|---:|---:|
| Inspector failure categories | 12 | 0 |
| Inspector warning categories | 11 | 5, documented |
| Longest headline, desktop | 6 lines | 2 lines |
| Longest headline, tablet | 5 lines | 2 lines |
| Longest headline, phone | 5 lines | 2 lines |
| Distinct moving elements, desktop | 9 | 30 |
| Distinct moving elements, tablet | 8 | 24 |
| Distinct moving elements, phone | 9 | 23 |

The baseline was rendered from the committed homepage against its unchanged existing visual assets; the final capture used the real Web Forms application. Both sets remain available in `.taste-skill/before/` and `.taste-skill/final/`.

The project builds with MSBuild on .NET Framework. The only reported build warning was the pre-existing `Company/Create_task.aspx.cs` method hiding `Page.IsValid`. IIS Express serves both the homepage and login with HTTP 200. JavaScript syntax and source lint pass; final responsive inspection returns **0 FAIL, 5 WARN**. No runtime JavaScript errors appeared in the final page's browser log.

Interaction checks in the browser:

- Company tab changes the selected tab, photo, copy and real workspace action.
- Next-card arrow moves the journey rail by about 450px.
- A real mouse drag moves it another 316px without activating its card link.
- Search for `cyber` returns the matching placement and announces one result.
- An unmatched search shows a clear empty state; Clear search restores all three placements and input focus.
- Opportunity preview opens correctly; its sign-in action reaches the existing `UIMS Login` page.
- Campus film opens in a dialog; Escape closes it and restores focus to its trigger.
- Film playback pauses when the hero is offscreen; a visible play/pause control is supplied.

Responsive screenshots were checked for typography, framing, palette, image crop / quality, copy completeness, card affordances and primary action placement. Reduced-motion behavior and native touch scrolling are implemented; no claim of manual physical-device testing is made. Direct local `file:` navigation was blocked by the browser tool's URL policy; the HTML export was checked through local HTTP instead.

## Remaining P3 / content notes

No P0, P1 or P2 issue remains within this homepage scope. The five inspector warnings are documented in `.taste-skill/critique.md`: repeated cards and horizontal overflow are explicitly requested; off-canvas card edges affect geometric counts; exact font-size consolidation is optional cleanup. Self-review: design 8, usability 8, creativity 7, content 7.5, weighted 7.8 / 10.

The upscaled 1920 × 484 video remains limited by a 960 × 242 original; true HD footage would improve it. The public company placements remain clearly labelled samples. Full sources, media rights, processing details and integration guidance are in `HOMEPAGE.md`. No authentication, database permissions or unrelated role-page behavior was changed for this task.

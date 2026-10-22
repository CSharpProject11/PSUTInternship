# Homepage visual QA

Reference: Armenia.travel homepage and the screenshots supplied in this conversation. Implementation: PSUT internship homepage at `http://localhost:55571/?role=student`.

At a desktop viewport of roughly 1272 × 712, both pages use an edge-to-edge video hero, navigation over the film, fixed rounded bottom corners, and a pill contact control at the lower right. The PSUT page uses its own campus footage, logo, content, and blue palette. At a mobile viewport of roughly 515 × 650, the hero remains full height and the navigation opens as a dropdown below the header.

Verified: the mobile menu opens and closes, Escape closes it and returns focus to its trigger, a menu link closes it and smooth-scrolls to its destination, and the page renders the opportunity and draggable facts rails. The changed JavaScript passes `node --check`. Hover and focus states for cards, and reduced-motion behavior, are defined in the homepage stylesheet.

No P0, P1, or P2 issues found in the checked states.

final result: passed

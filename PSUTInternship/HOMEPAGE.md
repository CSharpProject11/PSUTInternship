# PSUT homepage

The homepage adapts the visual composition and interaction vocabulary of [Armenia Travel](https://armenia.travel/) to PSUT's internship portal. It uses the existing C# Web Forms project, local Bootstrap, Manrope and official PSUT media. No JavaScript framework or CDN is required.

Design direction: Colour chapters, seed `1373396552`, with no redraws. The user's reference overrides the dealt hero and section geometry. The idea turns PSUT's walking lane, welcome auditorium and graduation courtyard into a student's next-chapter journey; the live interaction is its draggable photo / fact decks and role selector. Final self-critique: design 8, usability 8, creativity 7, content 7.5; weighted 7.8 / 10. The largest remaining limitation is the low-resolution original video. See `design-qa.md` for the final inspection evidence and retained warnings.

## Files

- `PSUTInternship/Default.aspx`: the actual homepage; existing `Default.aspx.cs` remains its code-behind.
- `PSUTInternship/Public.Master`: document, metadata, Bootstrap and public-page assets.
- `PSUTInternship/Content/campus-home.css`: scoped homepage layout, responsive composition and reduced motion.
- `PSUTInternship/Scripts/campus-home.js`: video playback, subtle scroll scaling, entrances, rail controls and accessible film dialog.
- Existing `interactions.js`: pointer dragging, inertia, touch scrolling and keyboard movement.
- Existing `wellington.js` and `portal.js`: role tabs, explicitly illustrative public opportunity previews and the existing login action.
- `PSUTInternship/index.html`: equivalent HTML preview, exported from the same Web Forms source. Run `node tools/preview-home.mjs --export` from the repository root after editing the ASPX or master. Authentication requires the real Web Forms application.

## Run

Open `PSUTInternship.slnx` in Visual Studio and run the Web Forms project through IIS Express. For the homepage alone, run `node tools/preview-home.mjs` from the repository root and open `http://127.0.0.1:4173/`. The static preview deliberately does not emulate authentication or server pages. The HTML export uses relative local asset paths. Direct `file:` opening could not be verified because the browser tool's URL policy allows only HTTP(S); verification used local HTTP and the real IIS Express application.

## Media

All photography is from PSUT's official media gallery. The existing local originals are reused; no Armenia photographs, footage, logos or fonts were copied. The footer credits PSUT and links to its gallery. Individual photographers and open licences were not supplied by the source; rights remain with their owners.

| Local file | Title / subject | Creator / source | Rights |
|---|---|---|---|
| `psut-aerial.jpg` | Campus entrance and gardens | PSUT, [Campus album](https://www.psut.edu.jo/ar/media/get-photos/5) | PSUT; no open licence asserted |
| `psut-rooftop.jpg` | Campus rooftop panorama | PSUT, [Campus album](https://www.psut.edu.jo/ar/media/get-photos/5) | PSUT; no open licence asserted |
| `psut-walkway.jpg` | Campus walking lane | PSUT, [Campus album](https://www.psut.edu.jo/ar/media/get-photos/5) | PSUT; no open licence asserted |
| `psut-entrance.jpg` | Campus entrance at night | PSUT, [Campus album](https://www.psut.edu.jo/ar/media/get-photos/5) | PSUT; no open licence asserted |
| `psut-graduation.jpg` | Graduation ceremony | PSUT, [Campus album](https://www.psut.edu.jo/ar/media/get-photos/5) | PSUT; no open licence asserted |
| `psut-students.jpeg` | New-student gathering | PSUT, [New students album](https://www.psut.edu.jo/ar/media/get-photos/21) | PSUT; no open licence asserted |
| `psut-community.jpeg` | Student welcome event | PSUT, [New students album](https://www.psut.edu.jo/ar/media/get-photos/21) | PSUT; no open licence asserted |
| `psut-welcome.jpeg` | Welcome auditorium | PSUT, [New students album](https://www.psut.edu.jo/ar/media/get-photos/21) | PSUT; no open licence asserted |
| `psut-2025.mp4` | PSUT campus film, original | PSUT, [official source](https://www.psut.edu.jo/uploads/2025/02/psut-2025.mp4) | PSUT; no open licence asserted |
| `psut-campus-enhanced.mp4` | Full campus film, web enhancement | Derived from that PSUT film | Same rights as original |
| `psut-campus-loop.mp4` | Short campus opening | Derived from that PSUT film | Same rights as original |

The original video is 960 × 242 at approximately 60 fps. The enhanced full film is 1920 × 484 at 30 fps, with mild temporal denoising, Lanczos scaling and restrained sharpening. The short hero loop is about 2 MB. Both are H.264/yuv420p with fast-start metadata. Upscaling improves presentation but does not restore missing original detail. A genuine higher-resolution PSUT master would be the next quality improvement. The full film loads on demand in its dialog; the short loop is pausable and does not autoplay when reduced motion is requested.

The existing `PSUT-MEDIA-SOURCES.json` records original image URLs. No stock photographs, generated campus images, drawings standing in for photos, fabricated testimonials, rankings or institutional statistics were added.

## Content and integration

The public ProgressSoft, Umniah and Mawdoo3 placements are existing illustrative data, clearly labelled as samples. Their seats, dates, durations and companies require replacement or live binding before publication as real vacancies. The live-opportunity button and all workspace links lead to existing ASP.NET routes and retain their authentication requirements. Email and telephone use actual PSUT contact details. No form pretends to send a message.

## Validation

The .NET Framework project builds; the pre-existing `Create_task.IsValid` hiding warning remains unrelated to this homepage. IIS Express returns HTTP 200 for `Default.aspx` and `Login.aspx`. Browser interaction checks cover tabs, card arrows and mouse dragging, sample search, film opening, Escape and focus restoration. Responsive inspection and visual critique are recorded under the repository's `.taste-skill/` directory and in `design-qa.md`.

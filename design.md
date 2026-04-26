Swift Design Requirements

Design Intent

The new application should feel like a native, offline-ready music-production handbook: polished, readable, lightweight, and organized like a book rather than a generic data browser. It should preserve the current Logic Pro.Guru identity and SwiftUI-native interaction patterns.

Required Visual Language





Preserve the Logic Pro.Guru brand name and compact gradient logo mark from [ios/LogicProCheatSheets/LogicProCheatSheets/Views/SheetListView.swift](/Users/levensailor/Dev/logicpro-cheatsheets/ios/LogicProCheatSheets/LogicProCheatSheets/Views/SheetListView.swift).



Use rounded rectangles as the primary shape language:





Hero cards: large radius around 24.



Category/content cards: radius around 16-18.



Small tiles: radius around 12-14.



Use native SwiftUI materials and system colors rather than custom heavy styling:





.background for primary cards.



.thinMaterial for soft grouped content surfaces.



.secondary for subtitles and supporting text.



.quaternary strokes for subtle borders.



Keep the palette friendly and restrained: blue, green, and purple accents should appear in the logo and home hero gradient, with most content surfaces staying neutral and readable.



Use icons sparingly but consistently: chapter emoji icons for content identity, SF Symbols for native controls, ratings, status, and utility UI.

Navigation Requirements





Use NavigationSplitView as the main shell on iPad/macOS-style layouts.



Sidebar must include:





A branded home row with LogoMark and Logic Pro.Guru.



Grouped chapter sections: Tracking, DAW, Mixing, Mastering, Reference.



Content version/status footer from ContentRepository.



Refresh action in the toolbar.



Selecting no chapter should show the home page, not the first chapter.



Chapter detail views must include previous/next navigation cards at the bottom.

Home Page Requirements





Home should be visually appealing and book-like, not a plain list.



Preserve these sections:





Hero card with logo, app name, large headline, short value proposition, and primary start button.



Adaptive category grid with five category cards.



“How to use the book” guidance card.



Category cards should use adaptive grids, large emoji icons, bold titles, concise subtitles, and chapter counts.

Mixing Navigation Requirements





The Mixing category in the sidebar should remain a 4-column square/tile grid rather than row links.



Tiles should be equal size, white when inactive, accent-colored when selected, and text must wrap without truncation.



Keep labels compact and chapter-like, using navItems labels where available.

Detail Page Requirements





Chapter detail pages should use:





A soft material header with emoji, large bold title, subtitle, and summary.



A vertical stack with consistent spacing around 16.



Reusable section components rather than one-off chapter layouts.



All content sections should render inside SectionCard-style containers with rounded backgrounds and subtle strokes.



Preserve the existing content contract from [ios/LogicProCheatSheets/LogicProCheatSheets/Models/ContentModels.swift](/Users/levensailor/Dev/logicpro-cheatsheets/ios/LogicProCheatSheets/LogicProCheatSheets/Models/ContentModels.swift): chain, cards, table, checklist, image, plugin-chooser, and tolerant unknown sections.

Section Rendering Requirements





Cards should use adaptive grids with a minimum width around 220, rounded material subcards, headline titles, and checkmark labels.



Tables should support the existing optional layouts:





standard: row cards with visible column labels.



compact: compact key/value tiles.



detailCards: visual cards where repeated subtitles become SF Symbol icon chips instead of verbose labels.



Plugin chooser should include:





Instrument/bus picker.



Plugin type picker.



Contextual result summary.



Five-star rating with half-star support, mapping 10/10 to 5 stars and 9/10 to 4.5 stars.



Empty or unsupported content should fail gracefully with a native unavailable/update-needed state.

Content and Architecture Requirements





Do not hardcode chapter copy in views. Views should render the shared content bundle.



Preserve the offline-first content architecture:





Bundled seed content in Resources/SeedContent.json.



Remote content from the web bundle.



Local cache via app support storage.



SHA verification before accepting remote content.



Keep schema changes backward-tolerant. Optional fields are preferred over new required fields.



Unknown future section types should not crash the app.

Typography and Layout Requirements





Use system fonts and SwiftUI semantic styles:





.largeTitle.bold() for major chapter/home headlines.



.title, .title2, .title3.bold() for section hierarchy.



.headline for card titles and primary labels.



.subheadline and .caption for supporting details.



Preserve generous padding but avoid wasted space in dense reference sections.



Prefer adaptive grids over fixed device-specific layouts.



Keep long text readable with clear hierarchy and avoid truncating chapter labels.

Accessibility Requirements





Every image/icon-only affordance must have an accessibility label when the text meaning is not visible.



Buttons and navigation tiles must expose meaningful labels.



Rating stars must expose a readable rating, such as 4.5 out of 5 stars.



Do not rely on color alone for selected state or meaning.

Agent Working Rules





Reuse existing components before creating new ones: SectionCard, CardsSectionView, TableSectionView, PluginChooserSectionView, HomeView, and MixingChapterGrid.



Keep styling native and simple. Avoid custom drawing unless it reinforces the existing brand.



If adding a new content presentation, first check whether it can be expressed as an optional field on the existing schema.



Any visual change should be applied consistently across web-shared content and Swift rendering when the content model is affected.



After implementation, verify decoding, cached seed content compatibility, and representative screens: Home, Mixing sidebar, one detail chapter, dense table section, and Plugins chooser.
// scholia — a universal template for typeset lecture notes / study scripts.
//
// Wraps the `ilm` book template with a shared set of theorem-like environments
// (see `theorems.typ`) and sensible defaults for multi-chapter notes.
//
//   #import "@preview/scholia:0.1.0": *
//
//   #show: scholia.with(
//     title: [My Notes],
//     authors: "Ada Lovelace",
//     bibliography-file: "refs.bib",
//   )
//
//   #let (definition, theorem, proof, ..) = scholia-theorems()

#import "@preview/ilm:2.1.1": ilm
#import "@preview/great-theorems:0.1.2": great-theorems-init
#import "theorems.typ": scholia-theorems

// Default cover page, mirroring the "notes on X" academic-script look.
#let default-cover(title, subtitle, authors, institution) = {
  let author-line = if type(authors) == array { authors.join(", ") } else { authors }
  align(left + horizon)[
    #text(2em)[*#title*]
    #if subtitle != none [
      #v(0em)
      #text(1.5em)[#subtitle]
    ]
    #if institution != none [
      #v(-0.5em)
      #text(1.2em)[#institution]
    ]
    #v(0.5em)
    #text(1.2em)[#author-line]
  ]
}

// Opening header for a chapter file: a numbered chapter heading, an optional
// subtitle, and an optional description set off from the body.
//
// Because the heading is a real level-1 heading, it drives the table of
// contents and the running header, so a chapter can be named after its source
// ("A Second Course in Probability") rather than after its contents.
//
//   #scholia-chapter(
//     [A Second Course in Probability],
//     subtitle: [Ross and Pekoz, 2nd edition],
//     description: [My summary of the book, chapter by chapter.],
//   )
//
// Named arguments:
//   subtitle     — a line under the title, e.g. the source being summarised
//   description  — a short blurb, ruled off from the body text
//   break-before — start the chapter on a new page (default false)
//   depth        — heading depth relative to the current offset (default 1)
//   level        — an absolute heading level, overriding `depth`
//   subtitle-size / description-size — text sizes
//   accent       — colour of the subtitle and of the rule under the blurb
#let scholia-chapter(
  title,
  subtitle: none,
  description: none,
  break-before: false,
  level: auto,
  depth: 1,
  subtitle-size: 1.1em,
  description-size: 0.95em,
  accent: gray.darken(25%),
) = {
  // The first chapter under a work or division follows its headings on the
  // same page; later ones start a page of their own.
  if break-before { pagebreak(weak: true) }

  // `level` is absolute and ignores `set heading(offset: ..)`, so headings are
  // emitted by `depth` unless an absolute level is asked for explicitly.
  if level == auto { heading(depth: depth, title) } else { heading(level: level, title) }

  if subtitle != none {
    block(above: -0.2em, below: 0.9em, text(
      size: subtitle-size,
      fill: accent,
      style: "italic",
    )[#subtitle])
  }

  if description != none {
    block(
      width: 100%,
      above: 0.6em,
      below: 1.2em,
      inset: (bottom: 0.7em),
      stroke: (bottom: 0.5pt + accent.lighten(50%)),
      text(size: description-size, fill: accent)[#description],
    )
  }
}

// --- structure above the chapter -------------------------------------------
//
// A compendium that collects several sources needs levels above the chapter:
//
//   1  area      "Probability"
//   2  work      "A Second Course in Probability"     (the source)
//   3  division  "Summary"                            (or Exercises, Notes)
//   4  chapter   "Measure Theory and Laws of ..."     (the source's own chapter)
//   5  section   "Probability Spaces"
//
// These three helpers emit *absolute* levels, so they are unaffected by the
// heading offset that shifts an included chapter's own markup into place.

// An area opens a page of its own, with nothing on it but its title.
#let scholia-area(title) = {
  pagebreak(weak: true)
  v(1fr)
  align(center, heading(level: 1, title))
  v(1fr)
  pagebreak(weak: true)
}

// A work and its divisions are not title pages: they sit directly above the
// first chapter, and their descriptions read as ordinary body text.
#let scholia-work(title, description: none) = {
  pagebreak(weak: true)
  heading(level: 2, title)
  if description != none { description }
}

#let scholia-division(title, description: none) = {
  heading(level: 3, title)
  if description != none { description }
}

// Heading numbering that hides the structural levels while still counting
// them. NOTE: never hide them with `set heading(numbering: none)` instead —
// unnumbered headings do not step the heading counter, which silently zeroes
// every block's address.
#let scholia-heading-numbering(structural-levels, pattern) = (..nums) => {
  let parts = nums.pos()
  if parts.len() <= structural-levels {
    none
  } else {
    let local = parts.slice(structural-levels)
    // A statement placed before the chapter's first section would read "1.0".
    while local.len() > 1 and local.last() == 0 { let _ = local.pop() }
    std.numbering(pattern, ..local)
  }
}

// Running footer: the current chapter, falling back to the current work.
#let scholia-footer(work-level, chapter-level) = context {
  let page-no = counter(page).at(here()).first()
  let here-loc = here()
  let chapters = query(heading.where(level: chapter-level).before(here-loc))
  let works = query(heading.where(level: work-level).before(here-loc))
  let name = if chapters.len() > 0 {
    chapters.last().body
  } else if works.len() > 0 {
    works.last().body
  } else {
    none
  }
  grid(
    columns: (1fr, auto),
    align: (left + bottom, right + bottom),
    if name != none { text(size: 0.75em, fill: gray.darken(30%), smallcaps(name)) } else { [] },
    text(size: 0.9em, str(page-no)),
  )
}

// Local numbers are not unique across works — every work has a "Definition
// 1.1.1". A reference therefore shows the bare local number inside its own
// work, and names the work when it points outside it.
#let scholia-xref(work-level) = it => context {
  let el = it.element
  if el == none {
    it
  } else {
    let there = counter(heading).at(el.location())
    let here-addr = counter(heading).at(here())
    let same-work = (
      here-addr.len() >= work-level
        and there.len() >= work-level
        and there.slice(0, work-level) == here-addr.slice(0, work-level)
    )
    // Outside any work (contents, footer, front matter) keep the local form.
    let no-context = here-addr.len() < work-level
    if same-work or no-context {
      it
    } else {
      let works = query(heading.where(level: work-level).before(el.location()))
      if works.len() == 0 { it } else {
        [#link(el.location())[#emph(works.last().body)], #it]
      }
    }
  }
}

// Main show-rule wrapper.
//
// Named arguments:
//   title            — document title (content or string)
//   authors          — a string or array of author names
//   subtitle         — optional subtitle shown on the cover
//   institution      — optional institution / course line on the cover
//   date             — a `datetime` (default: today)
//   abstract         — abstract content
//   preface          — optional preface content
//   bibliography     — a `bibliography(...)` value, or none. Construct it in
//                      your own document so the .bib path resolves there, e.g.
//                      `bibliography: bibliography("refs.bib")`.
//   heading-numbering — heading numbering pattern (default "1.1")
//   area-size / work-size / division-size — text size of the three structural
//                      heading levels. These are applied as show rules rather
//                      than baked into the heading bodies, so they do not leak
//                      into the table of contents, which copies those bodies.
//   structural-levels — how many heading levels sit above the chapter (see
//                      `scholia-area` / `scholia-work` / `scholia-division`).
//                      0 (default) is a plain single-source document. With 3,
//                      an included chapter file's own `=` and `==` become the
//                      chapter and its sections, numbered "1" and "1.3" as if
//                      the work stood alone, while the full address is still
//                      counted underneath and used for cross-references.
//   cover-page       — override the generated cover entirely (content or none)
//   ..ilm-args       — any extra named arguments are forwarded to `ilm`
//                      (e.g. paper-size, figure-index: (enabled: true), ...)
#let scholia(
  title: [Lecture Notes],
  authors: (),
  subtitle: none,
  institution: none,
  date: datetime.today(),
  abstract: [],
  preface: none,
  bibliography: none,
  heading-numbering: "1.1",
  structural-levels: 0,
  area-size: 2.2em,
  work-size: 1.6em,
  division-size: 1.25em,
  cover-page: auto,
  ..ilm-args,
  body,
) = {
  let chapter-level = structural-levels + 1
  let cover = if cover-page == auto {
    default-cover(title, subtitle, authors, institution)
  } else {
    cover-page
  }

  show: ilm.with(
    title: title,
    authors: authors,
    date: date,
    abstract: abstract,
    preface: preface,
    bibliography: bibliography,
    cover-page: cover,
    // ilm's footer and chapter break are both hardwired to level 1, which is
    // the area once there is structure above the chapter; scholia installs its
    // own below.
    ..(if structural-levels > 0 { (footer: none, chapter-pagebreak: false) }),
    ..ilm-args,
  )

  show: great-theorems-init

  if structural-levels == 0 {
    set heading(numbering: heading-numbering)
    body
  } else {
    set heading(numbering: scholia-heading-numbering(structural-levels, heading-numbering))
    // A numbering function returning `none` still reserves the number gutter,
    // which would indent every structural heading by a phantom number.
    set heading(hanging-indent: 0pt)
    show heading.where(level: 1): set text(size: area-size)
    show heading.where(level: 2): set text(size: work-size)
    show heading.where(level: 3): set text(size: division-size)
    show ref: scholia-xref(2)
    set page(footer: scholia-footer(2, chapter-level))
    // Included chapter files write `=` for their chapter and `==` for its
    // sections; the offset drops them into place under the structure.
    set heading(offset: structural-levels)
    body
  }
}

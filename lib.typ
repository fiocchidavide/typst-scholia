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
//   level        — heading level (default 1)
//   subtitle-size / description-size — text sizes
//   accent       — colour of the subtitle and of the rule under the blurb
#let scholia-chapter(
  title,
  subtitle: none,
  description: none,
  level: 1,
  subtitle-size: 1.1em,
  description-size: 0.95em,
  accent: gray.darken(25%),
) = {
  heading(level: level, title)

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
  cover-page: auto,
  ..ilm-args,
  body,
) = {
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
    ..ilm-args,
  )

  show: great-theorems-init
  set heading(numbering: heading-numbering)

  body
}

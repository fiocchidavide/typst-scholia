// Theorem-like environments for scholia.
//
// Generalised from a personal lecture-notes preamble. Each environment is a
// coloured, left-ruled block built on `great-theorems`, sharing a single
// counter that inherits the current heading numbering (e.g. "Definition 2.3").

#import "@preview/great-theorems:0.1.2": *
// rich-counters 0.2.2 fixes a "Cannot join integer with integer" crash that
// happened whenever the document had more heading levels than the counter's
// `inherited_levels` (see `inherited-levels` in `scholia-theorems`).
#import "@preview/rich-counters:0.2.2": *

// Default styling shared by every environment. Override individual keys by
// passing a `config` dictionary to `scholia-theorems`.
#let default-config = (
  label-weight: "bold",
  label-size: 12pt,
  breakable: false,
  border-width: 1.5pt,
  inset: (left: 6pt, y: 0pt),
  name-style: "italic",
  proof-label: "Proof",
  qed-symbol: sym.square.stroked,
  // Styling of the `source` attribution shown at the right of the title line.
  source-size: 0.85em,
  source-color: gray.darken(25%),
  // Separator printed between the block number and the name.
  name-separator: [\-],
)

// Attribution for material borrowed from a source text. Pushed to the right of
// the title line; the box keeps it from breaking across two lines, and moves
// spacer and text together when the line has no room left.
#let source-tag(body, cfg) = [
  #h(1fr)#box(text(size: cfg.source-size, fill: cfg.source-color)[#body])
]

// The title line: an optional name, an optional source, or both. The separator
// before the name is printed only when there is a name to separate.
#let title-line(name, source, cfg, env-color) = {
  let styled-name = if cfg.name-style == "italic" { emph(name) } else { name }
  text(fill: env-color, size: cfg.label-size)[
    #if name != none [#cfg.name-separator #styled-name ]
    #if source != none [#source-tag(source, cfg)]
  ]
}

// A standard coloured, left-ruled environment (definition, theorem, ...).
//
// The returned function takes `title` (the statement's own name), `source` (an
// attribution, shown right-aligned on the same line), or neither.
#let standard-environment(title, counter, cfg, env-color) = {
  let block = mathblock(
    blocktitle: title,
    counter: counter,
    stroke: (left: cfg.border-width + env-color),
    inset: cfg.inset,
    breakable: cfg.breakable,
    prefix: count => text(
      fill: env-color,
      weight: cfg.label-weight,
      size: cfg.label-size,
    )[#title #count],
    titlix: line => line,
    bodyfmt: body => [\ #body],
  )
  (title: none, source: none, ..args) => block(
    title: if title == none and source == none { none } else {
      title-line(title, source, cfg, env-color)
    },
    ..args,
  )
}

// A proof environment: uncounted, with a trailing QED symbol.
#let standard-proof(cfg) = {
  let block = mathblock(
    blocktitle: cfg.proof-label,
    counter: none,
    prefix: [*#cfg.proof-label.*],
    titlix: line => line,
    suffix: [#h(1fr) #cfg.qed-symbol],
    bodyfmt: body => body,
  )
  (title: none, source: none, ..args) => block(
    title: if title == none and source == none { none } else {
      [#if title != none [ (#title)]#if source != none [#source-tag(source, cfg)]]
    },
    ..args,
  )
}

// Build the full set of environments from a colour palette and config.
//
// Returns a dictionary of ready-to-use functions:
//   definition, theorem, lemma, proposition, corollary, remark, example, proof
//
// Usage:
//   #import "@preview/scholia:0.1.0": scholia-theorems
//   #let (definition, theorem, proof, ..) = scholia-theorems()
//
// Arguments:
//   inherited-levels — how many heading levels the block number inherits.
//     2 (default) numbers blocks as chapter.section, e.g. "Definition 2.3".
//     1 numbers them per chapter, e.g. "Definition 2". Deeper heading nesting
//     than this value works fine thanks to rich-counters >= 0.2.2.
//   colors — override any environment colour, e.g. (theorem: purple).
//   config — override styling keys for every environment, e.g.
//     (border-width: 2pt).
//   env-config — override styling keys for one environment only, e.g.
//     (example: (border-width: 0pt, inset: 0pt)) to set examples flush with
//     the body text. Keys not given fall back to `config`, then to
//     `default-config`.
#let scholia-theorems(
  inherited-levels: 2,
  colors: (:),
  config: (:),
  env-config: (:),
) = {
  let cfg = default-config + config
  let cfg-for = name => cfg + env-config.at(name, default: (:))

  // The shared counter, rebuilt per call so `inherited-levels` takes effect.
  let mathcounter = rich-counter(
    identifier: "scholia-mathblocks",
    inherited_levels: inherited-levels,
  )

  let palette = (
    definition: blue.darken(70%),
    theorem: red.darken(60%),
    lemma: red.darken(60%),
    proposition: red.darken(60%),
    corollary: green.darken(70%),
    remark: gray.darken(40%),
    example: eastern.darken(20%),
  ) + colors

  let env = (key, label) => standard-environment(
    label,
    mathcounter,
    cfg-for(key),
    palette.at(key),
  )

  (
    definition: env("definition", "Definition"),
    theorem: env("theorem", "Theorem"),
    lemma: env("lemma", "Lemma"),
    proposition: env("proposition", "Proposition"),
    corollary: env("corollary", "Corollary"),
    remark: env("remark", "Remark"),
    example: env("example", "Example"),
    proof: standard-proof(cfg-for("proof")),
  )
}

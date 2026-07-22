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
  name-style: "italic",
  proof-label: "Proof",
  qed-symbol: sym.square.stroked,
)

// A standard coloured, left-ruled environment (definition, theorem, ...).
#let standard-environment(title, counter, cfg, env-color) = mathblock(
  blocktitle: title,
  counter: counter,
  stroke: (left: cfg.border-width + env-color),
  inset: (left: 6pt, y: 0pt),
  breakable: cfg.breakable,
  prefix: count => text(
    fill: env-color,
    weight: cfg.label-weight,
    size: cfg.label-size,
  )[#title #count],
  titlix: name => text(fill: env-color, size: cfg.label-size)[\- #emph(name) ],
  bodyfmt: body => [\ #body],
)

// A proof environment: uncounted, with a trailing QED symbol.
#let standard-proof(cfg) = mathblock(
  blocktitle: cfg.proof-label,
  counter: none,
  prefix: [*#cfg.proof-label.*],
  titlix: name => [ (#name)],
  suffix: [#h(1fr) #cfg.qed-symbol],
  bodyfmt: body => body,
)

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
//   config — override styling keys, e.g. (border-width: 2pt).
#let scholia-theorems(inherited-levels: 2, colors: (:), config: (:)) = {
  let cfg = default-config + config

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

  (
    definition: standard-environment("Definition", mathcounter, cfg, palette.definition),
    theorem: standard-environment("Theorem", mathcounter, cfg, palette.theorem),
    lemma: standard-environment("Lemma", mathcounter, cfg, palette.lemma),
    proposition: standard-environment("Proposition", mathcounter, cfg, palette.proposition),
    corollary: standard-environment("Corollary", mathcounter, cfg, palette.corollary),
    remark: standard-environment("Remark", mathcounter, cfg, palette.remark),
    example: standard-environment("Example", mathcounter, cfg, palette.example),
    proof: standard-proof(cfg),
  )
}

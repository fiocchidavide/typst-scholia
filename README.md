# scholia

A universal [Typst](https://typst.app) template for typeset **lecture notes and
study scripts**. It wraps the [`ilm`](https://typst.app/universe/package/ilm)
book template with a shared, colour-coded set of theorem-like environments and
sensible defaults for multi-chapter documents.

It was extracted from a personal set of university notes so the same look and
feel can be reused across courses.

![Cover page](thumbnail.png)

## Features

- Book-style layout (cover, preface, abstract, ToC, running headers) via `ilm`.
- Coloured, left-ruled environments: `definition`, `theorem`, `lemma`,
  `proposition`, `corollary`, `remark`, `example`, and `proof` (with a trailing
  QED symbol), all sharing a single counter that follows the heading numbering.
- One-line document setup with pass-through to every `ilm` option.
- Configurable numbering depth, colours, and block styling.

## Quick start

```bash
typst init @preview/scholia
```

Or, using this repository directly as a local package, copy the `template/`
contents into a new project and import the package.

### Minimal document

```typ
#import "@preview/scholia:0.1.0": *

#show: scholia.with(
  title: [My Lecture Notes],
  subtitle: [_(My notes on)_ Some Fascinating Subject],
  authors: "Your Name",
  institution: [Your University, Some Semester],
  bibliography: bibliography("refs.bib"),
)

#let (definition, theorem, proof) = scholia-theorems()

= Getting Started

#definition(title: "Inner product")[
  A symmetric, bilinear, positive-definite map $⟨dot, dot⟩$.
]

#theorem(title: "Pythagoras")[
  If $⟨x, y⟩ = 0$ then $norm(x + y)^2 = norm(x)^2 + norm(y)^2$.
]

#proof[ Expand the norm. ]
```

### Multi-chapter documents

Because `include`d files do not inherit the caller's scope, put the environment
bindings in a shared file (`environments.typ`) and import it from every chapter.
See the [`template/`](template) directory for the full layout:

```
template/
  main.typ            # document setup + chapter includes
  environments.typ    # shared theorem bindings
  chapters/
    chapter1.typ      # imports ../environments.typ
  refs.bib
```

## API

### `scholia(..)` — the document show rule

| Argument            | Default            | Description                                                        |
| ------------------- | ------------------ | ------------------------------------------------------------------ |
| `title`             | `[Lecture Notes]`  | Document title.                                                    |
| `authors`           | `()`               | A string or array of author names.                                 |
| `subtitle`          | `none`             | Cover subtitle.                                                    |
| `institution`       | `none`             | Institution / course line on the cover.                            |
| `date`              | `datetime.today()` | Document date.                                                     |
| `abstract`          | `[]`               | Abstract content.                                                  |
| `preface`           | `none`             | Preface content.                                                   |
| `bibliography`      | `none`             | Pass `bibliography("refs.bib")` (built in your document so the path resolves there). |
| `heading-numbering` | `"1.1"`            | Heading numbering pattern.                                         |
| `cover-page`        | `auto`             | Override the generated cover with your own content, or `none`.     |
| `..ilm-args`        | —                  | Any extra named arguments are forwarded to `ilm` (e.g. `footer`, `appendix`, `figure-index: (enabled: true)`). |

### `scholia-theorems(..)` — the environments

Returns a dictionary of environment functions. Destructure the ones you need.

| Argument           | Default | Description                                                                 |
| ------------------ | ------- | --------------------------------------------------------------------------- |
| `inherited-levels` | `2`     | Heading levels the block number inherits. `2` → `Definition 2.3`; `1` → `Definition 2` (per chapter). Deeper heading nesting than this value is fine. |
| `colors`           | `(:)`   | Override any environment colour, e.g. `(theorem: purple)`.                   |
| `config`           | `(:)`   | Override styling keys (`border-width`, `label-size`, `proof-label`, `qed-symbol`, …). |

```typ
#let (definition, theorem, proof) = scholia-theorems(
  inherited-levels: 1,
  colors: (theorem: purple.darken(20%)),
  config: (border-width: 2pt),
)
```

## Dependencies

- [`ilm`](https://typst.app/universe/package/ilm) `2.1.1`
- [`great-theorems`](https://typst.app/universe/package/great-theorems) `0.1.2`
- [`rich-counters`](https://typst.app/universe/package/rich-counters) `0.2.2`
  — `0.2.2` fixes a *"Cannot join integer with integer"* crash that occurred
  when a document nested headings deeper than the counter's `inherited_levels`.

## License

MIT © Davide Fiocchi

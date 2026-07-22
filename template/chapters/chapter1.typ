#import "../environments.typ": *

= Getting Started

An introductory paragraph. Cite sources with #cite(<magnus2024>) as usual.

== A first section

#definition(title: "Inner product")[
  An _inner product_ on a real vector space $V$ is a map
  $⟨ dot, dot ⟩ : V times V -> RR$ that is symmetric, bilinear, and
  positive definite.
]

#proposition(title: "Cauchy–Schwarz inequality")[
  For all $x, y in V$,
  $ abs(⟨ x, y ⟩) <= norm(x) dot norm(y). $
]

#proof[
  Expand $norm(x - t y)^2 >= 0$ as a quadratic in $t in RR$ and require a
  non-positive discriminant.
]

#theorem(title: "Pythagoras")[
  If $⟨ x, y ⟩ = 0$, then $norm(x + y)^2 = norm(x)^2 + norm(y)^2$.
]

#remark[
  Environments share one counter that follows the section numbering, so this is
  automatically labelled relative to the current chapter.
]

#example(title: "A worked example")[
  Take $V = RR^2$ with the standard inner product and verify the identities
  above for $x = (1, 0)$ and $y = (0, 1)$.
]

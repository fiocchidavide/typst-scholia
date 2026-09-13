// Shared theorem-like environments for this document.
//
// Each chapter imports this file (`#import "../environments.typ": *`) so the
// environments are available in its own scope. Tweak colours or config here in
// one place and every chapter follows.

#import "@preview/scholia:0.2.0": scholia-chapter, scholia-theorems

#let (
  definition,
  theorem,
  lemma,
  proposition,
  corollary,
  remark,
  example,
  proof,
) = scholia-theorems()

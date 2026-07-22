#import "@preview/scholia:0.1.0": *

#show: scholia.with(
  title: [My Lecture Notes],
  subtitle: [_(My notes on)_ Some Fascinating Subject],
  authors: "Your Name",
  institution: [Your University, Some Semester],
  date: datetime.today(),
  abstract: [
    Write your abstract here.
  ],
  preface: [
    #align(center + horizon)[
      A short note on why these notes exist.
    ]
  ],
  bibliography: bibliography("refs.bib"),
  // Any extra named arguments are forwarded to `ilm`, e.g.:
  // figure-index: (enabled: true),
)

#for file in (
  "chapter1.typ",
  // add more chapters here
) {
  include "chapters/" + file
}

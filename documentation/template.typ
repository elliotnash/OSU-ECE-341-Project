#let project(title: "", authors: (), team-number: "", body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(
    paper: "us-letter",
    numbering: "1",
    number-align: center,
    header: [
      #authors.join(", ")
      \
      #team-number
    ]
  )
  set text(font: "Libertinus Serif", lang: "en")

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  // Main body.
  set par(justify: true)
  show figure: set block(breakable: true)

  body
}
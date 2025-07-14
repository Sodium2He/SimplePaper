// aided by Gemini-2.5-Pro-DeepResearch
// for typst 0.13.1 (8ace67d9).

#let equation-counter = counter("chapter-equations")

#let project(
  title: "",
  authors: (),
  abstract: none,
  keywords: (),
  body,
) = {
  let zh_shusong = ("FZShuSong-Z01", "FZShuSong-Z01S")
  let zh_xiaobiansong = ("FZXiaoBiaoSong-B05", "FZXiaoBiaoSong-B05S")
  let zh_kai = ("FZKai-Z03", "FZKai-Z03S")
  let zh_hei = ("FZHei-B01", "FZHei-B01S")
  let zh_fangsong = ("FZFangSong-Z02", "FZFangSong-Z02S")
  let en_sans_serif = "CMU Sans Serif"
  let en_serif = "CMU Serif"
  let en_typewriter = "Consolas"
  let en_code = "Consolas"

  let title-font = (en_serif, ..zh_hei)
  let author-font = (en_typewriter, ..zh_fangsong)
  let body-font = (en_serif, ..zh_shusong)
  let heading-font = (en_serif, ..zh_xiaobiansong)
  let caption-font = (en_serif, ..zh_kai)
  let header-font = (en_serif, ..zh_kai)
  let strong-font = (en_serif, ..zh_hei)
  let emph-font = (en_serif, ..zh_kai)
  let raw-font = (en_code, ..zh_hei)

  set document(author: authors.map(author => author.name), title: title)
  set page(numbering: "1", number-align: center, header: align(left)[
    #set text(font: header-font)
    #title
  ])
  set heading(numbering: "1.1")
  set text(font: body-font, lang: "zh", region: "cn")
  set bibliography(style: "gb-7714-2015-numeric")

  // use first-line-indent -> all (typst PR #5768)
  // instead of blank_par (old method)
  // to avoid introducing weird line spacing
  set par(
    first-line-indent: (amount: 2em, all: true),
    justify: true,
  )

  show heading: it => box(width: 100%)[
    #set par(first-line-indent: 0em)
    #v(0.50em)
    #set text(font: heading-font)
    #if it.numbering != none { counter(heading).display() }
    #h(0.75em)
    #it.body
  ]
  show heading.where(level: 1): it => {
    equation-counter.update(1)
    box(width: 100%)[
      #set par(first-line-indent: 0em)
      #v(0.5em)
      #set align(center)
      #set heading(numbering: "一")
      #it
      #v(0.75em)
    ]
  }


  set enum(indent: 2em, numbering: "1.i.a.")
  set list(indent: 2em)

  show figure: it => [
    #v(2pt)
    #set text(font: caption-font)
    #it
    #v(2pt)
  ]

  show strong: set text(font: strong-font)
  show emph: set text(font: emph-font)

  show ref: set text(red)
  // 合并了下划线和颜色，修复了原模板中的覆盖问题
  show link: it => {
    set text(blue)
    underline(it)
  }


  show raw: set text(font: raw-font)
  show raw.where(block: true): it => {
    block(
      width: 100%,
      fill: luma(240),
      inset: 10pt,
      it,
    )
  }

  align(center)[
    #block(text(font: title-font, weight: "bold", 1.75em, title))
    #v(0.5em)
  ]


  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 12pt,
      ..slice.map(author => align(center, {
        text(12pt, author.name, font: author-font)
        if "organization" in author [
          \ #text(author.organization, font: author-font)
        ]
        if "email" in author [
          \ #text(link("mailto:" + author.email), font: author-font)
        ]
      }))
    )
    if not is-last {
      v(16pt, weak: true)
    }
  }
  v(2em, weak: true)

  if abstract != none [
    #v(2pt)
    #h(2em) *摘要：* #abstract

    #if keywords != () [
      *关键字：* #keywords.join("；")
    ]
    #v(2pt)
  ]

  body
}

#let numbered_eq(body) = {
  math.equation(
    numbering: it => {
      let chap_num = counter(heading).get().first()
      equation-counter.step()
      let eq_num = equation-counter.get().last()
      numbering("(1.1)", chap_num, eq_num)
    },
    block: true,
    body,
  )
}

#let _r = text.with(fill: red)
#let _g = text.with(fill: green)
#let _b = text.with(fill: blue)
#let _a = text.with(fill: gray)

#let themed-block(
  body,
  title: "",
  fill: luma(240),
  stroke: none,
  radius: 2pt,
  inset: 8pt,
  counter: none,
) = {
  if counter != none {
    counter.step()
  }
  block(
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    width: 100%,
  )[
    #if title != "" or counter != none {
      if title != "" { title }
      if counter != none {
        h(0.3em)
        strong(context counter.display())
      }
      h(0.75em)
    }
    #body
  ]
}

#let problem-counter = counter("problem")
#let problem(body) = themed-block(
  title: strong("题目"),
  fill: rgb(241, 241, 255),
  counter: problem-counter,
  body,
)

#let solution(body) = {
  set enum(numbering: "1)i)a)")
  block(
    inset: 8pt,
    width: 100%,
  )[*解答.* #h(0.75em) #body]
}

#let note(body) = themed-block(
  title: strong("注"),
  fill: rgb(232, 244, 253),
  body,
)

#let warning(body) = themed-block(
  title: strong("注意"),
  fill: rgb(255, 243, 230),
  stroke: 1pt + rgb(255, 180, 120),
  body,
)

#let tip(body) = themed-block(
  title: strong("提示"),
  fill: rgb(237, 253, 232),
  body,
)

#let example(body) = themed-block(
  title: strong("例"),
  fill: luma(245),
  body,
)

#let theorem-counter = counter("theorem")
#let theorem(body) = themed-block(
  title: strong("定理"),
  fill: rgb("#39c5bc32"),
  counter: theorem-counter,
  body,
)

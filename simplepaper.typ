// aided by Gemini-2.5-Pro-DeepResearch
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

  // --- 段落设置：核心修复 ---
  // 使用 (amount:..., all: true) 来为所有段落（包括块级元素后的第一个段落）
  // 应用首行缩进，这是现代 Typst 的惯用做法。
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
  show heading.where(level: 1): it => box(width: 100%)[
    #set par(first-line-indent: 0em)
    #v(0.5em)
    #set align(center)
    #set heading(numbering: "一")
    #it
    #v(0.75em)
  ]

  set enum(indent: 2em)
  set list(indent: 2em)

  show figure: it => [
    #v(12pt)
    #set text(font: caption-font)
    #it
    #v(12pt)
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


#let problem-counter = counter("problem")
#let problem(body) = block(
  fill: rgb(241, 241, 255),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
)[
  #problem-counter.step()
  *题目 #context problem-counter.display().*
  #h(0.75em)
  #body
]

#let solution(body) = {
  set enum(numbering: "(1)")
  block(
    inset: 8pt,
    width: 100%,
  )[*解答.* #h(0.75em) #body]
}

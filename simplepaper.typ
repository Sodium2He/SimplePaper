// aided by Claude Soonet 4 & Gemini-2.5-Pro-DeepResearch
// for typst 0.13.1 (8ace67d9).

#let equation-counter = counter("chapter-equations")
#let figure-counter = counter("chapter-figures")
#let appendix-mode = state("appendix-mode", false)

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
  set page(numbering: "1", number-align: center, header: context {
    let page-num = here().page()
    let headings = query(selector(heading).before(here()))
    let is-appendix = appendix-mode.get()

    // 检查当前页是否有一级标题
    let current-page-headings = query(selector(heading).after(here())).filter(h => h.location().page() == page-num)
    let has-chapter-on-page = current-page-headings.any(h => h.level == 1)

    // 如果当前页有章节标题或者是第一页（标题页），则不显示页眉
    if has-chapter-on-page or page-num == 1 {
      none
    } else if headings.len() > 0 {
      let current-chapter = headings.filter(h => h.level == 1).last()
      let current-section = headings.filter(h => h.level == 2).last()

      if calc.even(page-num) {
        // 偶数页：页数 | 第X章/附录X 章节名
        align(left)[
          #set text(font: header-font)
          #page-num | #{
            if is-appendix {
              let appendix-letter = numbering("A", counter(heading).at(current-chapter.location()).first())
              "附录" + appendix-letter + " " + current-chapter.body
            } else {
              "第" + str(counter(heading).at(current-chapter.location()).first()) + "章 " + current-chapter.body
            }
          }
        ]
      } else {
        // 奇数页：章节号 小节标题 | 页数
        align(right)[
          #set text(font: header-font)
          #{
            if current-section != none {
              let section-nums = counter(heading).at(current-section.location())
              if is-appendix { numbering("A.1", ..section-nums) + " " + current-section.body } else {
                numbering("1.1", ..section-nums) + " " + current-section.body
              }
            } else {
              if is-appendix {
                let appendix-letter = numbering("A", counter(heading).at(current-chapter.location()).first())
                "附录" + appendix-letter + " " + current-chapter.body
              } else {
                let chapter-num = counter(heading).at(current-chapter.location()).first()
                numbering("1", chapter-num) + " " + current-chapter.body
              }
            }
          } | #page-num
        ]
      }
    } else {
      // 没有标题时的默认页眉
      align(center)[
        #set text(font: header-font)
        #title
      ]
    }
  })
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
    pagebreak(to: "odd")
    equation-counter.update(1)
    context if appendix-mode.get() {
      box(width: 100%)[
        #set par(first-line-indent: 0em)
        #v(0.5em)
        #set align(center)
        #set heading(numbering: "附录" + "A")
        #it
        #v(0.75em)
      ]
    } else {
      box(width: 100%)[
        #set par(first-line-indent: 0em)
        #v(0.5em)
        #set align(center)
        #set heading(numbering: "一")
        #it
        #v(0.75em)
      ]
    }
  }

  // try this instead of using codes below:
  // #import "@preview/i-figured:0.2.4"
  // #show heading: i-figured.reset-counters
  // #show figure: i-figured.show-figure
  // // #show math.equation: i-figured.show-equation
  // // #i-figured.outline()
  // // ////////  !IMPORTANT!  ////////
  // you should add [#show figure: i-figured.show-figure.with(numbering: "A.1", level: 1,)] after [#show: appendix] to fix numbered_eq numbering!
  // notice: also see block [#let appendix] and [#let numbered_eq]!
  // for more information: https://forum.typst.app/t/how-to-change-numbering-in-appendix/1716/6
  //  set figure(numbering: n => {
  //    let hdr = counter(heading).get().first()
  //    let num = query(selector(heading).before(here())).last().numbering
  //    numbering(num, hdr, n)
  //  })


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

// turn on appendix mode: #show: appendix
#let appendix(body) = {
  appendix-mode.update(true)
  set heading(numbering: "A.1.1", supplement: [Appendix])
  counter(heading).update(0)
  equation-counter.update(0)
  body
}

#let numbered_eq(body, label: none) = {
  let eq = math.equation(
    numbering: it => {
      let chap_num = counter(heading).get().first()
      equation-counter.step()
      let eq_num = equation-counter.get().last()
      numbering(if appendix-mode.get() { "(A.1)" } else { "(1.1)" }, chap_num, eq_num)
    },
    block: true,
    body,
  )
  // don't know why, but it works
  // no need to write like n...q($...$, <...>), n...q($...$)<...> is also ok
  if label != none {
    [#eq #label]
  } else {
    eq
  }
}

// fuchsia teal eastern purple maroon aqua navy
#let _r = text.with(fill: red)
#let _g = text.with(fill: green)
#let _b = text.with(fill: blue)
#let _y = text.with(fill: yellow)
#let _a = text.with(fill: gray)
#let _ry = text.with(fill: orange)
#let bf(content) = math.upright(math.bold(content))
#let aka = math.eq.delta
#let vt(content) = math.arrow(content)
#let detm(..args) = math.mat(delim: "|", ..args)
// you need to use like: detm(row-gap: #8pt, ...)

// https://github.com/typst/typst/discussions/4800#discussioncomment-12792630
// HOW-TO-USE: like table.cell(diagbox()[$x$][$y$], inset: 0pt, breakable: false)
// if package typst-diagbox: https://github.com/PgBiel/typst-diagbox resumes updating, diagbox funciton here should be removed
#let diagbox(text_left, text_right, padding: 5pt, stroke: .4pt, inverted: false) = context {
  let padded_right = pad(text_right, padding)
  let padded_left = pad(text_left, padding)

  let measure_right = measure(padded_right)
  let measure_left = measure(padded_left)

  let width_diff = calc.abs(measure_right.width - measure_left.width)

  let inner_height = measure_right.height + measure_left.height + width_diff / 10
  let inner_width = measure_right.width + measure_left.width

  box(width: inner_width, height: inner_height) // Empty box to ensure minimal size

  if inverted {
    place(bottom + right, padded_right)
    place(top + left, line(start: (0%, 100%), end: (100%, 0%), stroke: stroke))
    place(top + left, padded_left)
  } else {
    place(top + right, padded_right)
    place(top + left, line(end: (100%, 100%), stroke: stroke))
    place(bottom + left, padded_left)
  }
}

#let themed-block(
  body,
  title: "",
  fill: luma(0%, 4%),
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
    #set enum(numbering: "1)i)a)")
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

#let normal = themed-block

#let note(body) = themed-block(
  title: strong("注"),
  fill: rgb("#fffef3"),
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
  fill: rgb("#f1f9ff"),
  body,
)

#let theorem-counter = counter("theorem")
#let theorem(body) = themed-block(
  title: strong("定理"),
  fill: rgb("#39c5bc12"),
  counter: theorem-counter,
  body,
)

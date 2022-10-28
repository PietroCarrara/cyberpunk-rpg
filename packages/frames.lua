local basic = {
  id = 'basic',
  firstContentFrame = 'content',
  frames = {
    content = {
      left = '5%pw',
      right = 'left(divide)',
      top = '5%ph',
      bottom = 'top(footnotes)',
      next = 'content_2',
    },
    content_2 = {
      right = '95%pw',
      left = 'right(divide)',
      width = 'width(content)',
      top = 'top(content)',
      bottom = 'bottom(content)',
    },
    divide = {
      width = '4mm',
      top = 'top(content)',
      bottom = 'bottom(content)',
    },
    folio = {
      left = 'left(content)',
      right = 'right(content_2)',
      top = 'bottom(footnotes)+2%ph',
      bottom = '97%ph',
    },
    footnotes = {
      left = 'left(content)',
      right = 'right(content_2)',
      height = '0',
      bottom = '90%ph',
    },
  },
}

local chapter = {
  id = 'chapter',
  firstContentFrame = 'chapter',
  frames = {
    chapter = {
      left = 'left(content)',
      right = 'right(content_2)',
      top = '5%ph',
      height = '8%ph',
      next = 'content',
    },
    content = {
      left = '5%pw',
      right = 'left(divide)',
      top = 'bottom(chapter) + width(divide)',
      bottom = 'top(footnotes)',
      next = 'content_2',
    },
    content_2 = {
      right = '95%pw',
      left = 'right(divide)',
      width = 'width(content)',
      top = 'top(content)',
      bottom = 'bottom(content)',
    },
    divide = {
      width = '4mm',
      top = 'top(content)',
      bottom = 'bottom(content)',
    },
    folio = {
      left = 'left(content)',
      right = 'right(content_2)',
      top = 'bottom(footnotes)+2%ph',
      bottom = '97%ph',
    },
    footnotes = {
      left = 'left(content)',
      right = 'right(content_2)',
      height = '0',
      bottom = '90%ph',
    },
  },
}

return {
  basic = basic,
  chapter = chapter,
  list = {
    basic,
    chapter,
  }
}
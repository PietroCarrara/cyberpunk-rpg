local function cooper(str)
  return 'fonts/CooperHewitt-OTF-public/CooperHewitt-' .. str .. '.otf'
end

local function font(str, size)
  return { filename = str, size = size }
end

local plain = require('classes.plain')
local class = pl.class(plain)
class._name = "sixthworld"

local textcase = require('packages.textcase')

class.defaultFrameset = {
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
  }
}
class.firstContentFrame = 'content'

class.isItalic = false
class.isBold = false

function class:_init(options)
  plain._init(self, options)

  self:loadPackage('pdf')
  self:loadPackage('frametricks')
  self:loadPackage('counters')
  self:loadPackage('tableofcontents')
  self:loadPackage('textcase')
  self:loadPackage('rules')
  self:loadPackage("footnotes", {
    insertInto = "footnotes",
    stealFrom = { "content", "content_2", "divide" }
  })


  self:loadPackage('sorted')

  SILE.call('font', font(cooper('Medium'), '9pt'))

  self:registerPostinit(function(self, _) self:postInit() end)
end

function class:postInit()

end

function class:registerCommands()
  plain.registerCommands(self)

  self:registerCommand('textbf', function(_, content)
    if not self.isBold then
      self.isBold = true
      self:computeFont(content)
      self.isBold = false
    else
      self:computeFont(content)
    end
  end)

  self:registerCommand('textit', function(_, content)
    if not self.isItalic then
      self.isItalic = true
      self:computeFont(content)
      self.isItalic = false
    else
      self:computeFont(content)
    end
  end)

  self:registerCommand('section', function(_, content)
    SILE.typesetter:leaveHmode()
    SILE.call('increment-counter', { id = 'section' })
    SILE.call('goodbreak')
    SILE.call('bigskip')
    SILE.settings:temporarily(function ()
      SILE.call('noindent')
      SILE.call('font', font(cooper('Bold'), '16pt'), function()
        SILE.call('uppercase', {}, content)
        SILE.call('tocentry', { level = 1, number = self:getCounter('section').value }, SU.subContent(content))
      end)
    end)
    SILE.typesetter:leaveHmode()
    SILE.call('fullrule')
    SILE.typesetter:leaveHmode()
  end)

  self:registerCommand('subsection', function(_, content)
    SILE.typesetter:leaveHmode()
    SILE.call('increment-counter', { id = 'subsection' })
    SILE.call('goodbreak')
    SILE.call('medskip')
    SILE.settings:temporarily(function ()
      SILE.call('noindent')
      SILE.call('font', font(cooper('Bold'), '12pt'), function()
        SILE.call('uppercase', {}, content)
        SILE.call('tocentry', { level = 2, number = self:getCounter('subsection').value }, SU.subContent(content))
      end)
    end)
    SILE.call('smallskip')
    SILE.typesetter:leaveHmode()
  end)
end

function class:endPage()
  local r = plain.endPage(self)
  return r
end

function class:computeFont(content)
  if self.isBold and self.isItalic then
    SILE.call('font', font(cooper('BoldItalic'), '9pt'), content)
  elseif self.isBold then
    SILE.call('font', font(cooper('Bold'), '9pt'), content)
  elseif self.isItalic then
    SILE.call('font', font(cooper('MediumItalic'), '9pt'), content)
  else
    SILE.process(content)
  end
end

return class

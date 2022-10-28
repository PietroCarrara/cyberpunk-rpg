local plain = require('classes.plain')
local class = pl.class(plain)
class._name = "sixthworld"

local textcase = require('packages.textcase')
local frames = require('packages.frames')

class.defaultFrameset = frames.basic.frames
class.firstContentFrame = frames.basic.firstContentFrame

class.isItalic = false
class.isBold = false

local function cooper(str)
  return 'fonts/CooperHewitt-OTF-public/CooperHewitt-' .. str .. '.otf'
end

local function font(str, size)
  local font = { filename = str }

  if size then
    font.size = size
  end

  return font
end

function class:_init(options)
  plain._init(self, options)

  self:loadPackage('pdf')
  self:loadPackage('frametricks')
  self:loadPackage('counters')
  self:loadPackage('tableofcontents')
  self:loadPackage('textcase')
  self:loadPackage('rules')
  self:loadPackage('masters', frames.list)
  self:loadPackage('footnotes', {
    insertInto = 'footnotes',
    stealFrom = { 'content', 'content_2', 'divide' }
  })

  self:loadPackage('sorted')
  self:loadPackage('commands')

  SILE.call('font', font(cooper('Medium'), '9pt'))

  self:registerPostinit(function(self, _) self:postInit() end)
end

function class:postInit()
end

function class:registerCommands()
  plain.registerCommands(self)

  local identity = function (_, c) SILE.process(c) end

  self:registerCommand('chapter-style', identity)
  self:registerCommand('section-style', identity)
  self:registerCommand('subsection-style', identity)

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

  self:registerCommand('chapter', function(_, content)
    SILE.call('increment-counter', { id = 'chapter' })

    SILE.call('pagebreak')
    SILE.typesetter:leaveHmode()

    self:switchMasterOnePage('chapter')

    SILE.settings:temporarily(function()
      SILE.call('chapter-style', {}, content)
      SILE.call('tocentry', { level = 1, number = self:getCounter('chapter').value }, SU.subContent(content))
    end)

    SILE.call('eject')
    SILE.typesetter:leaveHmode()
  end)

  self:registerCommand('section', function(_, content)
    SILE.typesetter:leaveHmode()
    SILE.call('increment-counter', { id = 'section' })
    SILE.call('goodbreak')
    SILE.call('bigskip')
    SILE.settings:temporarily(function()
      SILE.call('section-style', {}, content)
      SILE.call('tocentry', { level = 2, number = self:getCounter('section').value }, SU.subContent(content))
    end)
    SILE.typesetter:leaveHmode()
  end)

  self:registerCommand('subsection', function(_, content)
    SILE.typesetter:leaveHmode()
    SILE.call('increment-counter', { id = 'subsection' })
    SILE.call('goodbreak')
    SILE.call('medskip')
    SILE.settings:temporarily(function()
      SILE.call('subsection-style', {}, content)
      SILE.call('tocentry', { level = 3, number = self:getCounter('subsection').value }, SU.subContent(content))
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
    SILE.call('font', font(cooper('BoldItalic')), content)
  elseif self.isBold then
    SILE.call('font', font(cooper('Bold')), content)
  elseif self.isItalic then
    SILE.call('font', font(cooper('MediumItalic')), content)
  else
    SILE.process(content)
  end
end

return class

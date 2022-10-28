local base = require('packages.base')

local package = pl.class(base)
package._name = "commands"

local function sortedblock(options, content)
  local type = ''
  if options.type then
    type = '-' .. options.type
  end

  local triggers = { 'pre-key', 'pre-content', 'post-key', 'post-content' }

  local opts = {}
  for i = 1, #triggers do
    local command = triggers[i] .. type
    if SILE.Commands[command] then
      opts[triggers[i]] = command
    end
  end

  return SILE.call('sorted', opts, content)
end

local function paintframe(frame, color)
  local frame = SILE.getFrame(frame)
  if frame == nil then
    SU.warn('could not paint frame "' .. frame .. '" for it was not found')
    return
  end
  local backgroundColor = SILE.color(color)
  SILE.outputter:pushColor(backgroundColor)
  SILE.outputter:drawRule(frame:left(), frame:top(), frame:width(), frame:height())
  SILE.outputter:popColor()
end

local function vcenter(options, content)
  local frame = SILE.typesetter.frame

  -- Calculate content height
  SILE.typesetter:pushState()
  SILE.process(content)
  SILE.typesetter:leaveHmode(1)
  local vbox = SILE.pagebuilder:collateVboxes(SILE.typesetter.state.outputQueue)
  SILE.typesetter:popState()

  SILE.typesetter:leaveHmode()
  SILE.typesetter:pushVglue({
    height = (frame:height() - vbox.height) / 2
  })
  SILE.process(content)
end

function package:_init()
  base._init(self)
  self.class:loadPackage("color")
end

function package:registerCommands()
  self:registerCommand('sortedblock', sortedblock)
  self:registerCommand('vcenter', vcenter)
  self:registerCommand('paint-frame', function(options, content)
    local frame = options.frame or SILE.typesetter.frame.id
    local color = SU.required(options, 'color')

    paintframe(frame, color)
  end)
end

return package

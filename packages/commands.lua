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

local function iceblock(option, content)

end

function package:registerCommands()
  self:registerCommand('sortedblock', sortedblock)
  self:registerCommand('iceblock', iceblock)
end

return package
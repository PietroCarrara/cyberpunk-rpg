local base = require('packages.base')

local package = pl.class(base)
package._name = "sorted"

local trimLeft = function (str)
  return str:gsub("^%s*", "")
end

local trimRight = function (str)
  return str:gsub("%s*$", "")
end

local trim = function (str)
  return trimRight(trimLeft(str))
end

function package:registerCommands()
  local items = {}

  self:registerCommand("sort", function (options, content)
    local sep = options.sep or ', '

    if #content ~= 1 or type(content[1]) ~= "string" then
      SU.error("Can't sort this object")
    end

    local items = pl.stringx.split(content[1], sep)

    table.sort(items, function (a, b)
      return a:lower() < b:lower()
    end)

    for i = 1,items:len() do
      SILE.typesetter:typeset(items[i])

      if i ~= #items then
        SILE.typesetter:typeset(sep)
      end
    end
  end)

  self:registerCommand("sorted", function (options, content)
    local items = {}

    for i = 1, #content do
      if type(content[i]) == "table" and content[i].command == "item" then
        items[#items+1] = {
          key = content[i].options.key or i,
          content = SU.subContent(content[i]),
        }
      else
        local text
        if type(content[i]) == "string" then
          text = trim(content[i])
        else
          text = content[i].command
        end
        if text ~= "" then SU.warn("Ignored \""..text.."\"") end
      end
    end

    table.sort(items, function (a, b)
      local x = tostring(a.key)
      local y = tostring(b.key)

      return x:lower() < y:lower()
    end)

    for i = 1, #items do
      if options['pre-key'] then
        SILE.call(options['pre-key'], items[i], { items[i].key })
      end
      if options['pre-content'] then
        SILE.call(options['pre-content'], items[i], items[i].content)
      end

      SILE.process(items[i].content)

      if options['post-content'] then
        SILE.call(options['post-content'], items[i], items[i].content)
      end
      if options['post-key'] then
        SILE.call(options['post-key'], items[i], { items[i].content })
      end

      SILE.typesetter:leaveHmode()
    end
  end)
end

return package
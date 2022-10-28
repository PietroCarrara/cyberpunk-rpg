local base = require('packages.base')

local package = pl.class(base)
package._name = "sorted"

local trimLeft = function(str)
  return str:gsub("^%s*", "")
end

local trimRight = function(str)
  return str:gsub("%s*$", "")
end

local trim = function(str)
  return trimRight(trimLeft(str))
end

local function norm(str)
  local tableAccents = {
    ["À"] = "A",
    ["Á"] = "A",
    ["Â"] = "A",
    ["Ã"] = "A",
    ["Ä"] = "A",
    ["Å"] = "A",
    ["Æ"] = "AE",
    ["Ç"] = "C",
    ["È"] = "E",
    ["É"] = "E",
    ["Ê"] = "E",
    ["Ë"] = "E",
    ["Ì"] = "I",
    ["Í"] = "I",
    ["Î"] = "I",
    ["Ï"] = "I",
    ["Ð"] = "D",
    ["Ñ"] = "N",
    ["Ò"] = "O",
    ["Ó"] = "O",
    ["Ô"] = "O",
    ["Õ"] = "O",
    ["Ö"] = "O",
    ["Ø"] = "O",
    ["Ù"] = "U",
    ["Ú"] = "U",
    ["Û"] = "U",
    ["Ü"] = "U",
    ["Ý"] = "Y",
    ["Þ"] = "P",
    ["ß"] = "s",
    ["à"] = "a",
    ["á"] = "a",
    ["â"] = "a",
    ["ã"] = "a",
    ["ä"] = "a",
    ["å"] = "a",
    ["æ"] = "ae",
    ["ç"] = "c",
    ["è"] = "e",
    ["é"] = "e",
    ["ê"] = "e",
    ["ë"] = "e",
    ["ì"] = "i",
    ["í"] = "i",
    ["î"] = "i",
    ["ï"] = "i",
    ["ð"] = "eth",
    ["ñ"] = "n",
    ["ò"] = "o",
    ["ó"] = "o",
    ["ô"] = "o",
    ["õ"] = "o",
    ["ö"] = "o",
    ["ø"] = "o",
    ["ù"] = "u",
    ["ú"] = "u",
    ["û"] = "u",
    ["ü"] = "u",
    ["ý"] = "y",
    ["þ"] = "p",
    ["ÿ"] = "y",
  }

  local normalisedString = ''
  local normalisedString = str:gsub("[%z\1-\127\194-\244][\128-\191]*", tableAccents)
  return normalisedString
end

function package:registerCommands()
  local items = {}

  self:registerCommand("sort", function(options, content)
    local sep = options.sep or ', '

    if #content == 1 and content.command == "sort" then
      content = content[1]
    end

    if #content ~= 1 or type(content[1]) ~= "string" then
      SU.error("Can't sort this object")
    end

    local items = pl.stringx.split(content[1], sep)

    table.sort(items, function(a, b)
      return norm(a):lower() < norm(b):lower()
    end)

    for i = 1, items:len() do
      SILE.typesetter:typeset(items[i])

      if i ~= #items then
        SILE.typesetter:typeset(sep)
      end
    end
  end)

  self:registerCommand("sorted", function(options, content)
    local items = {}

    for i = 1, #content do
      if type(content[i]) == "table" and content[i].command == "item" then
        items[#items + 1] = {
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
        if text ~= "" then SU.warn("Ignored \"" .. text .. "\"") end
      end
    end

    table.sort(items, function(a, b)
      local x = norm(tostring(a.key))
      local y = norm(tostring(b.key))

      return x:lower() < y:lower()
    end)

    SILE.typesetter:leaveHmode()
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
        SILE.call(options['post-key'], items[i], { items[i].key })
      end

      SILE.typesetter:leaveHmode()
    end
  end)
end

return package

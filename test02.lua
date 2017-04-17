cases = {
{input="Lambda", output="<mo>Λ</mo>"},
}

local asciimath = assert(loadfile 'asciimath.lua')()
-- TODO: [LATER] drop dependency on LGPL castl.runtime

local env = require 'castl.runtime'
env.document = {
  createTextNode = function(self, text) return text end,
  createElementNS = function(self, namespace, tag)
    return setmetatable({tag = tag}, {__index = Tag})
  end,
  createDocumentFragment = function(self) return env.document:createElementNS() end,
  print = function(_, ...) print(...) end,
}
Tag = function(self, name)
  if name == 'childNodes' then
    return setmetatable(self.childs or {}, {__index = function(self, name)
      if name == 'length' then
        return #self
      end
    end})
  elseif name == 'nodeName' then
    return self.tag
  elseif name == 'firstChild' then
    return (self.childs or {})[1]  -- TODO: is this ok?
  elseif name == 'lastChild' then
    return self.childs[#self.childs]  -- TODO: is this ok?
  end
  local funcs = {
    appendChild = function(self, child)
      if not self.childs then self.childs = {} end
      self.childs[#self.childs+1] = child
    end,
    setAttribute = function(self, name, value)
      if not self.attrs then self.attrs = {} end
      self.attrs[name] = value
    end,
    hasChildNodes = function(self)
      return self.childs and true or false
    end,
    toxml = function(self, buf0)
      local buf = buf0 or setmetatable({}, {__call = function(self, fmt, ...)
        self[#self+1] = string.format(fmt, ...)
      end})
      if self.tag then
        buf('<%s', self.tag)
        local attrs = {}
        for k,v in pairs(self.attrs or {}) do
          attrs[#attrs+1] = string.format(' %s="%s"', k, v)
        end
        table.sort(attrs)
        buf('%s>', table.concat(attrs, ''))
      end
      for _, ch in ipairs(self.childs or {}) do
        if type(ch) == 'string' then
          buf('%s', ch)
        else
          ch:toxml(buf)
        end
      end
      if self.tag then
        buf('</%s>', self.tag)
      end
      if not buf0 then
        return table.concat(buf, '')
      end
    end,
  }
  return funcs[name]
end

asciimath.init()

for _, case in ipairs(cases) do
  local res = asciimath:parseMath(case.input)
  while res.tag~='mstyle' do
    res = res.childs[1]
  end
  res = res.childs[1]
  res = res:toxml()
  if res ~= case.output then
    io.write(string.format('\ncase %s\n want: %s\n have: %s\n', case.input, case.output, res))
  else
    io.write('.')
  end
end


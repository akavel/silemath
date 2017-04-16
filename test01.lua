local asciimath = assert(loadfile 'asciimath.lua')()
-- TODO: port more tests from test/unittests.js
-- TODO: [LATER] drop dependency on LGPL castl.runtime
--[[
{input: "!=", output:"<mo>≠</mo>"},
{input: "[", output:"<mrow><mo>[</mo><mo></mo></mrow>"},
{input: "and", output:"<mrow><mspace width=\"1ex\"></mspace><mtext>and</mtext><mspace width=\"1ex\"></mspace></mrow>"},
{input: "arccos", output:"<mrow><mo>arccos</mo><mo></mo></mrow>"},
{input: "bbb", output:"<mstyle mathvariant=\"double-struck\"><mo></mo></mstyle>"},
{input: "f(x)/g(x)", output:"<mfrac><mrow><mi>f</mi><mrow><mo>(</mo><mi>x</mi><mo>)</mo></mrow></mrow><mrow><mi>g</mi><mrow><mo>(</mo><mi>x</mi><mo>)</mo></mrow></mrow></mfrac>"},
--]]

local env = require 'castl.runtime'
env.document = {
  createDocumentFragment = function(self) 
    return env.document:createElementNS()
  end,
  createTextNode = function(self, s)
    return s
  end,
  createElementNS = function(self, namespace, tag)
    return setmetatable({tag = tag}, {__index = Tag})
  end,
}
Tag = {
  appendChild = function(self, child)
    if not self.childs then self.childs = {} end
    self.childs[#self.childs+1] = child
  end,
  setAttribute = function(self, name, value)
    if not self.attrs then self.attrs = {} end
    self.attrs[name] = value
  end,
  marshal = function(self, buf)
    if not buf then
      buf = setmetatable({}, {__call = function(self, fmt, ...)
        self[#self+1] = string.format(fmt, ...)
      end})
    end
    if self.tag then
      buf('<%s', self.tag)
      local attrs = {}
      for k,v in pairs(self.attrs or {}) do
        attrs[#attrs+1] = string.format(' %s="%s"', k, v)
      end
      table.sort(attrs)
      buf('%s>', table.concat(attrs, ''))
    end
    for _, ch in ipairs(self.childs) do
      if type(ch) == 'string' then
        buf('%s', ch)
      else
        ch:marshal(buf)
      end
    end
    if self.tag then
      buf('</%s>', self.tag)
    end
    return buf
  end,
}

asciimath.init()
local input = "!="
local expectedOutput = "<mo>≠</mo>"
local res = asciimath.parseMath(nil, input)
while res and res.tag~='mstyle' do res = res.childs[1] end
res = res.childs[1]
print(table.concat(res:marshal(), ''))
print(expectedOutput)

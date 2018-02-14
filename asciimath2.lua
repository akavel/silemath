--[[
asciimath2.lua
==============
This file contains Lua functions to convert ASCII math notation and
(some) LaTeX to Presentation MathML (should work with Firefox and other
browsers that can render MathML).

Version 2.2 Mar 3, 2014. [cut by akavel - Mateusz Czaplinski, 2017]
Latest version at https://github.com/mathjax/asciimathml
If you use it on a webpage, please send the URL to jipsen@chapman.edu

Copyright (c) 2014 Peter Jipsen and other ASCIIMathML.js contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]
local asciimath = {}

local mathcolor = "blue";        -- change it to "" (to inherit) or another color
local mathfontsize = "1em";      -- change to e.g. 1.2em for larger math
local mathfontfamily = "serif";  -- change to "" to inherit (works in IE)
                                 -- or another family (e.g. "arial")
local automathrecognize = false; -- writing "amath" on page makes this true
--var checkForMathML = true;     -- check if browser can display MathML
local notifyIfNoMathML = true;   -- display note at top if no MathML capability
local alertIfNoMathML = false;   -- show alert box if no MathML capability
local translateOnLoad = true;    -- set to false to do call translators from js 
local translateASCIIMath = true; -- false to preserve `..`
local displaystyle = true;       -- puts limits above and below large operators
local showasciiformulaonhover = true; -- helps students learn ASCIIMath
local decimalsign = ".";         -- change to "," if you like, beware of `(1,2)`!
local AMdelimiter1, AMescape1 = "`", "\\\\`"; -- can use other characters
local AMdocumentId = "wikitext"  -- PmWiki element containing math (default=body)
local fixphi = true;             --false to return to legacy phi/varphi mapping

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local AMparseExpr

local isIE = false;
local noMathML, translated = false, false;

-- NOTE(akavel): stubs for some JS functionalities
local function charAt(str, i)
  -- FIXME(akavel): test this for correctness
  -- FIXME(akavel): for example, charAt('ż', 1) == 'ż'
  -- FIXME(akavel): for example, charAt('żółć', 3) == 'ł'
  -- Based on http://lua-users.org/wiki/LuaUnicode
  for uchar in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
    i = i-1
    if i <= 0 then
      return uchar
    end
  end
end
local function charCodeAt(str, i)
  -- FIXME(akavel): test this for correctness
  -- FIXME(akavel): for example, charCodeAt('ż', 1) == 380
  -- Based on http://lua-users.org/wiki/LuaUnicode
  local uchar = charAt(str, i)
  local c = uchar:byte()
  local len = c<0x80 and 1 or
    c<0xe0 and 2 or
    c<0xf0 and 3 or
    c<0xf8 and 4 or
    error('invalid UTF-8 character sequence: '..uchar)
  local code = c % (2^(8-len))
  for i = 2, #uchar do
    code = (code*0x40) + (uchar:byte(i) % 0x40)
  end
  return code
end
local Tag = function(self, name)
  if name == 'childNodes' then
    return setmetatable({_childs = self.childs}, {
      __len = function(self)
          return self._childs and #self._childs or 0
      end,
      __index = function(self, name)
        if type(name)=='number' then
          return self._childs[name]
        end
      end})
  elseif name == 'nodeName' then
    return self.tag
  elseif name == 'firstChild' then
    return (self.childs or {})[1]  -- TODO: is this ok?
  elseif name == 'lastChild' then
    return self.childs[#self.childs]  -- TODO: is this ok?
  elseif name == 'nextSibling' then
    if not self.parent then error('no parent') end
    for i,ch in ipairs(self.parent.childs) do
      if ch==self then
        return self.parent.childs[i+1]
      end
    end
  end
  local funcs = {
    appendChild = function(self, child)
      if child._fragment then
        while child.childs do
          self:appendChild(child:removeChild(child.childs[1]))
        end
      else
        if child.parent then child.parent:removeChild(child) end
        if not self.childs then self.childs = {} end
        child.parent = self
        self.childs[#self.childs+1] = child
      end
      return child
    end,
    replaceChild = function(self, new, old)
      if new._fragment then
        error("NIY: replaceChild using document-fragment")
      end
      for i,ch in ipairs(self.childs or {}) do
        if ch==old then
          self.childs[i] = new
          new.parent = self
          old.parent = nil
          return old
        end
      end
    end,
    setAttribute = function(self, name, value)
      if not self.attrs then self.attrs = {} end
      self.attrs[name] = value
    end,
    hasChildNodes = function(self)
      return self.childs and true or false
    end,
    removeChild = function(self, cut)
      for i,ch in ipairs(self.childs) do
        if ch==cut then
          table.remove(self.childs, i)
          if #self.childs==0 then
            self.childs = nil
          end
          cut.parent = nil
          return cut
        end
      end
    end,
    toxml = function(self)
      if self._fragment then
        local t = {}
        for _,ch in ipairs(self.childs or {}) do
          t[#t+1] = string.format("< %s >", toxml(ch))
        end
        return table.concat(t, '')
      end
      return toxml(self)
    end,
  }
  return funcs[name]
end
local document = {
  createElementNS = function(self, namespace, tag)
    return setmetatable({tag = tag}, {__index = Tag})
  end,
  createDocumentFragment = function(self)
    return setmetatable({_fragment = true}, {__index = Tag})
  end,
  createTextNode = function(self, text)
    text = string.gsub(text, '.', {
      [' '] = '&nbsp;',
      ['<'] = '&lt;',
      ['>'] = '&gt;',
      ['&'] = '&amp;',
      -- TODO(akavel): '"' and "'" ?
    })
    return setmetatable({text = text}, {__index = function(self, name)
      if name == 'hasChildNodes' then
        return function() return false end
      elseif name == 'nodeName' then
        return '#text'
      elseif name == 'nodeValue' then
        return self.text
      elseif name == '_fragment' then
        return false
      elseif name == 'parent' then
        return nil  -- if non nil, then __index wouldn't even be called
      end
      error(debug.traceback("tried to access string's method: "..name, 2))
    end})
  end,
  printf = function(_, fmt, ...) print(string.format(fmt, ...)) end,
}

local function createElementXHTML(t)
  return document:createElementNS("http://www.w3.org/1999/xhtml",t)
end

local AMmathml = "http://www.w3.org/1998/Math/MathML"

local function AMcreateElementMathML(t)
  return document:createElementNS(AMmathml,t)
end

local function createMmlNode(t,frag)
  local node;
  node = document:createElementNS(AMmathml,t)
  if frag then node:appendChild(frag) end
  return node
end

local function newcommand(oldstr,newstr)
  AMsymbols[#AMsymbols+1] = {input=oldstr, tag="mo", output=newstr, tex=null, ttype=DEFINITION}
  refreshSymbols()
end

local function newsymbol(symbolobj)
  AMsymbols[#AMsymbols+1] = symbolobj;
  refreshSymbols()
end

-- character lists for Mozilla/Netscape fonts
local AMcal = {"\240\157\146\156", "\226\132\172", "\240\157\146\158", "\240\157\146\159", "\226\132\176", "\226\132\177", "\240\157\146\162", "\226\132\139", "\226\132\144", "\240\157\146\165", "\240\157\146\166", "\226\132\146", "\226\132\179", "\240\157\146\169", "\240\157\146\170", "\240\157\146\171", "\240\157\146\172", "\226\132\155", "\240\157\146\174", "\240\157\146\175", "\240\157\146\176", "\240\157\146\177", "\240\157\146\178", "\240\157\146\179", "\240\157\146\180", "\240\157\146\181", "\240\157\146\182", "\240\157\146\183", "\240\157\146\184", "\240\157\146\185", "\226\132\175", "\240\157\146\187", "\226\132\138", "\240\157\146\189", "\240\157\146\190", "\240\157\146\191", "\240\157\147\128", "\240\157\147\129", "\240\157\147\130", "\240\157\147\131", "\226\132\180", "\240\157\147\133", "\240\157\147\134", "\240\157\147\135", "\240\157\147\136", "\240\157\147\137", "\240\157\147\138", "\240\157\147\139", "\240\157\147\140", "\240\157\147\141", "\240\157\147\142", "\240\157\147\143"}
local AMfrk = {"\240\157\148\132", "\240\157\148\133", "\226\132\173", "\240\157\148\135", "\240\157\148\136", "\240\157\148\137", "\240\157\148\138", "\226\132\140", "\226\132\145", "\240\157\148\141", "\240\157\148\142", "\240\157\148\143", "\240\157\148\144", "\240\157\148\145", "\240\157\148\146", "\240\157\148\147", "\240\157\148\148", "\226\132\156", "\240\157\148\150", "\240\157\148\151", "\240\157\148\152", "\240\157\148\153", "\240\157\148\154", "\240\157\148\155", "\240\157\148\156", "\226\132\168", "\240\157\148\158", "\240\157\148\159", "\240\157\148\160", "\240\157\148\161", "\240\157\148\162", "\240\157\148\163", "\240\157\148\164", "\240\157\148\165", "\240\157\148\166", "\240\157\148\167", "\240\157\148\168", "\240\157\148\169", "\240\157\148\170", "\240\157\148\171", "\240\157\148\172", "\240\157\148\173", "\240\157\148\174", "\240\157\148\175", "\240\157\148\176", "\240\157\148\177", "\240\157\148\178", "\240\157\148\179", "\240\157\148\180", "\240\157\148\181", "\240\157\148\182", "\240\157\148\183"}
local AMbbb = {"\240\157\148\184", "\240\157\148\185", "\226\132\130", "\240\157\148\187", "\240\157\148\188", "\240\157\148\189", "\240\157\148\190", "\226\132\141", "\240\157\149\128", "\240\157\149\129", "\240\157\149\130", "\240\157\149\131", "\240\157\149\132", "\226\132\149", "\240\157\149\134", "\226\132\153", "\226\132\154", "\226\132\157", "\240\157\149\138", "\240\157\149\139", "\240\157\149\140", "\240\157\149\141", "\240\157\149\142", "\240\157\149\143", "\240\157\149\144", "\226\132\164", "\240\157\149\146", "\240\157\149\147", "\240\157\149\148", "\240\157\149\149", "\240\157\149\150", "\240\157\149\151", "\240\157\149\152", "\240\157\149\153", "\240\157\149\154", "\240\157\149\155", "\240\157\149\156", "\240\157\149\157", "\240\157\149\158", "\240\157\149\159", "\240\157\149\160", "\240\157\149\161", "\240\157\149\162", "\240\157\149\163", "\240\157\149\164", "\240\157\149\165", "\240\157\149\166", "\240\157\149\167", "\240\157\149\168", "\240\157\149\169", "\240\157\149\170", "\240\157\149\171"}

-- token types
local CONST = 0
local UNARY = 1
local BINARY = 2
local INFIX = 3
local LEFTBRACKET = 4
local RIGHTBRACKET = 5
local SPACE = 6
local UNDEROVER = 7
local DEFINITION = 8
local LEFTRIGHT = 9
local TEXT = 10
local BIG = 11
local LONG = 12
local STRETCHY = 13
local MATRIX = 14
local UNARYUNDEROVER = 15;

local AMquote = {input="\"",   tag="mtext", output="mbox", tex=null, ttype=TEXT};
local AMsymbols = {
  {input = "alpha", tag = "mi", output = "\206\177", tex = nil, ttype = CONST},
  {input = "beta", tag = "mi", output = "\206\178", tex = nil, ttype = CONST},
  {input = "chi", tag = "mi", output = "\207\135", tex = nil, ttype = CONST},
  {input = "delta", tag = "mi", output = "\206\180", tex = nil, ttype = CONST},
  {input = "Delta", tag = "mo", output = "\206\148", tex = nil, ttype = CONST},
  {input = "epsi", tag = "mi", output = "\206\181", tex = "epsilon", ttype = CONST},
  {input = "varepsilon", tag = "mi", output = "\201\155", tex = nil, ttype = CONST},
  {input = "eta", tag = "mi", output = "\206\183", tex = nil, ttype = CONST},
  {input = "gamma", tag = "mi", output = "\206\179", tex = nil, ttype = CONST},
  {input = "Gamma", tag = "mo", output = "\206\147", tex = nil, ttype = CONST},
  {input = "iota", tag = "mi", output = "\206\185", tex = nil, ttype = CONST},
  {input = "kappa", tag = "mi", output = "\206\186", tex = nil, ttype = CONST},
  {input = "lambda", tag = "mi", output = "\206\187", tex = nil, ttype = CONST},
  {input = "Lambda", tag = "mo", output = "\206\155", tex = nil, ttype = CONST},
  {input = "lamda", tag = "mi", output = "\206\187", tex = nil, ttype = CONST},
  {input = "Lamda", tag = "mo", output = "\206\155", tex = nil, ttype = CONST},
  {input = "mu", tag = "mi", output = "\206\188", tex = nil, ttype = CONST},
  {input = "nu", tag = "mi", output = "\206\189", tex = nil, ttype = CONST},
  {input = "omega", tag = "mi", output = "\207\137", tex = nil, ttype = CONST},
  {input = "Omega", tag = "mo", output = "\206\169", tex = nil, ttype = CONST},
      {input = "phi", tag = "mi", output = (function()
              if fixphi then
                  return "\207\149"
              else
                  return "\207\134"
              end
          end)(), tex = nil, ttype = CONST}
  ,
  
      {input = "varphi", tag = "mi", output = (function()
              if fixphi then
                  return "\207\134"
              else
                  return "\207\149"
              end
          end)(), tex = nil, ttype = CONST}
  ,
  {input = "Phi", tag = "mo", output = "\206\166", tex = nil, ttype = CONST},
  {input = "pi", tag = "mi", output = "\207\128", tex = nil, ttype = CONST},
  {input = "Pi", tag = "mo", output = "\206\160", tex = nil, ttype = CONST},
  {input = "psi", tag = "mi", output = "\207\136", tex = nil, ttype = CONST},
  {input = "Psi", tag = "mi", output = "\206\168", tex = nil, ttype = CONST},
  {input = "rho", tag = "mi", output = "\207\129", tex = nil, ttype = CONST},
  {input = "sigma", tag = "mi", output = "\207\131", tex = nil, ttype = CONST},
  {input = "Sigma", tag = "mo", output = "\206\163", tex = nil, ttype = CONST},
  {input = "tau", tag = "mi", output = "\207\132", tex = nil, ttype = CONST},
  {input = "theta", tag = "mi", output = "\206\184", tex = nil, ttype = CONST},
  {input = "vartheta", tag = "mi", output = "\207\145", tex = nil, ttype = CONST},
  {input = "Theta", tag = "mo", output = "\206\152", tex = nil, ttype = CONST},
  {input = "upsilon", tag = "mi", output = "\207\133", tex = nil, ttype = CONST},
  {input = "xi", tag = "mi", output = "\206\190", tex = nil, ttype = CONST},
  {input = "Xi", tag = "mo", output = "\206\158", tex = nil, ttype = CONST},
  {input = "zeta", tag = "mi", output = "\206\182", tex = nil, ttype = CONST},
  {input = "*", tag = "mo", output = "\226\139\133", tex = "cdot", ttype = CONST},
  {input = "**", tag = "mo", output = "\226\136\151", tex = "ast", ttype = CONST},
  {input = "***", tag = "mo", output = "\226\139\134", tex = "star", ttype = CONST},
  {input = "//", tag = "mo", output = "/", tex = nil, ttype = CONST},
  {input = "\\\\", tag = "mo", output = "\\", tex = "backslash", ttype = CONST},
  {input = "setminus", tag = "mo", output = "\\", tex = nil, ttype = CONST},
  {input = "xx", tag = "mo", output = "\195\151", tex = "times", ttype = CONST},
  {input = "|><", tag = "mo", output = "\226\139\137", tex = "ltimes", ttype = CONST},
  {input = "><|", tag = "mo", output = "\226\139\138", tex = "rtimes", ttype = CONST},
  {input = "|><|", tag = "mo", output = "\226\139\136", tex = "bowtie", ttype = CONST},
  {input = "-:", tag = "mo", output = "\195\183", tex = "div", ttype = CONST},
  {input = "divide", tag = "mo", output = "-:", tex = nil, ttype = DEFINITION},
  {input = "@", tag = "mo", output = "\226\136\152", tex = "circ", ttype = CONST},
  {input = "o+", tag = "mo", output = "\226\138\149", tex = "oplus", ttype = CONST},
  {input = "ox", tag = "mo", output = "\226\138\151", tex = "otimes", ttype = CONST},
  {input = "o.", tag = "mo", output = "\226\138\153", tex = "odot", ttype = CONST},
  {input = "sum", tag = "mo", output = "\226\136\145", tex = nil, ttype = UNDEROVER},
  {input = "prod", tag = "mo", output = "\226\136\143", tex = nil, ttype = UNDEROVER},
  {input = "^^", tag = "mo", output = "\226\136\167", tex = "wedge", ttype = CONST},
  {input = "^^^", tag = "mo", output = "\226\139\128", tex = "bigwedge", ttype = UNDEROVER},
  {input = "vv", tag = "mo", output = "\226\136\168", tex = "vee", ttype = CONST},
  {input = "vvv", tag = "mo", output = "\226\139\129", tex = "bigvee", ttype = UNDEROVER},
  {input = "nn", tag = "mo", output = "\226\136\169", tex = "cap", ttype = CONST},
  {input = "nnn", tag = "mo", output = "\226\139\130", tex = "bigcap", ttype = UNDEROVER},
  {input = "uu", tag = "mo", output = "\226\136\170", tex = "cup", ttype = CONST},
  {input = "uuu", tag = "mo", output = "\226\139\131", tex = "bigcup", ttype = UNDEROVER},
  {input = "!=", tag = "mo", output = "\226\137\160", tex = "ne", ttype = CONST},
  {input = ":=", tag = "mo", output = ":=", tex = nil, ttype = CONST},
  {input = "lt", tag = "mo", output = "<", tex = nil, ttype = CONST},
  {input = "<=", tag = "mo", output = "\226\137\164", tex = "le", ttype = CONST},
  {input = "lt=", tag = "mo", output = "\226\137\164", tex = "leq", ttype = CONST},
  {input = "gt", tag = "mo", output = ">", tex = nil, ttype = CONST},
  {input = ">=", tag = "mo", output = "\226\137\165", tex = "ge", ttype = CONST},
  {input = "gt=", tag = "mo", output = "\226\137\165", tex = "geq", ttype = CONST},
  {input = "-<", tag = "mo", output = "\226\137\186", tex = "prec", ttype = CONST},
  {input = "-lt", tag = "mo", output = "\226\137\186", tex = nil, ttype = CONST},
  {input = ">-", tag = "mo", output = "\226\137\187", tex = "succ", ttype = CONST},
  {input = "-<=", tag = "mo", output = "\226\170\175", tex = "preceq", ttype = CONST},
  {input = ">-=", tag = "mo", output = "\226\170\176", tex = "succeq", ttype = CONST},
  {input = "in", tag = "mo", output = "\226\136\136", tex = nil, ttype = CONST},
  {input = "!in", tag = "mo", output = "\226\136\137", tex = "notin", ttype = CONST},
  {input = "sub", tag = "mo", output = "\226\138\130", tex = "subset", ttype = CONST},
  {input = "sup", tag = "mo", output = "\226\138\131", tex = "supset", ttype = CONST},
  {input = "sube", tag = "mo", output = "\226\138\134", tex = "subseteq", ttype = CONST},
  {input = "supe", tag = "mo", output = "\226\138\135", tex = "supseteq", ttype = CONST},
  {input = "-=", tag = "mo", output = "\226\137\161", tex = "equiv", ttype = CONST},
  {input = "~=", tag = "mo", output = "\226\137\133", tex = "cong", ttype = CONST},
  {input = "~~", tag = "mo", output = "\226\137\136", tex = "approx", ttype = CONST},
  {input = "prop", tag = "mo", output = "\226\136\157", tex = "propto", ttype = CONST},
  {input = "and", tag = "mtext", output = "and", tex = nil, ttype = SPACE},
  {input = "or", tag = "mtext", output = "or", tex = nil, ttype = SPACE},
  {input = "not", tag = "mo", output = "\194\172", tex = "neg", ttype = CONST},
  {input = "=>", tag = "mo", output = "\226\135\146", tex = "implies", ttype = CONST},
  {input = "if", tag = "mo", output = "if", tex = nil, ttype = SPACE},
  {input = "<=>", tag = "mo", output = "\226\135\148", tex = "iff", ttype = CONST},
  {input = "AA", tag = "mo", output = "\226\136\128", tex = "forall", ttype = CONST},
  {input = "EE", tag = "mo", output = "\226\136\131", tex = "exists", ttype = CONST},
  {input = "_|_", tag = "mo", output = "\226\138\165", tex = "bot", ttype = CONST},
  {input = "TT", tag = "mo", output = "\226\138\164", tex = "top", ttype = CONST},
  {input = "|--", tag = "mo", output = "\226\138\162", tex = "vdash", ttype = CONST},
  {input = "|==", tag = "mo", output = "\226\138\168", tex = "models", ttype = CONST},
  {input = "(", tag = "mo", output = "(", tex = nil, ttype = LEFTBRACKET},
  {input = ")", tag = "mo", output = ")", tex = nil, ttype = RIGHTBRACKET},
  {input = "[", tag = "mo", output = "[", tex = nil, ttype = LEFTBRACKET},
  {input = "]", tag = "mo", output = "]", tex = nil, ttype = RIGHTBRACKET},
  {input = "{", tag = "mo", output = "{", tex = nil, ttype = LEFTBRACKET},
  {input = "}", tag = "mo", output = "}", tex = nil, ttype = RIGHTBRACKET},
  {input = "|", tag = "mo", output = "|", tex = nil, ttype = LEFTRIGHT},
  {input = "(:", tag = "mo", output = "\226\140\169", tex = "langle", ttype = LEFTBRACKET},
  {input = ":)", tag = "mo", output = "\226\140\170", tex = "rangle", ttype = RIGHTBRACKET},
  {input = "<<", tag = "mo", output = "\226\140\169", tex = nil, ttype = LEFTBRACKET},
  {input = ">>", tag = "mo", output = "\226\140\170", tex = nil, ttype = RIGHTBRACKET},
  {input = "{:", tag = "mo", output = "{:", tex = nil, ttype = LEFTBRACKET, ["invisible"] = true},
  {input = ":}", tag = "mo", output = ":}", tex = nil, ttype = RIGHTBRACKET, ["invisible"] = true},
  {input = "int", tag = "mo", output = "\226\136\171", tex = nil, ttype = CONST},
  {input = "dx", tag = "mi", output = "{:d x:}", tex = nil, ttype = DEFINITION},
  {input = "dy", tag = "mi", output = "{:d y:}", tex = nil, ttype = DEFINITION},
  {input = "dz", tag = "mi", output = "{:d z:}", tex = nil, ttype = DEFINITION},
  {input = "dt", tag = "mi", output = "{:d t:}", tex = nil, ttype = DEFINITION},
  {input = "oint", tag = "mo", output = "\226\136\174", tex = nil, ttype = CONST},
  {input = "del", tag = "mo", output = "\226\136\130", tex = "partial", ttype = CONST},
  {input = "grad", tag = "mo", output = "\226\136\135", tex = "nabla", ttype = CONST},
  {input = "+-", tag = "mo", output = "\194\177", tex = "pm", ttype = CONST},
  {input = "O/", tag = "mo", output = "\226\136\133", tex = "emptyset", ttype = CONST},
  {input = "oo", tag = "mo", output = "\226\136\158", tex = "infty", ttype = CONST},
  {input = "aleph", tag = "mo", output = "\226\132\181", tex = nil, ttype = CONST},
  {input = "...", tag = "mo", output = "...", tex = "ldots", ttype = CONST},
  {input = ":.", tag = "mo", output = "\226\136\180", tex = "therefore", ttype = CONST},
  {input = "/_", tag = "mo", output = "\226\136\160", tex = "angle", ttype = CONST},
  {input = "/_\\", tag = "mo", output = "\226\150\179", tex = "triangle", ttype = CONST},
  {input = "'", tag = "mo", output = "\226\128\178", tex = "prime", ttype = CONST},
  {input = "tilde", tag = "mover", output = "~", tex = nil, ttype = UNARY, ["acc"] = true},
  {input = "\\ ", tag = "mo", output = " ", tex = nil, ttype = CONST},
  {input = "frown", tag = "mo", output = "\226\140\162", tex = nil, ttype = CONST},
  {input = "quad", tag = "mo", output = "  ", tex = nil, ttype = CONST},
  {input = "qquad", tag = "mo", output = "    ", tex = nil, ttype = CONST},
  {input = "cdots", tag = "mo", output = "\226\139\175", tex = nil, ttype = CONST},
  {input = "vdots", tag = "mo", output = "\226\139\174", tex = nil, ttype = CONST},
  {input = "ddots", tag = "mo", output = "\226\139\177", tex = nil, ttype = CONST},
  {input = "diamond", tag = "mo", output = "\226\139\132", tex = nil, ttype = CONST},
  {input = "square", tag = "mo", output = "\226\150\161", tex = nil, ttype = CONST},
  {input = "|__", tag = "mo", output = "\226\140\138", tex = "lfloor", ttype = CONST},
  {input = "__|", tag = "mo", output = "\226\140\139", tex = "rfloor", ttype = CONST},
  {input = "|~", tag = "mo", output = "\226\140\136", tex = "lceiling", ttype = CONST},
  {input = "~|", tag = "mo", output = "\226\140\137", tex = "rceiling", ttype = CONST},
  {input = "CC", tag = "mo", output = "\226\132\130", tex = nil, ttype = CONST},
  {input = "NN", tag = "mo", output = "\226\132\149", tex = nil, ttype = CONST},
  {input = "QQ", tag = "mo", output = "\226\132\154", tex = nil, ttype = CONST},
  {input = "RR", tag = "mo", output = "\226\132\157", tex = nil, ttype = CONST},
  {input = "ZZ", tag = "mo", output = "\226\132\164", tex = nil, ttype = CONST},
  {input = "f", tag = "mi", output = "f", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "g", tag = "mi", output = "g", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "lim", tag = "mo", output = "lim", tex = nil, ttype = UNDEROVER},
  {input = "Lim", tag = "mo", output = "Lim", tex = nil, ttype = UNDEROVER},
  {input = "sin", tag = "mo", output = "sin", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "cos", tag = "mo", output = "cos", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "tan", tag = "mo", output = "tan", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "sinh", tag = "mo", output = "sinh", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "cosh", tag = "mo", output = "cosh", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "tanh", tag = "mo", output = "tanh", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "cot", tag = "mo", output = "cot", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "sec", tag = "mo", output = "sec", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "csc", tag = "mo", output = "csc", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "arcsin", tag = "mo", output = "arcsin", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "arccos", tag = "mo", output = "arccos", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "arctan", tag = "mo", output = "arctan", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "coth", tag = "mo", output = "coth", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "sech", tag = "mo", output = "sech", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "csch", tag = "mo", output = "csch", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "exp", tag = "mo", output = "exp", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "abs", tag = "mo", output = "abs", tex = nil, ttype = UNARY, ["rewriteleftright"] = {"|", "|"}, 2},
  {input = "norm", tag = "mo", output = "norm", tex = nil, ttype = UNARY, ["rewriteleftright"] = {"\226\136\165", "\226\136\165"}, 2},
  {input = "floor", tag = "mo", output = "floor", tex = nil, ttype = UNARY, ["rewriteleftright"] = {"\226\140\138", "\226\140\139"}, 2},
  {input = "ceil", tag = "mo", output = "ceil", tex = nil, ttype = UNARY, ["rewriteleftright"] = {"\226\140\136", "\226\140\137"}, 2},
  {input = "log", tag = "mo", output = "log", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "ln", tag = "mo", output = "ln", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "det", tag = "mo", output = "det", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "dim", tag = "mo", output = "dim", tex = nil, ttype = CONST},
  {input = "mod", tag = "mo", output = "mod", tex = nil, ttype = CONST},
  {input = "gcd", tag = "mo", output = "gcd", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "lcm", tag = "mo", output = "lcm", tex = nil, ttype = UNARY, ["func"] = true},
  {input = "lub", tag = "mo", output = "lub", tex = nil, ttype = CONST},
  {input = "glb", tag = "mo", output = "glb", tex = nil, ttype = CONST},
  {input = "min", tag = "mo", output = "min", tex = nil, ttype = UNDEROVER},
  {input = "max", tag = "mo", output = "max", tex = nil, ttype = UNDEROVER},
  {input = "uarr", tag = "mo", output = "\226\134\145", tex = "uparrow", ttype = CONST},
  {input = "darr", tag = "mo", output = "\226\134\147", tex = "downarrow", ttype = CONST},
  {input = "rarr", tag = "mo", output = "\226\134\146", tex = "rightarrow", ttype = CONST},
  {input = "->", tag = "mo", output = "\226\134\146", tex = "to", ttype = CONST},
  {input = ">->", tag = "mo", output = "\226\134\163", tex = "rightarrowtail", ttype = CONST},
  {input = "->>", tag = "mo", output = "\226\134\160", tex = "twoheadrightarrow", ttype = CONST},
  {input = ">->>", tag = "mo", output = "\226\164\150", tex = "twoheadrightarrowtail", ttype = CONST},
  {input = "|->", tag = "mo", output = "\226\134\166", tex = "mapsto", ttype = CONST},
  {input = "larr", tag = "mo", output = "\226\134\144", tex = "leftarrow", ttype = CONST},
  {input = "harr", tag = "mo", output = "\226\134\148", tex = "leftrightarrow", ttype = CONST},
  {input = "rArr", tag = "mo", output = "\226\135\146", tex = "Rightarrow", ttype = CONST},
  {input = "lArr", tag = "mo", output = "\226\135\144", tex = "Leftarrow", ttype = CONST},
  {input = "hArr", tag = "mo", output = "\226\135\148", tex = "Leftrightarrow", ttype = CONST},
  {input = "sqrt", tag = "msqrt", output = "sqrt", tex = nil, ttype = UNARY},
  {input = "root", tag = "mroot", output = "root", tex = nil, ttype = BINARY},
  {input = "frac", tag = "mfrac", output = "/", tex = nil, ttype = BINARY},
  {input = "/", tag = "mfrac", output = "/", tex = nil, ttype = INFIX},
  {input = "stackrel", tag = "mover", output = "stackrel", tex = nil, ttype = BINARY},
  {input = "overset", tag = "mover", output = "stackrel", tex = nil, ttype = BINARY},
  {input = "underset", tag = "munder", output = "stackrel", tex = nil, ttype = BINARY},
  {input = "_", tag = "msub", output = "_", tex = nil, ttype = INFIX},
  {input = "^", tag = "msup", output = "^", tex = nil, ttype = INFIX},
  {input = "hat", tag = "mover", output = "^", tex = nil, ttype = UNARY, ["acc"] = true},
  {input = "bar", tag = "mover", output = "\194\175", tex = "overline", ttype = UNARY, ["acc"] = true},
  {input = "vec", tag = "mover", output = "\226\134\146", tex = nil, ttype = UNARY, ["acc"] = true},
  {input = "dot", tag = "mover", output = ".", tex = nil, ttype = UNARY, ["acc"] = true},
  {input = "ddot", tag = "mover", output = "..", tex = nil, ttype = UNARY, ["acc"] = true},
  {input = "ul", tag = "munder", output = "\204\178", tex = "underline", ttype = UNARY, ["acc"] = true},
  {input = "ubrace", tag = "munder", output = "\226\143\159", tex = "underbrace", ttype = UNARYUNDEROVER, ["acc"] = true},
  {input = "obrace", tag = "mover", output = "\226\143\158", tex = "overbrace", ttype = UNARYUNDEROVER, ["acc"] = true},
  {input = "text", tag = "mtext", output = "text", tex = nil, ttype = TEXT},
  {input = "mbox", tag = "mtext", output = "mbox", tex = nil, ttype = TEXT},
  {input = "color", tag = "mstyle", ttype = BINARY},
  {input = "cancel", tag = "menclose", output = "cancel", tex = nil, ttype = UNARY},
  AMquote,
  {input = "bb", tag = "mstyle", atname = "mathvariant", atval = "bold", output = "bb", tex = nil, ttype = UNARY},
  {input = "mathbf", tag = "mstyle", atname = "mathvariant", atval = "bold", output = "mathbf", tex = nil, ttype = UNARY},
  {input = "sf", tag = "mstyle", atname = "mathvariant", atval = "sans-serif", output = "sf", tex = nil, ttype = UNARY},
  {input = "mathsf", tag = "mstyle", atname = "mathvariant", atval = "sans-serif", output = "mathsf", tex = nil, ttype = UNARY},
  {input = "bbb", tag = "mstyle", atname = "mathvariant", atval = "double-struck", output = "bbb", tex = nil, ttype = UNARY, codes = AMbbb},
  {input = "mathbb", tag = "mstyle", atname = "mathvariant", atval = "double-struck", output = "mathbb", tex = nil, ttype = UNARY, codes = AMbbb},
  {input = "cc", tag = "mstyle", atname = "mathvariant", atval = "script", output = "cc", tex = nil, ttype = UNARY, codes = AMcal},
  {input = "mathcal", tag = "mstyle", atname = "mathvariant", atval = "script", output = "mathcal", tex = nil, ttype = UNARY, codes = AMcal},
  {input = "tt", tag = "mstyle", atname = "mathvariant", atval = "monospace", output = "tt", tex = nil, ttype = UNARY},
  {input = "mathtt", tag = "mstyle", atname = "mathvariant", atval = "monospace", output = "mathtt", tex = nil, ttype = UNARY},
  {input = "fr", tag = "mstyle", atname = "mathvariant", atval = "fraktur", output = "fr", tex = nil, ttype = UNARY, codes = AMfrk},
  {input = "mathfrak", tag = "mstyle", atname = "mathvariant", atval = "fraktur", output = "mathfrak", tex = nil, ttype = UNARY, codes = AMfrk},
}

local AMnames = {}; --list of input symbols

local function refreshSymbols()
  table.sort(AMsymbols, function(s1,s2)
    return s1.input < s2.input
  end)
  for i in ipairs(AMsymbols) do
    AMnames[i] = AMsymbols[i].input
  end
end

local function initSymbols()
  local symlen = #AMsymbols
  for i=1,symlen do
    if AMsymbols[i].tex then
      AMsymbols[#AMsymbols+1] = {
        input=AMsymbols[i].tex, tag=AMsymbols[i].tag, output=AMsymbols[i].output, ttype=AMsymbols[i].ttype, acc=AMsymbols[i].acc,
      }
    end
  end
  refreshSymbols()
end

function asciimath.init()
  -- var msg, warnings = new Array()
  if not noMathML then initSymbols() end
  return true
end


local function define(oldstr,newstr)
  AMsymbols[#AMsymbols+1] = {input=oldstr, tag="mo", output=newstr, tex=nil, ttype=DEFINITION}
  refreshSymbols() -- this may be a problem if many symbols are defined!
end

--remove n characters and any following blanks
local function AMremoveCharsAndBlanks(str,n)
  local st = str:sub(n+1)
  if st:sub(1,1)=='\\' and st:sub(2,2)~='\\' and st:sub(2,2)~=' ' then
    st = st:sub(2)
  end
  for i = 1, #st do
    if st:sub(i,i):byte() > 32 then
      return st:sub(i)
    end
  end
  return ''
end

-- return position >=n where str appears or would be inserted
-- assumes arr is sorted
local function position(arr, str, n)
  -- TODO(akavel): optimize if necessary (bisect?); original JS version was
  -- better optimized, here I translated a naive version
  for i = n, #arr do
    if arr[i] >= str then
      return i
    end
  end
  return #arr
end

-- return maximal initial substring of str that appears in names
-- return null if there is none
local function AMgetSymbol(str)
  local k = 1  -- new pos
  local j = 1  -- old pos
  local mk  -- match pos
  local st
  local tagst
  local match = ''
  local more = true
  for i = 1,#str do
    if not more then break end
    st = str:sub(1, i)  -- initial substring of length i
    j = k
    k = position(AMnames, st, j)
    if k<=#AMnames and str:sub(1, #AMnames[k]) == AMnames[k] then
      match = AMnames[k]
      mk = k
      i = #match
    end
    more = (k <= #AMnames and str:sub(1, #AMnames[k]) >= AMnames[k])
  end
  AMpreviousSymbol = AMcurrentSymbol
  if match ~= '' then
    AMcurrentSymbol = AMsymbols[mk].ttype
    return AMsymbols[mk]
  end
  -- if str[1] is a digit or - return maxsubstring of digits.digits
  AMcurrentSymbol = CONST
  k = 1
  st = str:sub(1, 1)
  local integ = true
  while '0' <= st and st <= '9' and k <= #str do
    k = k+1
    st = str:sub(k, k)
  end
  if st == decimalsign then
    st = str:sub(k+1, k+1)
    if '0' <= st and st <= '9' then
      integ = false
      k = k+1
      while '0' <= st and st <= '9' and k <= #str do
        k = k+1
        st = str:sub(k, k)
      end
    end
  end
  if (integ and k>1) or k>2 then
    st = str:sub(1, k-1)
    tagst = 'mn'
  else
    k = 2
    st = str:sub(1, 1)  -- take 1 character
    if ('A' > st or st > 'Z') and ('a' > st or st > 'z') then
      tagst = 'mo'
    else
      tagst = 'mi'
    end
  end
  if st == '-' and AMpreviousSymbol == INFIX then
    AMcurrentSymbol = INFIX  -- trick '/' into recognizing '-' on second parse
    return {input=st, tag=tagst, output=st, ttype=UNARY, func=true}
  end
  return {input=st, tag=tagst, output=st, ttype=CONST}
end

local function AMremoveBrackets(node)
  local st
  if not node:hasChildNodes() then return end
  if node.firstChild:hasChildNodes() and (node.nodeName=='mrow' or node.nodeName=='M:MROW') then
    st = node.firstChild.firstChild.nodeValue
    if st=='(' or st=='[' or st=='{' then
      node:removeChild(node.firstChild)
    end
  end
  if node.lastChild:hasChildNodes() and (node.nodeName=='mrow' or node.nodeName=='M:MROW') then
    st = node.lastChild.firstChild.nodeValue
    if st==')' or st==']' or st=='}' then
      node:removeChild(node.lastChild)
    end
  end
end

--[[
Parsing ASCII math expressions with the following grammar
v ::= [A-Za-z] | greek letters | numbers | other constant symbols
u ::= sqrt | text | bb | other unary symbols for font commands
b ::= frac | root | stackrel         binary symbols
l ::= ( | [ | { | (: | {:            left brackets
r ::= ) | ] | } | :) | :}            right brackets
S ::= v | lEr | uS | bSS             Simple expression
I ::= S_S | S^S | S_S^S | S          Intermediate expression
E ::= IE | I/I                       Expression
Each terminal symbol is translated into a corresponding mathml node.
--]]

local AMnestingDepth, AMpreviousSymbol, AMcurrentSymbol

-- parses str and returns (node,tailstr)
function AMparseSexpr(str)
  local symbol, node, result, i, st
  local newFrag = document:createDocumentFragment()
  str = AMremoveCharsAndBlanks(str, 0)
  symbol = AMgetSymbol(str)  -- either a token or a bracket or empty
  if symbol == nil or symbol.ttype == RIGHTBRACKET and AMnestingDepth > 0 then
    return nil, str
  end
  if symbol.ttype == DEFINITION then
    str = symbol.output .. AMremoveCharsAndBlanks(str, #symbol.input)
    symbol = AMgetSymbol(str)
  end
  local case = symbol.ttype
  if case==UNDEROVER or case==CONST then
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    return createMmlNode(symbol.tag,  -- its a constant
                         document:createTextNode(symbol.output)), str
  elseif case==LEFTBRACKET then  -- read (expr+)
    AMnestingDepth = AMnestingDepth + 1
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    result = {AMparseExpr(str, true)}
    AMnestingDepth = AMnestingDepth - 1
    if type(symbol.invisible) == 'boolean' and symbol.invisible then
      node = createMmlNode('mrow', result[1])
    else
      node = createMmlNode('mo', document:createTextNode(symbol.output))
      node = createMmlNode('mrow', node)
      node:appendChild(result[1])
    end
    return node, result[2]
  elseif case==TEXT then
    if symbol~=AMquote then
      str = AMremoveCharsAndBlanks(str, #symbol.input)
    end
    if str:sub(1,1)=='{' then
      i = str:find('}', 1, true)
    elseif str:sub(1,1)=='(' then
      i = str:find(')', 1, true)
    elseif str:sub(1,1)=='[' then
      i = str:find(']', 1, true)
    elseif symbol==AMquote then
      i = str:find('"', 2, true)
    else
      i = 1
    end
    if i == nil then
      i = #str+1
    end
    i = i-1
    st = str:sub(2,i)
    if st:sub(1,1) == ' ' then
      node = createMmlNode('mspace')
      node:setAttribute('width', '1ex')
      newFrag:appendChild(node)
    end
    newFrag:appendChild(
      createMmlNode(symbol.tag, document:createTextNode(st)))
    if st:sub(-1) == ' ' then
      node = createMmlNode('mspace')
      node:setAttribute('width', '1ex')
      newFrag:appendChild(node)
    end
    str = AMremoveCharsAndBlanks(str, i+1)
    return createMmlNode('mrow', newFrag), str
  elseif case==UNARYUNDEROVER or case==UNARY then
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    result = {AMparseSexpr(str)}
    if result[1] == nil then
      return createMmlNode(symbol.tag,
        document:createTextNode(symbol.output)), str
    end
    if type(symbol.func)=='boolean' and symbol.func then  -- functions hack
      st = str:sub(1,1)
      if st=='^' or st=='_' or st=='/' or st=='|' or st==',' or
        (#symbol.input==1 and symbol.input:match('%w') and st~='(') then
        return createMmlNode(symbol.tag,
          document:createTextNode(symbol.output)), str
      else
        node = createMmlNode('mrow',
          createMmlNode(symbol.tag, document:createTextNode(symbol.output)))
        node:appendChild(result[1])
        return node, result[2]
      end
    end
    AMremoveBrackets(result[1])
    if symbol.input == 'sqrt' then  -- sqrt
      return createMmlNode(symbol.tag, result[1]), result[2]
    elseif type(symbol.rewriteleftright) ~= 'nil' then  -- abs, floor, ceil
      node = createMmlNode('mrow', createMmlNode('mo', document:createTextNode(symbol.rewriteleftright[1])))
      node:appendChild(result[1])
      node:appendChild(createMmlNode('mo', document:createTextNode(symbol.rewriteleftright[2])))
      return node, result[2]
    elseif symbol.input == 'cancel' then  -- cancel
      node = createMmlNode(symbol.tag, result[1])
      node:setAttribute('notation', 'updiagonalstrike')
      return node, result[2]
    elseif type(symbol.acc) == 'boolean' and symbol.acc then  -- accent
      node = createMmlNode(symbol.tag, result[1])
      node:appendChild(createMmlNode('mo', document:createTextNode(symbol.output)))
      return node, result[2]
    else  -- font change command
      if type(symbol.codes) ~= 'nil' then
        for i = 1, #result[1].childNodes do
          if result[1].childNodes[i].nodeName == 'mi' or result[1].nodeName == 'mi' then
            if result[1].nodeName == 'mi' then
              st = result[1].firstChild.nodeValue
            else
              st = result[1].childNodes[i].firstChild.nodeValue
            end
            local newst = ''
            for j = 1, #st do
              -- FIXME(akavel): make sure below works ok for UTF-8 chars...
              if charCodeAt(st, j)>64 and charCodeAt(st, j)<91 then
                newst = newst .. symbol.codes[charCodeAt(st, j)-64]
              elseif charCodeAt(st, j)>96 and charCodeAt(st, j)<123 then
                newst = newst .. symbol.codes[charCodeAt(st, j)-70]
              else
                newst = newst .. charAt(st, j)
              end
            end
            if result[1].nodeName == 'mi' then
              result[1] = createMmlNode('mo'):
                appendChild(document:createTextNode(newst))
            else
              result[1]:replaceChild(createMmlNode('mo'):
                appendChild(document:createTextNode(newst)),
                result[1].childNodes[i])
            end
          end
        end
      end
      node = createMmlNode(symbol.tag, result[1])
      node:setAttribute(symbol.atname, symbol.atval)
      return node, result[2]
    end
  elseif case==BINARY then
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    result = {AMparseSexpr(str)}
    if result[1]==nil then
      return createMmlNode('mo',
        document:createTextNode(symbol.input)), str
    end
    AMremoveBrackets(result[1])
    local result2 = {AMparseSexpr(result[2])}
    if result2[1]==nil then
      return createMmlNode('mo',
        document:createTextNode(symbol.input)), str
    end
    AMremoveBrackets(result2[1])
    if symbol.input == 'color' then
      if str:sub(1,1)=='{' then i=str:find('}', 1, true)
      elseif str:sub(1,1)=='(' then i=str:find(')', 1, true)
      elseif str:sub(1,1)=='[' then i=str:find(']', 1, true)
      end
      st = str:sub(2,i-1)
      node = createMmlNode(symbol.tag, result2[1])
      node:setAttribute('mathcolor', st)
      return node, result2[2]
    end
    if symbol.input == 'root' or symbol.output == 'stackrel' then
      newFrag:appendChild(result2[1])
    end
    newFrag:appendChild(result[1])
    if symbol.input == 'frac' then
      newFrag:appendChild(result2[1])
    end
    return createMmlNode(symbol.tag, newFrag), result2[2]
  elseif case==INFIX then
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    return createMmlNode('mo', document:createTextNode(symbol.output)), str
  elseif case==SPACE then
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    node = createMmlNode('mspace')
    node:setAttribute('width', '1ex')
    newFrag:appendChild(node)
    newFrag:appendChild(
      createMmlNode(symbol.tag, document:createTextNode(symbol.output)))
    node = createMmlNode('mspace')
    node:setAttribute('width', '1ex')
    newFrag:appendChild(node)
    return createMmlNode('mrow', newFrag), str
  elseif case==LEFTRIGHT then
    AMnestingDepth = AMnestingDepth + 1
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    result = {AMparseExpr(str, false)}
    AMnestingDepth = AMnestingDepth - 1
    st = ''
    if result[1].lastChild ~= nil then
      st = result[1].lastChild.firstChild.nodeValue
    end
    if st == '|' then  -- its an absolute value subterm
      node = createMmlNode('mo', document:createTextNode(symbol.output))
      node = createMmlNode('mrow', node)
      node:appendChild(result[1])
      return node, result[2]
    else  -- the '|' is a \mid so use unicode 2223 (divides) for spacing
      node = createMmlNode('mo', document:createTextNode('\226\136\163'))
      node = createMmlNode('mrow', node)
      return node, str
    end
  else  -- default
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    return createMmlNode(symbol.tag,  -- its a constant
                         document:createTextNode(symbol.output)), str
  end
end

local function AMparseIexpr(str)
  local symbol, sym1, sym2, node, result, underover
  str = AMremoveCharsAndBlanks(str, 0)
  sym1 = AMgetSymbol(str)
  result = {AMparseSexpr(str)}
  node = result[1]
  str = result[2]
  symbol = AMgetSymbol(str)
  if symbol.ttype == INFIX and symbol.input ~= '/' then
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    result = {AMparseSexpr(str)}
    if result[1] == nil then  -- show box in place of missing argument
      result[1] = createMmlNode('mo', document:createTextNode('\226\150\161'))
    else
      AMremoveBrackets(result[1])
    end
    str = result[2]
    underover = (sym1.ttype == UNDEROVER or sym1.ttype == UNARYUNDEROVER)
    if symbol.input == '_' then
      sym2 = AMgetSymbol(str)
      if sym2.input == '^' then
        str = AMremoveCharsAndBlanks(str, #sym2.input)
        local res2 = {AMparseSexpr(str)}
        AMremoveBrackets(res2[1])
        str = res2[2]
        if underover then
          node = createMmlNode('munderover', node)
        else
          node = createMmlNode('msubsup', node)
        end
        node:appendChild(result[1])
        node:appendChild(res2[1])
        node = createMmlNode('mrow', node)  -- so sum does not stretch
      else
        if underover then
          node = createMmlNode('munder', node)
        else
          node = createMmlNode('msub', node)
        end
        node:appendChild(result[1])
      end
    elseif symbol.input == '^' and underover then
      node = createMmlNode('mover', node)
      node:appendChild(result[1])
    else
      node = createMmlNode(symbol.tag, node)
      node:appendChild(result[1])
    end
    if type(sym1.func)~='nil' and sym1.func then
      sym2 = AMgetSymbol(str)
      if sym2.ttype ~= INFIX and sym2.ttype ~= RIGHTBRACKET then
        result = {AMparseIexpr(str)}
        node = createMmlNode('mrow', node)
        node:appendChild(result[1])
        str = result[2]
      end
    end
  end
  return node, str
end

function AMparseExpr(str, rightbracket)
  local symbol, node, result, i, newFrag
  newFrag = document:createDocumentFragment()
  repeat
    str = AMremoveCharsAndBlanks(str, 0)
    result = {AMparseIexpr(str)}
    node = result[1]
    str = result[2]
    symbol = AMgetSymbol(str)
    if symbol.ttype == INFIX and symbol.input == '/' then
      str = AMremoveCharsAndBlanks(str, #symbol.input)
      result = {AMparseIexpr(str)}
      if result[1] == nil then  -- show box in place of missing argument
        result[1] = createMmlNode('mo', document:createTextNode('\226\150\161'))
      else
        AMremoveBrackets(result[1])
      end
      str = result[2]
      AMremoveBrackets(node)
      node = createMmlNode(symbol.tag, node)
      node:appendChild(result[1])
      newFrag:appendChild(node)
      symbol = AMgetSymbol(str)
    elseif node~=nil then
      newFrag:appendChild(node)
    end
  until not ((symbol.ttype ~= RIGHTBRACKET and
           (symbol.ttype ~= LEFTRIGHT or rightbracket)
           or AMnestingDepth == 0) and symbol~=nil and symbol.output~="")
  if symbol.ttype == RIGHTBRACKET or symbol.ttype == LEFTRIGHT then
    local len = #newFrag.childNodes
    if len>0 and newFrag.childNodes[len].nodeName == 'mrow'
      and newFrag.childNodes[len].lastChild
      and newFrag.childNodes[len].lastChild.firstChild then  -- matrix
      local right = newFrag.childNodes[len].lastChild.firstChild.nodeValue
      if right==')' or right==']' then
        local left = newFrag.childNodes[len].firstChild.firstChild.nodeValue
        if left=='(' and right==')' and symbol.output~='}' or
          left=='[' and right==']' then
          local pos = {}  -- positions of commas
          local matrix = true
          local m = #newFrag.childNodes
          local i = 1
          while matrix and i<=m do
            pos[i-1] = {}  -- NOTE(akavel): required for #pos to work OK in Lua
            pos[i] = {}
            node = newFrag.childNodes[i]
            if matrix then
              matrix = node.nodeName=='mrow' and
                (i==m or node.nextSibling.nodeName=='mo' and
                  node.nextSibling.firstChild.nodeValue==',') and
                node.firstChild.firstChild.nodeValue==left and
                node.lastChild.firstChild.nodeValue==right
            end
            if matrix then
              for j = 1, #node.childNodes do
                if node.childNodes[j].firstChild.nodeValue==',' then
                  pos[i][#pos[i]+1] = j
                end
              end
            end
            if matrix and i>2 then
              matrix = (#pos[i] == #pos[i-2])
            end
            i = i+2
          end
          matrix = matrix and (#pos>1 or #pos[1]>0)
          if matrix then
            local row, frag, n, k, table
            table = document:createDocumentFragment()
            local i = 1
            while i<=m do
              row = document:createDocumentFragment()
              frag = document:createDocumentFragment()
              node = newFrag.firstChild  -- <mrow>(-,-,...,-,-)</mrow>
              n = #node.childNodes
              k = 1
              node:removeChild(node.firstChild)  -- remove (
              for j = 2, n-1 do
                if type(pos[i][k]) ~= 'nil' and j==pos[i][k] then
                  node:removeChild(node.firstChild)  -- remove ,
                  row:appendChild(createMmlNode('mtd', frag))
                  k = k + 1
                else
                  frag:appendChild(node.firstChild)
                end
              end
              row:appendChild(createMmlNode('mtd', frag))
              if #newFrag.childNodes > 2 then
                newFrag:removeChild(newFrag.firstChild)  -- remove <mrow>)</mrow>
                newFrag:removeChild(newFrag.firstChild)  -- remove <mo>,</mo>
              end
              table:appendChild(createMmlNode('mtr', row))
              i = i+2
            end
            node = createMmlNode('mtable', table)
            if type(symbol.invisible) == 'boolean' and symbol.invisible then
              node:setAttribute('columnalign', 'left')
            end
            newFrag:replaceChild(node, newFrag.firstChild)
          end
        end
      end
    end
    str = AMremoveCharsAndBlanks(str, #symbol.input)
    if type(symbol.invisible) ~= 'boolean' or not symbol.invisible then
      node = createMmlNode('mo', document:createTextNode(symbol.output))
      newFrag:appendChild(node)
    end
  end
  return newFrag, str
end

function asciimath.parseMath(str, latex)
  local frag, node
  AMnestingDepth = 0
  -- some basic cleanup for dealing with stuff editors like TinyMCE adds
  str = string.gsub(str, '&nbsp;', '')
  str = string.gsub(str, '&gt;', '>')
  str = string.gsub(str, '&lt;', '<')
  for _,f in ipairs{'Sin', 'Cos', 'Tan', 'Arcsin', 'Arccos', 'Arctan', 'Sinh', 'Cosh', 'Tanh', 'Cot', 'Sec', 'Csc', 'Log', 'Ln', 'Abs'} do
    str = string.gsub(str, f, f:lower())
  end
  frag = ({AMparseExpr(string.gsub(str, '^%s+', ''), false)})[1]
  node = createMmlNode('mstyle', frag)
  if mathcolor ~= '' then
    node:setAttribute('mathcolor', mathcolor)
  end
  if mathfontfamily ~= '' then
    node:setAttribute('fontfamily', mathfontfamily)
  end
  if displaystyle then
    node:setAttribute('displaystyle', 'true')
  end
  node = createMmlNode('math', node)
  if showasciiformulaonhover then  -- fixed by djhsu so newline
    node:setAttribute('title', string.gsub(str, '%s+', ' '))  -- does not show in Gecko
  end
  return node
end







return asciimath


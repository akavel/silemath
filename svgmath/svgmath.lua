
local setfenv, unpack = setfenv, (unpack or table.unpack)
local setmetatable, require, xpcall, string = setmetatable, require, xpcall, string
local error, table = error, table
local PYLUA = require('svgmath.PYLUA')
local sax = require('svgmath.xml').sax
local XMLGenerator = require('svgmath.tools.saxtools').XMLGenerator
local ContentFilter = require('svgmath.tools.saxtools').ContentFilter
local MathHandler = require('svgmath.mathhandler').MathHandler
local MathNS = require('svgmath.mathhandler').MathNS
local MathEntityResolver = require('svgmath.mathhandler').MathEntityResolver
local _ENV = {package=package}
if setfenv then setfenv(1, _ENV) end

MathFilter = PYLUA.class(ContentFilter) {

  __init__ = function(self, out, mathout)
    ContentFilter.__init__(self, out)
    self.plainOutput = out
    self.mathOutput = mathout
    self.depth = 0
  end
  ;

  -- ContentHandler methods
  setDocumentLocator = function(self, locator)
    self.plainOutput:setDocumentLocator(locator)
    self.mathOutput:setDocumentLocator(locator)
  end
  ;

  startElementNS = function(self, elementName, qName, attrs)
    if self.depth==0 then
      local namespace, localName = unpack(elementName)
      if namespace==MathNS then
        self.output = self.mathOutput
        self.depth = 1
      end
    else
      self.depth = self.depth+1
    end
    ContentFilter.startElementNS(self, elementName, qName, attrs)
  end
  ;

  endElementNS = function(self, elementName, qName)
    ContentFilter.endElementNS(self, elementName, qName)
    if self.depth>0 then
      self.depth = self.depth-1
      if self.depth==0 then
        self.output = self.plainOutput
      end
    end
  end
  ;
}

local function fakeFile()
  return setmetatable({}, {__index={
    write = function(self, string)
      self[#self+1] = string
    end,
    reset = function() end,
    tostring = function(self)
      return table.concat(self, '')
    end,
  }})
end

mathml2svg = function(source)
  local output = fakeFile()
  local encoding = 'utf-8'
  local standalone = false  -- TODO(akavel): or true?

  -- TODO(akavel): dynamically generate config based on font
  local config = require 'svgmath.config'

  -- Create the converter as a content handler. 
  local saxoutput = XMLGenerator(output, encoding)
  local handler = MathHandler(saxoutput, config)
  if not standalone then
    handler = MathFilter(saxoutput, handler)
  end

  -- Parse input file
  local exitcode = 0
  local ok, ret = xpcall(function()
    parser = sax.make_parser()
    parser:setFeature(sax.handler.feature_namespaces, 1)
    --parser:setEntityResolver(MathEntityResolver())
    parser:setContentHandler(handler)
    parser:parse(source)
  end, PYLUA.traceback)
  if not ok then
    local xcpt = ret
    if PYLUA.is_a(ret, sax.SAXException) then
      error(string.format('Error parsing input file: %s', xcpt:getMessage()))
    else
      error(ret)
    end
  end
  return output:tostring()
end

return _ENV

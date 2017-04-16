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
	createDocumentFragment = function(...) print('hello0!',...) end
}
env.createDocumentFragment = function(...) print('hello1!', ...) end
env.this.createDocumentFragment = function(...) print('hello2!', ...) end
_G.createDocumentFragment = function(...) print('hello3!', ...) end
env._G = env._obj({})
env._G.createDocumentFragment = function(...) print('hello4!', ...) end

local input = "!="
local expectedOutput = "<mo>≠</mo>"
local res = asciimath.parseMath(nil, input)
print(res)
print(expectedOutput)

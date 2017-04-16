local chunk = assert(loadfile 'asciimath.lua')
local aml = chunk()

local env = require 'castl.runtime'

print '--castl.runtime'
t = {}
for k,v in pairs(env) do t[#t+1]=k end
table.sort(t)
for _,k in ipairs(t) do print(k) end

print()
print '--_G'
t = {}
for k,v in pairs(env) do t[#t+1]=k end
table.sort(t)
for _,k in ipairs(t) do print(k) end

print()
print '--env.this'
if type(env.this) == 'table' then
	for k,v in pairs(aml) do print(k,v) end
end

print()
print '--aml'
for k,v in pairs(aml) do print(k,v) end


--[[
local castl = require 'castl.runtime'
local x = castl._obj({})

local _ENV = require("castl.runtime")
local asciimath

asciimath = _obj({})
--]]

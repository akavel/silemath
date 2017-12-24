function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
end

local svg = require 'justenoughsvg'
local mm = require 'justenoughmatrix'

-- load MathML SVG image
local f = assert(io.open('sample/test13.out.svg'))
local mathml = svg.parse(function() return f:read(1) end)
f:close()

print('hello')
-- load fonts
-- (https://superuser.com/a/1072309/12184 - HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts)
font_files = {
  ["DejaVu Serif"] = "DejaVuSerif.ttf",
}
--font_dir = "C:/windows/fonts"
-- TODO: is the font size in SVG specified in pixels, or something else?
local function load_fonts(svg, fonts)
  --print('enter')
  local fonts = fonts or {}
  for _, elem in ipairs(svg) do
    if type(elem) == 'table' then
      --print't'
      if elem.name == 'text' then
        local family = elem.attrs.font_family
        local size = elem.attrs.font_size
        local key = family .. ' ' .. size
        if not fonts[key] then
          print(key)
          fonts[key] = love.graphics.newFont(
            font_files[family],
            0 + size)
        end
      else
        load_fonts(elem.childs or {}, fonts)
      end
    end
  end
  return fonts
end
local fonts = load_fonts(mathml.childs)

function love.draw()
  
  
  love.graphics.setColor(20,255,0,255)
  love.graphics.print("Hello", 100, 100)
end


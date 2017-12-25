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
  ["DejaVu Serif regular"] = "DejaVuSerif.ttf",
  ["DejaVu Serif italic"] = "DejaVuSerif-Italic.ttf",
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
        local style = elem.attrs.font_style or 'regular'
        local size = elem.attrs.font_size
        local key = family .. ' ' .. style .. ' ' .. size
        if not fonts[key] then
          print(key)
          fonts[key] = love.graphics.newFont(
            font_files[family .. ' ' .. style],
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

local function render(svg, fonts, matrices)
  local matrices = matrices or {mm.translate(20,40)}
  -- TODO: process viewBox attribute
  local m0 = matrices[#matrices]
  local m
  if svg.attrs and svg.attrs.translate1 then
    m = mm.mul(m0, mm.translate(svg.attrs.translate1, svg.attrs.translate2))
  elseif svg.attrs and svg.attrs.scale1 then
    m = mm.mul(m0, mm.scale(svg.attrs.scale1, svg.attrs.scale2))
  end
  if m then
    matrices[#matrices+1] = m
    m0 = m
  end
  -- maybe render
  if svg.name == 'text' then
    local font = fonts[svg.attrs.font_family .. ' ' .. (svg.attrs.font_style or 'regular') .. ' ' .. svg.attrs.font_size]
    love.graphics.setFont(font)
    local dy = -font:getAscent()
    local x, y = mm.apply(m0, svg.attrs.x, svg.attrs.y)
    local text = svg.childs[1]
    local w = font:getWidth(text) * m0[1]
    love.graphics.print(text, x-w/2, y+dy, 0, m0[1], m0[4], 0, 0)
--    print(('  '):rep(#matrices) .. '"' .. text .. '" (' .. svg.attrs.x .. ', ' .. svg.attrs.y .. ') = ' .. x .. ', ' .. y)
--    love.graphics.rectangle('line', x, y+dy, w, svg.attrs.font_size)
  elseif svg.name == 'line' then
    local x1, y1 = mm.apply(m0, svg.attrs.x1, svg.attrs.y1)
    local x2, y2 = mm.apply(m0, svg.attrs.x2, svg.attrs.y2)
    love.graphics.line(x1, y1, x2, y2)
  else
    for _,el in ipairs(svg.childs or {}) do
      render(el, fonts, matrices)
    end
  end
  -- pop transformation matrix if pushed
  if m then
    matrices[#matrices] = nil
  end
end

i = 0
function love.draw()
  
  love.graphics.setColor(20,255,0,255)
  love.graphics.print("Hello", 100, 100)
  love.graphics.print("ORIGIN", 0,0)
  
  render(mathml, fonts)
  i = i + 1
  if i==3 then print = function() end end
end


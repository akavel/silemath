
-- below enables SU.debug('silemath', 'some text') to print something, per sile.sil
SILE.debugFlags.silemath = 1

-- local asciimath = require 'asciimath.asciimath'
local asciimath = require 'asciimath2'
local svg = require 'justenoughsvg'
local pdf = require 'justenoughlibtexpdf'

local function renderGlyph(glyph, x, y, fontoptions)
  -- below 2 lines load raw font from cache (or disk if not cached); first
  -- occurrence results in 'Resolved font ...' message
  local fontoptions = SILE.font.loadDefaults(fontoptions)
  -- TODO: [LATER] use 'current outputter' (SILE.outputter.outputHbox) instead of explicit libtexpdf?
  SILE.outputters.libtexpdf.setFont(fontoptions)
  -- FIXME: below block feels overcomplicated and probably against the flow; can it be simplified?
  local shape = SILE.shaper:shapeToken(glyph, fontoptions)
  shape[1].width = 0
  shape[1].x_offset = x
  shape[1].y_offset = y
  -- FIXME: below 'dummy' triggers correct branch in libtexpdf-output's outputHbox
  SILE.outputters.libtexpdf.outputHbox{
    complex=true,
    glyphString='dummy',
    items=shape
  }
end

local function render(svg, matrices)
  -- TODO: process viewBox attribute
  local m = 0
  if svg.attrs and svg.attrs.translate1 then
    pdf:gsave()
    m = m+1
    pdf.setmatrix(1,0,0,1, svg.attrs.translate1, -svg.attrs.translate2)
  elseif svg.attrs and svg.attrs.scale1 then
    pdf:gsave()
    m = m+1
    pdf.setmatrix(svg.attrs.scale1, 0, 0, svg.attrs.scale2, 0, 0)
  end
  -- maybe render
  if svg.name == 'text' then
    -- local dy = -font:getAscent()
    local text = svg.childs[1]
    pdf:gsave()
    -- FIXME: glyph should be centered horizontally at svg.attrs.x
    pdf.setmatrix(1,0,0,1, svg.attrs.x, -svg.attrs.y)
    renderGlyph(text, 0, 0, {
      family = svg.attrs.font_family,
      style = svg.attrs.font_style or '',
      size = svg.attrs.font_size,
    })
    pdf:grestore()
    -- love.graphics.print(text, x-w/2, y+dy, 0, m0[1], m0[4], 0, 0)
    -- love.graphics.rectangle('line', x, y+dy, w, svg.attrs.font_size)
  elseif svg.name == 'line' then
    -- FIXME: somehow use svg.attrs.stroke_width when drawing the line
    local x1, y1 = svg.attrs.x1, svg.attrs.y1
    local x2, y2 = svg.attrs.x2, svg.attrs.y2
    pdf.add_content("q")
    pdf.add_content(x1 .. ' ' .. y1 .. ' m')
    pdf.add_content(x2 .. ' ' .. y2 .. ' l')
    pdf.add_content("S")
    pdf.add_content("Q")
  else
    for _,el in ipairs(svg.childs or {}) do
      render(el, matrices)
    end
  end
  -- pop transformation matrix if pushed
  while m>0 do
    m = m-1
    pdf:grestore()
  end
end

SILE.registerCommand("mathsvg", function(options, content)
  local fn = SU.required(options, "src", "filename")
  local f = assert(io.open(fn))
  local mathml = svg.parse(function() return f:read(1) end)
  f:close()

  SILE.typesetter:pushHbox{
    -- TODO: process viewBox attribute from SVG (or width & height attributes) to build hbox size
    height=30, width=30, depth=0,
    outputYourself = function(self, typesetter)
      local oldx, oldy = SILE.outputters.libtexpdf.cursor()
      SILE.outputters.libtexpdf.moveTo(0,0)
      pdf:gsave()
      pdf.setmatrix(1,0,0,1, oldx, -SILE.documentState.paperSize[2] + oldy)
      render(mathml)
      pdf:grestore()
      SILE.outputters.libtexpdf.moveTo(oldx, oldy)
      -- TODO: advance the pdf cursor as necessary
    end,
  }
end, "Render a SVG of a math equation that was produced by svgmath")


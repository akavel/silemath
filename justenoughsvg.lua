-- TODO: parse SVG emitted by github.com/akavel/svgmath
-- (see .../testdata/*.out.svg)
-- TODO: parse simple SVG into a tree of elements
-- TODO: recursive descent (= top-down walk) through
-- the tree, processing subsequent nodes, rendering them
-- to SILE taking into account any transformations from
-- higher up the tree [i.e. stack of transformations]
-- TODO: support should be needed only for the following
-- SVG elements:
--  path, rect, line, <g translate(...)>, text, circle
-- TODO: optionally, as intermediate alternative,
-- maybe render the nodes in "live mode" in ZeroBrane
-- Studio into some graphics engine?

-- NOTE: this parser is expected to work only on SVGs
-- emitted by svgmath, and as such makes many simplifying
-- assumptions about the input.

-- wrap_getc returns an object with methods: getc, ungetc,
-- error.
local function wrap_getc(getc)
	return {
		ungetc = function(self, c)
			self.c = c
		end,
		getc = function(self)
			if self.c then
				local c = self.c
				self.c = nil
				return c
			end
			return getc()
		end,
		error = function(self, ...)
			-- TODO: show position in input
			error(...)
		end,
	}
end

-- parse_tree returns a tree of objects representing
-- parsed SVG, or raises error.
function parse_tree(getc)
	local g = wrap_getc(getc)
	-- opening '<'
	local c = g:getc()
	if c ~= '<' then g:error('expected "<", got "'..c..'"') end
	return parse_element_inside(g)
end

local function isalpha(c)
	return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')
end
local function isalnum(c)
	return isalpha(c) or (c >= '0' and c <= '9')
end

-- parse_element_inside parses SVG element after initial
-- '<' was already consumed.
function parse_element_inside(g)
	local elem = {}
	-- element name (usually namespace:name)
	local n = {}
	while true do
		local c = g:getc()
		if isalpha(c) then
			n[#n+1] = c
		elseif c == ':' then
			-- namespace - discard
			n = {}
		elseif c == ' ' or c == '>' or c == '/' then
			-- end of element name
			g:ungetc(c)
			break
		else
			g:error('unexpected character "'..c..'" in element name')
		end
	end
	elem.name = table.concat(n, '')
	-- optional space-separated attributes
	while true do
		local c = g:getc()
		if c ~= ' ' then
			g:ungetc(c)
			break
		end
		if not elem.attrs then elem.attrs = {} end
		local name, value = parse_attr(g)
		elem.attrs[name] = value
	end
	-- does the element have children?
	local c = g:getc()
	if c == '/' then
		-- no children
		local c = g:getc()
		if c ~= '>' then
			g:error('expected "/>", got "/'..c..'"')
		end
		return elem
	end
	-- parse children
	local function add_child(ch)
		if not elem.childs then elem.childs = {} end
		local n = #elem.childs
		if type(ch) == 'string' and type(elem.childs[n]) == 'string' then
			elem.childs[n] = elem.childs[n] .. ch
		else
			elem.childs[n+1] = ch
		end
	end
	while true do
		local c = g:getc()
		if c == '<' then
			-- child elem, or end of current elem?
			local c = g:getc()
			if c == '/' then
				-- end of current elem
				break
			end
			local child = parse_element_inside(g)
			add_child(child)
		else
			-- text node
			add_child(c)
		end
	end
	-- TODO: verify elem.name
	parse_element_end(g)
	return elem
end

function parse_attr(g)
	-- attribute name
	local n = {}
	while true do
		local c = g:getc()
		if isalnum(c) or c == '-' or c == ':' then
			n[#n+1] = c
		elseif c == '=' then
			break
		else
			g:error('unexpected character "'..c..'" in attribute name')
		end
	end
	n = table.concat(n, '')
	-- attribute value
	local c = g:getc()
	if c ~= '"' then
		g:error("expected '=\"' in attribute value, got '="..c.."'")
	end
	local value = {}
	while true do
		local c = g:getc()
		if c == '"' then
			break
		end
		value[#value+1] = c
	end
	return n, table.concat(value, '')
end

function parse_element_end(g)
	while true do
		local c = g:getc()
		if c == '>' then
			return
		end
	end
end

---- DEMO/TEST ----
if not ... then
	local f = assert(io.open('sample/test13.out.svg'))
	local tree = parse_tree(function()
		return f:read(1)
	end)
	f:close()
	-- dump the tree
	local function dump_tree(elem, indent)
		local w = io.write
		local indent = indent or ''
		w(indent)
		if type(elem)=='string' then
			w'"' w(elem) w'"\n'
			return
		end
		w'<' w(elem.name)
		for k,v in pairs(elem.attrs or {}) do
			w' ' w(k) w'="' w(v) w'"'
		end
		w'>\n'
		for _,child in ipairs(elem.childs or {}) do
			dump_tree(child, indent..'  ')
		end
	end
	dump_tree(tree)
	-- for k,v in pairs(tree) do
	-- 	print(k,v)
	-- end
end


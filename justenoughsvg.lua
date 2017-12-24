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
function wrap_getc(getc)
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
-- parsed SVG, or raises error. The g should be a result
-- of wrap_getc.
function parse_tree(g)
	-- opening '<'
	local c = g:getc()
	if c ~= '<' then g:error('expected "<", got "'..c..'"') end
	return parse_element_inside(g)
end

-- parse_element_inside parses SVG element after initial
-- '<' was already consumed.
function parse_element_inside(g)
	local elem = {}
	-- element name (usually namespace:name)
	local n = {}
	while true do
		local c = g:getc()
		if c >= 'a' and c <= 'z' then
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


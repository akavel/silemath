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
	local node = {}
	-- opening '<'
	local c = g:getc()
	if c ~= '<' then g:error('expected "<", got "'..c..'"') end
	-- node name (usually namespace:name)
	local n = {}
	while true do
		local c = g:getc()
		if c >= 'a' and c <= 'z' then
			n[#n+1] = c
		elseif c == ':' then
			-- namespace - discard
			n = {}
		elseif c == ' ' or c == '>' or c == '/' then
			-- end of node name
			g:ungetc(c)
			break
		else
			g:error('unexpected character "'..c..'" in node name')
		end
	end
	node.name = table.concat(n, '')
	-- optional space-separated attributes
	while true do
		local c = g:getc()
		if c ~= ' ' then
			g:ungetc(c)
			break
		end
		if not node.attrs then node.attrs = {} end
		local name, value = parse_attr(g)
		node.attrs[name] = value
	end
	-- does the element have children?
	local c = g:getc()
	if c == '/' then
		-- no children
		local c = g:getc()
		if c ~= '>' then
			g:error('expected "/>", got "/'..c..'"')
		end
		return node
	end
	-- parse children
end


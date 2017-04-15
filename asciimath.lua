-- Lua code (Lua 5.2):
--------------------------------------------------------------------
local _ENV = require("castl.runtime")
local asciimath

asciimath = _obj({})
(function(this)
    local AMprocessNode, processNodeR, AMautomathrec, strarr2docFrag, parseMath, AMparseExpr, AMparseIexpr, AMparseSexpr, AMcurrentSymbol, AMpreviousSymbol, AMnestingDepth, AMremoveBrackets, AMgetSymbol, position, AMremoveCharsAndBlanks, define, refreshSymbols, initSymbols, AMnames, compareNames, AMsymbols, AMquote, UNARYUNDEROVER, MATRIX, STRETCHY, LONG, BIG, TEXT, LEFTRIGHT, DEFINITION, UNDEROVER, SPACE, RIGHTBRACKET, LEFTBRACKET, INFIX, BINARY, UNARY, CONST, AMbbb, AMfrk, AMcal, newsymbol, newcommand, createMmlNode, AMcreateElementMathML, AMmathml, createElementXHTML, translate, init, translated, noMathML, isIE, fixphi, AMdocumentId, AMescape1, AMdelimiter1, decimalsign, showasciiformulaonhover, displaystyle, translateASCIIMath, translateOnLoad, alertIfNoMathML, notifyIfNoMathML, automathrecognize, mathfontfamily, mathfontsize, mathcolor
    init = (function(this)
        local warnings, msg
        warnings = _new(Array)
        if not _bool(noMathML) then
            initSymbols(_ENV)
        end
        
        do
            return true
        end
    end)
    translate = (function(this, spanclassAM)
        local processN, body
        if not _bool(translated) then
            translated = true
            body = document:getElementsByTagName("body")[0]
            processN = document:getElementById(AMdocumentId)
            if _bool(translateASCIIMath) then
                AMprocessNode(
                    _ENV,
                    (function()
                        if (not _eq(processN, null)) then
                            return processN
                        else
                            return body
                        end
                    end)(),
                    false,
                    spanclassAM
                )
            end
        end
    end)
    createElementXHTML = (function(this, t)
        if _bool(isIE) then
            do
                return document:createElement(t)
            end
        else
            do
                return document:createElementNS("http://www.w3.org/1999/xhtml", t)
            end
        end
    end)
    AMcreateElementMathML = (function(this, t)
        if _bool(isIE) then
            do
                return document:createElement((_addStr1("m:", t)))
            end
        else
            do
                return document:createElementNS(AMmathml, t)
            end
        end
    end)
    createMmlNode = (function(this, t, frag)
        local node
        if _bool(isIE) then
            node = document:createElement((_addStr1("m:", t)))
        else
            node = document:createElementNS(AMmathml, t)
        end
        
        if _bool(frag) then
            node:appendChild(frag)
        end
        
        do
            return node
        end
    end)
    newcommand = (function(this, oldstr, newstr)
        AMsymbols:push(_obj({["input"] = oldstr, ["tag"] = "mo", ["output"] = newstr, ["tex"] = null, ["ttype"] = DEFINITION}))
        refreshSymbols(_ENV)
    end)
    newsymbol = (function(this, symbolobj)
        AMsymbols:push(symbolobj)
        refreshSymbols(_ENV)
    end)
    compareNames = (function(this, s1, s2)
        if (_gt(s1.input, s2.input)) then
            do
                return 1
            end
        else
            do
                return -1
            end
        end
    end)
    initSymbols = (function(this)
        local symlen, i
        symlen = AMsymbols.length
        i = 0
        while (_lt(i, symlen)) do
            if _bool(AMsymbols[i].tex) then
                AMsymbols:push(
                    _obj(
                        {["input"] = AMsymbols[i].tex, ["tag"] = AMsymbols[i].tag, ["output"] = AMsymbols[i].output, ["ttype"] = AMsymbols[i].ttype, ["acc"] = ((function()
                                local _lev = AMsymbols[i].acc
                                return _bool(_lev) and _lev or false
                            end)())}
                    )
                )
            end
            
            i = _inc(i)
        end
        
        refreshSymbols(_ENV)
    end)
    refreshSymbols = (function(this)
        local i
        AMsymbols:sort(compareNames)
        i = 0
        while (_lt(i, AMsymbols.length)) do
            AMnames[i] = AMsymbols[i].input
            i = _inc(i)
        end
    end)
    define = (function(this, oldstr, newstr)
        AMsymbols:push(_obj({["input"] = oldstr, ["tag"] = "mo", ["output"] = newstr, ["tex"] = null, ["ttype"] = DEFINITION}))
        refreshSymbols(_ENV)
    end)
    AMremoveCharsAndBlanks = (function(this, str, n)
        local i, st
        if ((function()
            local _lev = ((function()
                local _lev = (_eq(str:charAt(n), "\\"))
                if _bool(_lev) then
                    return (not _eq(str:charAt((_addNum2(n, 1))), "\\"))
                else
                    return _lev
                end
            end)())
            if _bool(_lev) then
                return (not _eq(str:charAt((_addNum2(n, 1))), " "))
            else
                return _lev
            end
        end)()) then
            st = str:slice((_addNum2(n, 1)))
        else
            st = str:slice(n)
        end
        
        i = 0
        while ((function()
            local _lev = (_lt(i, st.length))
            if _bool(_lev) then
                return (_le(st:charCodeAt(i), 32))
            else
                return _lev
            end
        end)()) do
            i = (_addNum2(i, 1))
        end
        
        do
            return st:slice(i)
        end
    end)
    position = (function(this, arr, str, n)
        local i, m, h
        if (_eq(n, 0)) then
            n = -1
            h = arr.length
            while (_lt((_addNum2(n, 1)), h)) do
                m = (_arshift((_add(n, h)), 1))
                if (_lt(arr[m], str)) then
                    n = m
                else
                    h = m
                end
                
                ::_continue::
            end
            
            do
                return h
            end
        else
            i = n
            while ((function()
                local _lev = (_lt(i, arr.length))
                if _bool(_lev) then
                    return (_lt(arr[i], str))
                else
                    return _lev
                end
            end)()) do
                i = _inc(i)
            end
        end
        
        do
            return i
        end
    end)
    AMgetSymbol = (function(this, str)
        local integ, i, more, match, tagst, st, mk, j, k
        k = 0
        j = 0
        match = ""
        more = true
        i = 1
        while _bool(
            ((function()
                local _lev = (_le(i, str.length))
                if _bool(_lev) then
                    return more
                else
                    return _lev
                end
            end)())
        ) do
            st = str:slice(0, i)
            j = k
            k = position(_ENV, AMnames, st, j)
            if ((function()
                local _lev = (_lt(k, AMnames.length))
                if _bool(_lev) then
                    return (_eq(str:slice(0, AMnames[k].length), AMnames[k]))
                else
                    return _lev
                end
            end)()) then
                match = AMnames[k]
                mk = k
                i = match.length
            end
            
            more = ((function()
                local _lev = (_lt(k, AMnames.length))
                if _bool(_lev) then
                    return (_ge(str:slice(0, AMnames[k].length), AMnames[k]))
                else
                    return _lev
                end
            end)())
            i = _inc(i)
        end
        
        AMpreviousSymbol = AMcurrentSymbol
        if (not _eq(match, "")) then
            AMcurrentSymbol = AMsymbols[mk].ttype
            do
                return AMsymbols[mk]
            end
        end
        
        AMcurrentSymbol = CONST
        k = 1
        st = str:slice(0, 1)
        integ = true
        while ((function()
            local _lev = ((function()
                local _lev = (_le("0", st))
                if _bool(_lev) then
                    return (_le(st, "9"))
                else
                    return _lev
                end
            end)())
            if _bool(_lev) then
                return (_le(k, str.length))
            else
                return _lev
            end
        end)()) do
            st = str:slice(k, (_addNum2(k, 1)))
            k = _inc(k)
            ::_continue::
        end
        
        if (_eq(st, decimalsign)) then
            st = str:slice(k, (_addNum2(k, 1)))
            if ((function()
                local _lev = (_le("0", st))
                if _bool(_lev) then
                    return (_le(st, "9"))
                else
                    return _lev
                end
            end)()) then
                integ = false
                k = _inc(k)
                while ((function()
                    local _lev = ((function()
                        local _lev = (_le("0", st))
                        if _bool(_lev) then
                            return (_le(st, "9"))
                        else
                            return _lev
                        end
                    end)())
                    if _bool(_lev) then
                        return (_le(k, str.length))
                    else
                        return _lev
                    end
                end)()) do
                    st = str:slice(k, (_addNum2(k, 1)))
                    k = _inc(k)
                    ::_continue::
                end
            end
        end
        
        if _bool(
            ((function()
                local _lev = ((function()
                    if _bool(integ) then
                        return (_gt(k, 1))
                    else
                        return integ
                    end
                end)())
                return _bool(_lev) and _lev or (_gt(k, 2))
            end)())
        ) then
            st = str:slice(0, (k - 1))
            tagst = "mn"
        else
            k = 2
            st = str:slice(0, 1)
            tagst = (function()
                if ((function()
                    local _lev = ((function()
                        local _lev = (_gt("A", st))
                        return _bool(_lev) and _lev or (_gt(st, "Z"))
                    end)())
                    if _bool(_lev) then
                        return ((function()
                            local _lev = (_gt("a", st))
                            return _bool(_lev) and _lev or (_gt(st, "z"))
                        end)())
                    else
                        return _lev
                    end
                end)()) then
                    return "mo"
                else
                    return "mi"
                end
            end)()
        end
        
        if ((function()
            local _lev = (_eq(st, "-"))
            if _bool(_lev) then
                return (_eq(AMpreviousSymbol, INFIX))
            else
                return _lev
            end
        end)()) then
            AMcurrentSymbol = INFIX
            do
                return _obj({["input"] = st, ["tag"] = tagst, ["output"] = st, ["ttype"] = UNARY, ["func"] = true})
            end
        end
        
        do
            return _obj({["input"] = st, ["tag"] = tagst, ["output"] = st, ["ttype"] = CONST})
        end
    end)
    AMremoveBrackets = (function(this, node)
        local st
        if not _bool(node:hasChildNodes()) then
            do
                return 
            end
        end
        
        if _bool(
            ((function()
                local _lev = node.firstChild:hasChildNodes()
                if _bool(_lev) then
                    return ((function()
                        local _lev = (_eq(node.nodeName, "mrow"))
                        return _bool(_lev) and _lev or (_eq(node.nodeName, "M:MROW"))
                    end)())
                else
                    return _lev
                end
            end)())
        ) then
            st = node.firstChild.firstChild.nodeValue
            if ((function()
                local _lev = ((function()
                    local _lev = (_eq(st, "("))
                    return _bool(_lev) and _lev or (_eq(st, "["))
                end)())
                return _bool(_lev) and _lev or (_eq(st, "{"))
            end)()) then
                node:removeChild(node.firstChild)
            end
        end
        
        if _bool(
            ((function()
                local _lev = node.lastChild:hasChildNodes()
                if _bool(_lev) then
                    return ((function()
                        local _lev = (_eq(node.nodeName, "mrow"))
                        return _bool(_lev) and _lev or (_eq(node.nodeName, "M:MROW"))
                    end)())
                else
                    return _lev
                end
            end)())
        ) then
            st = node.lastChild.firstChild.nodeValue
            if ((function()
                local _lev = ((function()
                    local _lev = (_eq(st, ")"))
                    return _bool(_lev) and _lev or (_eq(st, "]"))
                end)())
                return _bool(_lev) and _lev or (_eq(st, "}"))
            end)()) then
                node:removeChild(node.lastChild)
            end
        end
    end)
    AMparseSexpr = (function(this, str)
        local result2, j, newst, newFrag, st, i, result, node, symbol
        newFrag = document:createDocumentFragment()
        str = AMremoveCharsAndBlanks(_ENV, str, 0)
        symbol = AMgetSymbol(_ENV, str)
        if ((function()
            local _lev = (_eq(symbol, null))
            return _bool(_lev) and _lev or ((function()
                local _lev = (_eq(symbol.ttype, RIGHTBRACKET))
                if _bool(_lev) then
                    return (_gt(AMnestingDepth, 0))
                else
                    return _lev
                end
            end)())
        end)()) then
            do
                return _arr({[0] = null, str}, 2)
            end
        end
        
        if (_eq(symbol.ttype, DEFINITION)) then
            str = (_add(symbol.output, AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)))
            symbol = AMgetSymbol(_ENV, str)
        end
        
        repeat
            local _into = false
            local _cases = {[UNDEROVER] = true, [CONST] = true, [LEFTBRACKET] = true, [TEXT] = true, [UNARYUNDEROVER] = true, [UNARY] = true, [BINARY] = true, [INFIX] = true, [SPACE] = true, [LEFTRIGHT] = true}
            local _v = symbol.ttype
            if not _cases[_v] then
                _into = true
                goto _default
            end
            if _into or (_v == UNDEROVER) then
                _into = true
            end
            if _into or (_v == CONST) then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                do
                    return _arr({[0] = createMmlNode(_ENV, symbol.tag, document:createTextNode(symbol.output)), str}, 2)
                end
                _into = true
            end
            if _into or (_v == LEFTBRACKET) then
                AMnestingDepth = _inc(AMnestingDepth)
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                result = AMparseExpr(_ENV, str, true)
                AMnestingDepth = _dec(AMnestingDepth)
                if _bool(
                    ((function()
                        local _lev = (_eq(_type(symbol.invisible), "boolean"))
                        if _bool(_lev) then
                            return symbol.invisible
                        else
                            return _lev
                        end
                    end)())
                ) then
                    node = createMmlNode(_ENV, "mrow", result[0])
                else
                    node = createMmlNode(_ENV, "mo", document:createTextNode(symbol.output))
                    node = createMmlNode(_ENV, "mrow", node)
                    node:appendChild(result[0])
                end
                
                do
                    return _arr({[0] = node, result[1]}, 2)
                end
                _into = true
            end
            if _into or (_v == TEXT) then
                if (not _eq(symbol, AMquote)) then
                    str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                end
                
                if (_eq(str:charAt(0), "{")) then
                    i = str:indexOf("}")
                elseif (_eq(str:charAt(0), "(")) then
                    i = str:indexOf(")")
                elseif (_eq(str:charAt(0), "[")) then
                    i = str:indexOf("]")
                elseif (_eq(symbol, AMquote)) then
                    i = (_addNum2(str:slice(1):indexOf("\""), 1))
                else
                    i = 0
                end
                
                if (_eq(i, -1)) then
                    i = str.length
                end
                
                st = str:slice(1, i)
                if (_eq(st:charAt(0), " ")) then
                    node = createMmlNode(_ENV, "mspace")
                    node:setAttribute("width", "1ex")
                    newFrag:appendChild(node)
                end
                
                newFrag:appendChild(createMmlNode(_ENV, symbol.tag, document:createTextNode(st)))
                if (_eq(st:charAt((st.length - 1)), " ")) then
                    node = createMmlNode(_ENV, "mspace")
                    node:setAttribute("width", "1ex")
                    newFrag:appendChild(node)
                end
                
                str = AMremoveCharsAndBlanks(_ENV, str, (_addNum2(i, 1)))
                do
                    return _arr({[0] = createMmlNode(_ENV, "mrow", newFrag), str}, 2)
                end
                _into = true
            end
            if _into or (_v == UNARYUNDEROVER) then
                _into = true
            end
            if _into or (_v == UNARY) then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                result = AMparseSexpr(_ENV, str)
                if (_eq(result[0], null)) then
                    do
                        return _arr({[0] = createMmlNode(_ENV, symbol.tag, document:createTextNode(symbol.output)), str}, 2)
                    end
                end
                
                if _bool(
                    ((function()
                        local _lev = (_eq(_type(symbol.func), "boolean"))
                        if _bool(_lev) then
                            return symbol.func
                        else
                            return _lev
                        end
                    end)())
                ) then
                    st = str:charAt(0)
                    if _bool(
                        ((function()
                            local _lev = ((function()
                                local _lev = ((function()
                                    local _lev = ((function()
                                        local _lev = ((function()
                                            local _lev = (_eq(st, "^"))
                                            return _bool(_lev) and _lev or (_eq(st, "_"))
                                        end)())
                                        return _bool(_lev) and _lev or (_eq(st, "/"))
                                    end)())
                                    return _bool(_lev) and _lev or (_eq(st, "|"))
                                end)())
                                return _bool(_lev) and _lev or (_eq(st, ","))
                            end)())
                            return _bool(_lev) and _lev or ((function()
                                local _lev = ((function()
                                    local _lev = (_eq(symbol.input.length, 1))
                                    if _bool(_lev) then
                                        return symbol.input:match(_regexp("\\w", ""))
                                    else
                                        return _lev
                                    end
                                end)())
                                if _bool(_lev) then
                                    return (not _eq(st, "("))
                                else
                                    return _lev
                                end
                            end)())
                        end)())
                    ) then
                        do
                            return _arr({[0] = createMmlNode(_ENV, symbol.tag, document:createTextNode(symbol.output)), str}, 2)
                        end
                    else
                        node = createMmlNode(_ENV, "mrow", createMmlNode(_ENV, symbol.tag, document:createTextNode(symbol.output)))
                        node:appendChild(result[0])
                        do
                            return _arr({[0] = node, result[1]}, 2)
                        end
                    end
                end
                
                AMremoveBrackets(_ENV, result[0])
                if (_eq(symbol.input, "sqrt")) then
                    do
                        return _arr({[0] = createMmlNode(_ENV, symbol.tag, result[0]), result[1]}, 2)
                    end
                elseif (not _eq(_type(symbol.rewriteleftright), "undefined")) then
                    node = createMmlNode(_ENV, "mrow", createMmlNode(_ENV, "mo", document:createTextNode(symbol.rewriteleftright[0])))
                    node:appendChild(result[0])
                    node:appendChild(createMmlNode(_ENV, "mo", document:createTextNode(symbol.rewriteleftright[1])))
                    do
                        return _arr({[0] = node, result[1]}, 2)
                    end
                elseif (_eq(symbol.input, "cancel")) then
                    node = createMmlNode(_ENV, symbol.tag, result[0])
                    node:setAttribute("notation", "updiagonalstrike")
                    do
                        return _arr({[0] = node, result[1]}, 2)
                    end
                elseif _bool(
                    ((function()
                        local _lev = (_eq(_type(symbol.acc), "boolean"))
                        if _bool(_lev) then
                            return symbol.acc
                        else
                            return _lev
                        end
                    end)())
                ) then
                    node = createMmlNode(_ENV, symbol.tag, result[0])
                    node:appendChild(createMmlNode(_ENV, "mo", document:createTextNode(symbol.output)))
                    do
                        return _arr({[0] = node, result[1]}, 2)
                    end
                else
                    if ((function()
                        local _lev = not _bool(isIE)
                        if _bool(_lev) then
                            return (not _eq(_type(symbol.codes), "undefined"))
                        else
                            return _lev
                        end
                    end)()) then
                        i = 0
                        while (_lt(i, result[0].childNodes.length)) do
                            if ((function()
                                local _lev = (_eq(result[0].childNodes[i].nodeName, "mi"))
                                return _bool(_lev) and _lev or (_eq(result[0].nodeName, "mi"))
                            end)()) then
                                st = (function()
                                    if (_eq(result[0].nodeName, "mi")) then
                                        return result[0].firstChild.nodeValue
                                    else
                                        return result[0].childNodes[i].firstChild.nodeValue
                                    end
                                end)()
                                newst = _arr({}, 0)
                                j = 0
                                while (_lt(j, st.length)) do
                                    if ((function()
                                        local _lev = (_gt(st:charCodeAt(j), 64))
                                        if _bool(_lev) then
                                            return (_lt(st:charCodeAt(j), 91))
                                        else
                                            return _lev
                                        end
                                    end)()) then
                                        newst = (_add(newst, symbol.codes[(st:charCodeAt(j) - 65)]))
                                    elseif ((function()
                                        local _lev = (_gt(st:charCodeAt(j), 96))
                                        if _bool(_lev) then
                                            return (_lt(st:charCodeAt(j), 123))
                                        else
                                            return _lev
                                        end
                                    end)()) then
                                        newst = (_add(newst, symbol.codes[(st:charCodeAt(j) - 71)]))
                                    else
                                        newst = (_add(newst, st:charAt(j)))
                                    end
                                    
                                    j = _inc(j)
                                end
                                
                                if (_eq(result[0].nodeName, "mi")) then
                                    result[0] = createMmlNode(_ENV, "mo"):appendChild(document:createTextNode(newst))
                                else
                                    result[0]:replaceChild(createMmlNode(_ENV, "mo"):appendChild(document:createTextNode(newst)), result[0].childNodes[i])
                                end
                            end
                            
                            i = _inc(i)
                        end
                    end
                    
                    node = createMmlNode(_ENV, symbol.tag, result[0])
                    node:setAttribute(symbol.atname, symbol.atval)
                    do
                        return _arr({[0] = node, result[1]}, 2)
                    end
                end
                
                _into = true
            end
            if _into or (_v == BINARY) then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                result = AMparseSexpr(_ENV, str)
                if (_eq(result[0], null)) then
                    do
                        return _arr({[0] = createMmlNode(_ENV, "mo", document:createTextNode(symbol.input)), str}, 2)
                    end
                end
                
                AMremoveBrackets(_ENV, result[0])
                result2 = AMparseSexpr(_ENV, result[1])
                if (_eq(result2[0], null)) then
                    do
                        return _arr({[0] = createMmlNode(_ENV, "mo", document:createTextNode(symbol.input)), str}, 2)
                    end
                end
                
                AMremoveBrackets(_ENV, result2[0])
                if (_eq(symbol.input, "color")) then
                    if (_eq(str:charAt(0), "{")) then
                        i = str:indexOf("}")
                    elseif (_eq(str:charAt(0), "(")) then
                        i = str:indexOf(")")
                    elseif (_eq(str:charAt(0), "[")) then
                        i = str:indexOf("]")
                    end
                    
                    st = str:slice(1, i)
                    node = createMmlNode(_ENV, symbol.tag, result2[0])
                    node:setAttribute("mathcolor", st)
                    do
                        return _arr({[0] = node, result2[1]}, 2)
                    end
                end
                
                if ((function()
                    local _lev = (_eq(symbol.input, "root"))
                    return _bool(_lev) and _lev or (_eq(symbol.output, "stackrel"))
                end)()) then
                    newFrag:appendChild(result2[0])
                end
                
                newFrag:appendChild(result[0])
                if (_eq(symbol.input, "frac")) then
                    newFrag:appendChild(result2[0])
                end
                
                do
                    return _arr({[0] = createMmlNode(_ENV, symbol.tag, newFrag), result2[1]}, 2)
                end
                _into = true
            end
            if _into or (_v == INFIX) then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                do
                    return _arr({[0] = createMmlNode(_ENV, "mo", document:createTextNode(symbol.output)), str}, 2)
                end
                _into = true
            end
            if _into or (_v == SPACE) then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                node = createMmlNode(_ENV, "mspace")
                node:setAttribute("width", "1ex")
                newFrag:appendChild(node)
                newFrag:appendChild(createMmlNode(_ENV, symbol.tag, document:createTextNode(symbol.output)))
                node = createMmlNode(_ENV, "mspace")
                node:setAttribute("width", "1ex")
                newFrag:appendChild(node)
                do
                    return _arr({[0] = createMmlNode(_ENV, "mrow", newFrag), str}, 2)
                end
                _into = true
            end
            if _into or (_v == LEFTRIGHT) then
                AMnestingDepth = _inc(AMnestingDepth)
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                result = AMparseExpr(_ENV, str, false)
                AMnestingDepth = _dec(AMnestingDepth)
                st = ""
                if (not _eq(result[0].lastChild, null)) then
                    st = result[0].lastChild.firstChild.nodeValue
                end
                
                if (_eq(st, "|")) then
                    node = createMmlNode(_ENV, "mo", document:createTextNode(symbol.output))
                    node = createMmlNode(_ENV, "mrow", node)
                    node:appendChild(result[0])
                    do
                        return _arr({[0] = node, result[1]}, 2)
                    end
                else
                    node = createMmlNode(_ENV, "mo", document:createTextNode("\226\136\163"))
                    node = createMmlNode(_ENV, "mrow", node)
                    do
                        return _arr({[0] = node, str}, 2)
                    end
                end
                
                _into = true
            end
            ::_default::
            if _into then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                do
                    return _arr({[0] = createMmlNode(_ENV, symbol.tag, document:createTextNode(symbol.output)), str}, 2)
                end
                _into = true
            end
        until true
    end)
    AMparseIexpr = (function(this, str)
        local res2, underover, result, node, sym2, sym1, symbol
        str = AMremoveCharsAndBlanks(_ENV, str, 0)
        sym1 = AMgetSymbol(_ENV, str)
        result = AMparseSexpr(_ENV, str)
        node = result[0]
        str = result[1]
        symbol = AMgetSymbol(_ENV, str)
        if ((function()
            local _lev = (_eq(symbol.ttype, INFIX))
            if _bool(_lev) then
                return (not _eq(symbol.input, "/"))
            else
                return _lev
            end
        end)()) then
            str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
            result = AMparseSexpr(_ENV, str)
            if (_eq(result[0], null)) then
                result[0] = createMmlNode(_ENV, "mo", document:createTextNode("\226\150\161"))
            else
                AMremoveBrackets(_ENV, result[0])
            end
            
            str = result[1]
            underover = ((function()
                local _lev = (_eq(sym1.ttype, UNDEROVER))
                return _bool(_lev) and _lev or (_eq(sym1.ttype, UNARYUNDEROVER))
            end)())
            if (_eq(symbol.input, "_")) then
                sym2 = AMgetSymbol(_ENV, str)
                if (_eq(sym2.input, "^")) then
                    str = AMremoveCharsAndBlanks(_ENV, str, sym2.input.length)
                    res2 = AMparseSexpr(_ENV, str)
                    AMremoveBrackets(_ENV, res2[0])
                    str = res2[1]
                    node = createMmlNode(
                        _ENV,
                        (function()
                            if _bool(underover) then
                                return "munderover"
                            else
                                return "msubsup"
                            end
                        end)(),
                        node
                    )
                    node:appendChild(result[0])
                    node:appendChild(res2[0])
                    node = createMmlNode(_ENV, "mrow", node)
                else
                    node = createMmlNode(
                        _ENV,
                        (function()
                            if _bool(underover) then
                                return "munder"
                            else
                                return "msub"
                            end
                        end)(),
                        node
                    )
                    node:appendChild(result[0])
                end
            elseif _bool(
                ((function()
                    local _lev = (_eq(symbol.input, "^"))
                    if _bool(_lev) then
                        return underover
                    else
                        return _lev
                    end
                end)())
            ) then
                node = createMmlNode(_ENV, "mover", node)
                node:appendChild(result[0])
            else
                node = createMmlNode(_ENV, symbol.tag, node)
                node:appendChild(result[0])
            end
            
            if _bool(
                ((function()
                    local _lev = (not _eq(_type(sym1.func), "undefined"))
                    if _bool(_lev) then
                        return sym1.func
                    else
                        return _lev
                    end
                end)())
            ) then
                sym2 = AMgetSymbol(_ENV, str)
                if ((function()
                    local _lev = (not _eq(sym2.ttype, INFIX))
                    if _bool(_lev) then
                        return (not _eq(sym2.ttype, RIGHTBRACKET))
                    else
                        return _lev
                    end
                end)()) then
                    result = AMparseIexpr(_ENV, str)
                    node = createMmlNode(_ENV, "mrow", node)
                    node:appendChild(result[0])
                    str = result[1]
                end
            end
        end
        
        do
            return _arr({[0] = node, str}, 2)
        end
    end)
    AMparseExpr = (function(this, str, rightbracket)
        local table, k, n, frag, row, j, m, matrix, pos, left, right, len, newFrag, i, result, node, symbol
        newFrag = document:createDocumentFragment()
        repeat
            str = AMremoveCharsAndBlanks(_ENV, str, 0)
            result = AMparseIexpr(_ENV, str)
            node = result[0]
            str = result[1]
            symbol = AMgetSymbol(_ENV, str)
            if ((function()
                local _lev = (_eq(symbol.ttype, INFIX))
                if _bool(_lev) then
                    return (_eq(symbol.input, "/"))
                else
                    return _lev
                end
            end)()) then
                str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
                result = AMparseIexpr(_ENV, str)
                if (_eq(result[0], null)) then
                    result[0] = createMmlNode(_ENV, "mo", document:createTextNode("\226\150\161"))
                else
                    AMremoveBrackets(_ENV, result[0])
                end
                
                str = result[1]
                AMremoveBrackets(_ENV, node)
                node = createMmlNode(_ENV, symbol.tag, node)
                node:appendChild(result[0])
                newFrag:appendChild(node)
                symbol = AMgetSymbol(_ENV, str)
            elseif (not _eq(node, undefined)) then
                newFrag:appendChild(node)
            end
            
            ::_continue::
        until not _bool(
            ((function()
                local _lev = ((function()
                    local _lev = ((function()
                        local _lev = ((function()
                            local _lev = (not _eq(symbol.ttype, RIGHTBRACKET))
                            if _bool(_lev) then
                                return ((function()
                                    local _lev = (not _eq(symbol.ttype, LEFTRIGHT))
                                    return _bool(_lev) and _lev or rightbracket
                                end)())
                            else
                                return _lev
                            end
                        end)())
                        return _bool(_lev) and _lev or (_eq(AMnestingDepth, 0))
                    end)())
                    if _bool(_lev) then
                        return (not _eq(symbol, null))
                    else
                        return _lev
                    end
                end)())
                if _bool(_lev) then
                    return (not _eq(symbol.output, ""))
                else
                    return _lev
                end
            end)())
        )
        
        if ((function()
            local _lev = (_eq(symbol.ttype, RIGHTBRACKET))
            return _bool(_lev) and _lev or (_eq(symbol.ttype, LEFTRIGHT))
        end)()) then
            len = newFrag.childNodes.length
            if _bool(
                ((function()
                    local _lev = ((function()
                        local _lev = ((function()
                            local _lev = (_gt(len, 0))
                            if _bool(_lev) then
                                return (_eq(newFrag.childNodes[(len - 1)].nodeName, "mrow"))
                            else
                                return _lev
                            end
                        end)())
                        if _bool(_lev) then
                            return newFrag.childNodes[(len - 1)].lastChild
                        else
                            return _lev
                        end
                    end)())
                    if _bool(_lev) then
                        return newFrag.childNodes[(len - 1)].lastChild.firstChild
                    else
                        return _lev
                    end
                end)())
            ) then
                right = newFrag.childNodes[(len - 1)].lastChild.firstChild.nodeValue
                if ((function()
                    local _lev = (_eq(right, ")"))
                    return _bool(_lev) and _lev or (_eq(right, "]"))
                end)()) then
                    left = newFrag.childNodes[(len - 1)].firstChild.firstChild.nodeValue
                    if ((function()
                        local _lev = ((function()
                            local _lev = ((function()
                                local _lev = (_eq(left, "("))
                                if _bool(_lev) then
                                    return (_eq(right, ")"))
                                else
                                    return _lev
                                end
                            end)())
                            if _bool(_lev) then
                                return (not _eq(symbol.output, "}"))
                            else
                                return _lev
                            end
                        end)())
                        return _bool(_lev) and _lev or ((function()
                            local _lev = (_eq(left, "["))
                            if _bool(_lev) then
                                return (_eq(right, "]"))
                            else
                                return _lev
                            end
                        end)())
                    end)()) then
                        pos = _arr({}, 0)
                        matrix = true
                        m = newFrag.childNodes.length
                        i = 0
                        while _bool(
                            ((function()
                                if _bool(matrix) then
                                    return (_lt(i, m))
                                else
                                    return matrix
                                end
                            end)())
                        ) do
                            pos[i] = _arr({}, 0)
                            node = newFrag.childNodes[i]
                            if _bool(matrix) then
                                matrix = ((function()
                                    local _lev = ((function()
                                        local _lev = ((function()
                                            local _lev = (_eq(node.nodeName, "mrow"))
                                            if _bool(_lev) then
                                                return ((function()
                                                    local _lev = (_eq(i, (m - 1)))
                                                    return _bool(_lev) and _lev or ((function()
                                                        local _lev = (_eq(node.nextSibling.nodeName, "mo"))
                                                        if _bool(_lev) then
                                                            return (_eq(node.nextSibling.firstChild.nodeValue, ","))
                                                        else
                                                            return _lev
                                                        end
                                                    end)())
                                                end)())
                                            else
                                                return _lev
                                            end
                                        end)())
                                        if _bool(_lev) then
                                            return (_eq(node.firstChild.firstChild.nodeValue, left))
                                        else
                                            return _lev
                                        end
                                    end)())
                                    if _bool(_lev) then
                                        return (_eq(node.lastChild.firstChild.nodeValue, right))
                                    else
                                        return _lev
                                    end
                                end)())
                            end
                            
                            if _bool(matrix) then
                                j = 0
                                while (_lt(j, node.childNodes.length)) do
                                    if (_eq(node.childNodes[j].firstChild.nodeValue, ",")) then
                                        pos[i][pos[i].length] = j
                                    end
                                    
                                    j = _inc(j)
                                end
                            end
                            
                            if _bool(
                                ((function()
                                    if _bool(matrix) then
                                        return (_gt(i, 1))
                                    else
                                        return matrix
                                    end
                                end)())
                            ) then
                                matrix = (_eq(pos[i].length, pos[(i - 2)].length))
                            end
                            
                            i = (_addNum2(i, 2))
                        end
                        
                        matrix = ((function()
                            if _bool(matrix) then
                                return ((function()
                                    local _lev = (_gt(pos.length, 1))
                                    return _bool(_lev) and _lev or (_gt(pos[0].length, 0))
                                end)())
                            else
                                return matrix
                            end
                        end)())
                        if _bool(matrix) then
                            table = document:createDocumentFragment()
                            i = 0
                            while (_lt(i, m)) do
                                row = document:createDocumentFragment()
                                frag = document:createDocumentFragment()
                                node = newFrag.firstChild
                                n = node.childNodes.length
                                k = 0
                                node:removeChild(node.firstChild)
                                j = 1
                                while (_lt(j, (n - 1))) do
                                    if ((function()
                                        local _lev = (not _eq(_type(pos[i][k]), "undefined"))
                                        if _bool(_lev) then
                                            return (_eq(j, pos[i][k]))
                                        else
                                            return _lev
                                        end
                                    end)()) then
                                        node:removeChild(node.firstChild)
                                        row:appendChild(createMmlNode(_ENV, "mtd", frag))
                                        k = _inc(k)
                                    else
                                        frag:appendChild(node.firstChild)
                                    end
                                    
                                    j = _inc(j)
                                end
                                
                                row:appendChild(createMmlNode(_ENV, "mtd", frag))
                                if (_gt(newFrag.childNodes.length, 2)) then
                                    newFrag:removeChild(newFrag.firstChild)
                                    newFrag:removeChild(newFrag.firstChild)
                                end
                                
                                table:appendChild(createMmlNode(_ENV, "mtr", row))
                                i = (_addNum2(i, 2))
                            end
                            
                            node = createMmlNode(_ENV, "mtable", table)
                            if _bool(
                                ((function()
                                    local _lev = (_eq(_type(symbol.invisible), "boolean"))
                                    if _bool(_lev) then
                                        return symbol.invisible
                                    else
                                        return _lev
                                    end
                                end)())
                            ) then
                                node:setAttribute("columnalign", "left")
                            end
                            
                            newFrag:replaceChild(node, newFrag.firstChild)
                        end
                    end
                end
            end
            
            str = AMremoveCharsAndBlanks(_ENV, str, symbol.input.length)
            if ((function()
                local _lev = (not _eq(_type(symbol.invisible), "boolean"))
                return _bool(_lev) and _lev or not _bool(symbol.invisible)
            end)()) then
                node = createMmlNode(_ENV, "mo", document:createTextNode(symbol.output))
                newFrag:appendChild(node)
            end
        end
        
        do
            return _arr({[0] = newFrag, str}, 2)
        end
    end)
    parseMath = (function(this, str, latex)
        local node, frag
        AMnestingDepth = 0
        str = str:replace(_regexp("&nbsp;", "g"), "")
        str = str:replace(_regexp("&gt;", "g"), ">")
        str = str:replace(_regexp("&lt;", "g"), "<")
        str = str:replace(
            _regexp("(Sin|Cos|Tan|Arcsin|Arccos|Arctan|Sinh|Cosh|Tanh|Cot|Sec|Csc|Log|Ln|Abs)", "g"),
            (function(this, v)
                do
                    return v:toLowerCase()
                end
            end)
        )
        frag = AMparseExpr(_ENV, str:replace(_regexp("^\\s+", "g"), ""), false)[0]
        node = createMmlNode(_ENV, "mstyle", frag)
        if (not _eq(mathcolor, "")) then
            node:setAttribute("mathcolor", mathcolor)
        end
        
        if (not _eq(mathfontfamily, "")) then
            node:setAttribute("fontfamily", mathfontfamily)
        end
        
        if _bool(displaystyle) then
            node:setAttribute("displaystyle", "true")
        end
        
        node = createMmlNode(_ENV, "math", node)
        if _bool(showasciiformulaonhover) then
            node:setAttribute("title", str:replace(_regexp("\\s+", "g"), " "))
        end
        
        do
            return node
        end
    end)
    strarr2docFrag = (function(this, arr, linebreaks, latex)
        local j, arri, i, expr, newFrag
        newFrag = document:createDocumentFragment()
        expr = false
        i = 0
        while (_lt(i, arr.length)) do
            if _bool(expr) then
                newFrag:appendChild(parseMath(_ENV, arr[i], latex))
            else
                arri = (function()
                    if _bool(linebreaks) then
                        return arr[i]:split("\010\010")
                    else
                        return _arr({[0] = arr[i]}, 1)
                    end
                end)()
                newFrag:appendChild(createElementXHTML(_ENV, "span"):appendChild(document:createTextNode(arri[0])))
                j = 1
                while (_lt(j, arri.length)) do
                    newFrag:appendChild(createElementXHTML(_ENV, "p"))
                    newFrag:appendChild(createElementXHTML(_ENV, "span"):appendChild(document:createTextNode(arri[j])))
                    j = _inc(j)
                end
            end
            
            expr = not _bool(expr)
            i = _inc(i)
        end
        
        do
            return newFrag
        end
    end)
    AMautomathrec = (function(this, str)
        local re2, re1, arr, re, token, letter, simpleAMtoken, secondenglishAMtoken, englishAMtoken, ambigAMtoken, texcommand
        texcommand = "\\\\[a-zA-Z]+|\\\\\\s|"
        ambigAMtoken = "\\b(?:oo|lim|ln|int|oint|del|grad|aleph|prod|prop|sinh|cosh|tanh|cos|sec|pi|tt|fr|sf|sube|supe|sub|sup|det|mod|gcd|lcm|min|max|vec|ddot|ul|chi|eta|nu|mu)(?![a-z])|"
        englishAMtoken = "\\b(?:sum|ox|log|sin|tan|dim|hat|bar|dot)(?![a-z])|"
        secondenglishAMtoken = "|\\bI\\b|\\bin\\b|\\btext\\b"
        simpleAMtoken = "NN|ZZ|QQ|RR|CC|TT|AA|EE|sqrt|dx|dy|dz|dt|xx|vv|uu|nn|bb|cc|csc|cot|alpha|beta|delta|Delta|epsilon|gamma|Gamma|kappa|lambda|Lambda|omega|phi|Phi|Pi|psi|Psi|rho|sigma|Sigma|tau|theta|Theta|xi|Xi|zeta"
        letter = ((_addStr1((_addStr1((_addStr1("[a-zA-HJ-Z](?=(?:[^a-zA-Z]|$|", ambigAMtoken)), englishAMtoken)), simpleAMtoken)) .. "))|")
        token = (_addStr1((_addStr1((_addStr1((_addStr2((_add(letter, texcommand)), "\\d+|[-()[\\]{}+=*&^_%\\@/<>,\\|!:;'~]|\\.(?!(?: |$))|")), ambigAMtoken)), englishAMtoken)), simpleAMtoken))
        re = _new(RegExp, ((_addStr1((_addStr1(((_addStr1("(^|\\s)(((", token)) .. ")\\s?)(("), token)), secondenglishAMtoken)) .. ")\\s?)+)([,.?]?(?=\\s|$))"), "g")
        str = str:replace(re, " `$2`$7")
        arr = str:split(AMdelimiter1)
        re1 = _new(RegExp, ((_addStr1((_addStr1((_addStr1("(^|\\s)([b-zB-HJ-Z+*<>]|", texcommand)), ambigAMtoken)), simpleAMtoken)) .. ")(\\s|\\n|$)"), "g")
        re2 = _new(RegExp, ((_addStr1((_addStr1((_addStr1("(^|\\s)([a-z]|", texcommand)), ambigAMtoken)), simpleAMtoken)) .. ")([,.])"), "g")
        i = 0
        while (_lt(i, arr.length)) do
            if (_eq((_mod(i, 2)), 0)) then
                arr[i] = arr[i]:replace(re1, " `$2`$3")
                arr[i] = arr[i]:replace(re2, " `$2`$3")
                arr[i] = arr[i]:replace(_regexp("([{}[\\]])", ""), "`$1`")
            end
            
            i = _inc(i)
        end
        
        str = arr:join(AMdelimiter1)
        str = str:replace(_regexp("((^|\\s)\\([a-zA-Z]{2,}.*?)\\)`", "g"), "$1`)")
        str = str:replace(_regexp("`(\\((a\\s|in\\s))(.*?[a-zA-Z]{2,}\\))", "g"), "$1`$3")
        str = str:replace(_regexp("\\sin`", "g"), "` in")
        str = str:replace(_regexp("`(\\(\\w\\)[,.]?(\\s|\\n|$))", "g"), "$1`")
        str = str:replace(_regexp("`([0-9.]+|e.g|i.e)`(\\.?)", "gi"), "$1$2")
        str = str:replace(_regexp("`([0-9.]+:)`", "g"), "$1")
        do
            return str
        end
    end)
    processNodeR = (function(this, n, linebreaks, latex)
        local len, i, frg, arr, str, mtch
        if (_eq(n.childNodes.length, 0)) then
            if _bool(
                ((function()
                    local _lev = ((function()
                        local _lev = ((function()
                            local _lev = ((function()
                                local _lev = ((function()
                                    local _lev = (not _eq(n.nodeType, 8))
                                    return _bool(_lev) and _lev or linebreaks
                                end)())
                                if _bool(_lev) then
                                    return (not _eq(n.parentNode.nodeName, "form"))
                                else
                                    return _lev
                                end
                            end)())
                            if _bool(_lev) then
                                return (not _eq(n.parentNode.nodeName, "FORM"))
                            else
                                return _lev
                            end
                        end)())
                        if _bool(_lev) then
                            return (not _eq(n.parentNode.nodeName, "textarea"))
                        else
                            return _lev
                        end
                    end)())
                    if _bool(_lev) then
                        return (not _eq(n.parentNode.nodeName, "TEXTAREA"))
                    else
                        return _lev
                    end
                end)())
            ) then
                str = n.nodeValue
                if not (_eq(str, null)) then
                    str = str:replace(_regexp("\\r\\n\\r\\n", "g"), "\010\010")
                    str = str:replace(_regexp("\\x20+", "g"), " ")
                    str = str:replace(_regexp("\\s*\\r\\n", "g"), " ")
                    if _bool(latex) then
                        mtch = (function()
                            if (_eq(str:indexOf("$"), -1)) then
                                return false
                            else
                                return true
                            end
                        end)()
                        str = str:replace(_regexp("([^\\\\])\\$", "g"), "$1 $")
                        str = str:replace(_regexp("^\\$", ""), " $")
                        arr = str:split(" $")
                        i = 0
                        while (_lt(i, arr.length)) do
                            arr[i] = arr[i]:replace(_regexp("\\\\\\$", "g"), "$")
                            i = _inc(i)
                        end
                    else
                        mtch = false
                        str = str:replace(
                            _new(RegExp, AMescape1, "g"),
                            (function(this)
                                mtch = true
                                do
                                    return "AMescape1"
                                end
                            end)
                        )
                        str = str:replace(
                            _regexp("\\\\?end{?a?math}?", "i"),
                            (function(this)
                                automathrecognize = false
                                mtch = true
                                do
                                    return ""
                                end
                            end)
                        )
                        str = str:replace(
                            _regexp("amath\\b|\\\\begin{a?math}", "i"),
                            (function(this)
                                automathrecognize = true
                                mtch = true
                                do
                                    return ""
                                end
                            end)
                        )
                        arr = str:split(AMdelimiter1)
                        if _bool(automathrecognize) then
                            i = 0
                            while (_lt(i, arr.length)) do
                                if (_eq((_mod(i, 2)), 0)) then
                                    arr[i] = AMautomathrec(_ENV, arr[i])
                                end
                                
                                i = _inc(i)
                            end
                        end
                        
                        str = arr:join(AMdelimiter1)
                        arr = str:split(AMdelimiter1)
                        i = 0
                        while (_lt(i, arr.length)) do
                            arr[i] = arr[i]:replace(_regexp("AMescape1", "g"), AMdelimiter1)
                            i = _inc(i)
                        end
                    end
                    
                    if _bool(
                        ((function()
                            local _lev = (_gt(arr.length, 1))
                            return _bool(_lev) and _lev or mtch
                        end)())
                    ) then
                        if not _bool(noMathML) then
                            frg = strarr2docFrag(_ENV, arr, (_eq(n.nodeType, 8)), latex)
                            len = frg.childNodes.length
                            n.parentNode:replaceChild(frg, n)
                            do
                                return (len - 1)
                            end
                        else
                            do
                                return 0
                            end
                        end
                    end
                end
            else
                do
                    return 0
                end
            end
        elseif (not _eq(n.nodeName, "math")) then
            i = 0
            while (_lt(i, n.childNodes.length)) do
                i = (_add(i, processNodeR(_ENV, n.childNodes[i], linebreaks, latex)))
                i = _inc(i)
            end
        end
        
        do
            return 0
        end
    end)
    AMprocessNode = (function(this, n, linebreaks, spanclassAM)
        local i, st, frag
        if (not _eq(spanclassAM, null)) then
            frag = document:getElementsByTagName("span")
            i = 0
            while (_lt(i, frag.length)) do
                if (_eq(frag[i].className, "AM")) then
                    processNodeR(_ENV, frag[i], linebreaks, false)
                end
                
                i = _inc(i)
            end
        else
            local _status, _return = _pcall(
                function()
                    st = n.innerHTML
                end
            )
            if not _status then
                local _cstatus, _creturn = _pcall(
                    function()
                        local err = _return
                    end
                )
                if _cstatus then
                else
                    _throw(_creturn, 0)
                end
            end
            
            if _bool(
                ((function()
                    local _lev = ((function()
                        local _lev = ((function()
                            local _lev = ((function()
                                local _lev = ((function()
                                    local _lev = (_eq(st, null))
                                    return _bool(_lev) and _lev or (_regexp("amath\\b|\\\\begin{a?math}", "i")):test(st)
                                end)())
                                return _bool(_lev) and _lev or (not _eq(st:indexOf((_addStr2(AMdelimiter1, " "))), -1))
                            end)())
                            return _bool(_lev) and _lev or (_eq(st:slice(-1), AMdelimiter1))
                        end)())
                        return _bool(_lev) and _lev or (not _eq(st:indexOf((_addStr2(AMdelimiter1, "<"))), -1))
                    end)())
                    return _bool(_lev) and _lev or (not _eq(st:indexOf((_addStr2(AMdelimiter1, "\010"))), -1))
                end)())
            ) then
                processNodeR(_ENV, n, linebreaks, false)
            end
        end
    end)
    mathcolor = "blue"
    mathfontsize = "1em"
    mathfontfamily = "serif"
    automathrecognize = false
    notifyIfNoMathML = true
    alertIfNoMathML = false
    translateOnLoad = true
    translateASCIIMath = true
    displaystyle = true
    showasciiformulaonhover = true
    decimalsign = "."
    AMdelimiter1 = "`"
    AMescape1 = "\\\\`"
    AMdocumentId = "wikitext"
    fixphi = true
    isIE = false
    noMathML = false
    translated = false
    AMmathml = "http://www.w3.org/1998/Math/MathML"
    AMcal = _arr({[0] = "\240\157\146\156", "\226\132\172", "\240\157\146\158", "\240\157\146\159", "\226\132\176", "\226\132\177", "\240\157\146\162", "\226\132\139", "\226\132\144", "\240\157\146\165", "\240\157\146\166", "\226\132\146", "\226\132\179", "\240\157\146\169", "\240\157\146\170", "\240\157\146\171", "\240\157\146\172", "\226\132\155", "\240\157\146\174", "\240\157\146\175", "\240\157\146\176", "\240\157\146\177", "\240\157\146\178", "\240\157\146\179", "\240\157\146\180", "\240\157\146\181", "\240\157\146\182", "\240\157\146\183", "\240\157\146\184", "\240\157\146\185", "\226\132\175", "\240\157\146\187", "\226\132\138", "\240\157\146\189", "\240\157\146\190", "\240\157\146\191", "\240\157\147\128", "\240\157\147\129", "\240\157\147\130", "\240\157\147\131", "\226\132\180", "\240\157\147\133", "\240\157\147\134", "\240\157\147\135", "\240\157\147\136", "\240\157\147\137", "\240\157\147\138", "\240\157\147\139", "\240\157\147\140", "\240\157\147\141", "\240\157\147\142", "\240\157\147\143"}, 52)
    AMfrk = _arr({[0] = "\240\157\148\132", "\240\157\148\133", "\226\132\173", "\240\157\148\135", "\240\157\148\136", "\240\157\148\137", "\240\157\148\138", "\226\132\140", "\226\132\145", "\240\157\148\141", "\240\157\148\142", "\240\157\148\143", "\240\157\148\144", "\240\157\148\145", "\240\157\148\146", "\240\157\148\147", "\240\157\148\148", "\226\132\156", "\240\157\148\150", "\240\157\148\151", "\240\157\148\152", "\240\157\148\153", "\240\157\148\154", "\240\157\148\155", "\240\157\148\156", "\226\132\168", "\240\157\148\158", "\240\157\148\159", "\240\157\148\160", "\240\157\148\161", "\240\157\148\162", "\240\157\148\163", "\240\157\148\164", "\240\157\148\165", "\240\157\148\166", "\240\157\148\167", "\240\157\148\168", "\240\157\148\169", "\240\157\148\170", "\240\157\148\171", "\240\157\148\172", "\240\157\148\173", "\240\157\148\174", "\240\157\148\175", "\240\157\148\176", "\240\157\148\177", "\240\157\148\178", "\240\157\148\179", "\240\157\148\180", "\240\157\148\181", "\240\157\148\182", "\240\157\148\183"}, 52)
    AMbbb = _arr({[0] = "\240\157\148\184", "\240\157\148\185", "\226\132\130", "\240\157\148\187", "\240\157\148\188", "\240\157\148\189", "\240\157\148\190", "\226\132\141", "\240\157\149\128", "\240\157\149\129", "\240\157\149\130", "\240\157\149\131", "\240\157\149\132", "\226\132\149", "\240\157\149\134", "\226\132\153", "\226\132\154", "\226\132\157", "\240\157\149\138", "\240\157\149\139", "\240\157\149\140", "\240\157\149\141", "\240\157\149\142", "\240\157\149\143", "\240\157\149\144", "\226\132\164", "\240\157\149\146", "\240\157\149\147", "\240\157\149\148", "\240\157\149\149", "\240\157\149\150", "\240\157\149\151", "\240\157\149\152", "\240\157\149\153", "\240\157\149\154", "\240\157\149\155", "\240\157\149\156", "\240\157\149\157", "\240\157\149\158", "\240\157\149\159", "\240\157\149\160", "\240\157\149\161", "\240\157\149\162", "\240\157\149\163", "\240\157\149\164", "\240\157\149\165", "\240\157\149\166", "\240\157\149\167", "\240\157\149\168", "\240\157\149\169", "\240\157\149\170", "\240\157\149\171"}, 52)
    CONST = 0
    UNARY = 1
    BINARY = 2
    INFIX = 3
    LEFTBRACKET = 4
    RIGHTBRACKET = 5
    SPACE = 6
    UNDEROVER = 7
    DEFINITION = 8
    LEFTRIGHT = 9
    TEXT = 10
    BIG = 11
    LONG = 12
    STRETCHY = 13
    MATRIX = 14
    UNARYUNDEROVER = 15
    AMquote = _obj({["input"] = "\"", ["tag"] = "mtext", ["output"] = "mbox", ["tex"] = null, ["ttype"] = TEXT})
    AMsymbols = _arr(
        {
            [0] = _obj({["input"] = "alpha", ["tag"] = "mi", ["output"] = "\206\177", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "beta", ["tag"] = "mi", ["output"] = "\206\178", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "chi", ["tag"] = "mi", ["output"] = "\207\135", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "delta", ["tag"] = "mi", ["output"] = "\206\180", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Delta", ["tag"] = "mo", ["output"] = "\206\148", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "epsi", ["tag"] = "mi", ["output"] = "\206\181", ["tex"] = "epsilon", ["ttype"] = CONST}),
            _obj({["input"] = "varepsilon", ["tag"] = "mi", ["output"] = "\201\155", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "eta", ["tag"] = "mi", ["output"] = "\206\183", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "gamma", ["tag"] = "mi", ["output"] = "\206\179", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Gamma", ["tag"] = "mo", ["output"] = "\206\147", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "iota", ["tag"] = "mi", ["output"] = "\206\185", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "kappa", ["tag"] = "mi", ["output"] = "\206\186", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "lambda", ["tag"] = "mi", ["output"] = "\206\187", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Lambda", ["tag"] = "mo", ["output"] = "\206\155", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "lamda", ["tag"] = "mi", ["output"] = "\206\187", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Lamda", ["tag"] = "mo", ["output"] = "\206\155", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "mu", ["tag"] = "mi", ["output"] = "\206\188", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "nu", ["tag"] = "mi", ["output"] = "\206\189", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "omega", ["tag"] = "mi", ["output"] = "\207\137", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Omega", ["tag"] = "mo", ["output"] = "\206\169", ["tex"] = null, ["ttype"] = CONST}),
            _obj(
                {["input"] = "phi", ["tag"] = "mi", ["output"] = (function()
                        if _bool(fixphi) then
                            return "\207\149"
                        else
                            return "\207\134"
                        end
                    end)(), ["tex"] = null, ["ttype"] = CONST}
            ),
            _obj(
                {["input"] = "varphi", ["tag"] = "mi", ["output"] = (function()
                        if _bool(fixphi) then
                            return "\207\134"
                        else
                            return "\207\149"
                        end
                    end)(), ["tex"] = null, ["ttype"] = CONST}
            ),
            _obj({["input"] = "Phi", ["tag"] = "mo", ["output"] = "\206\166", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "pi", ["tag"] = "mi", ["output"] = "\207\128", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Pi", ["tag"] = "mo", ["output"] = "\206\160", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "psi", ["tag"] = "mi", ["output"] = "\207\136", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Psi", ["tag"] = "mi", ["output"] = "\206\168", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "rho", ["tag"] = "mi", ["output"] = "\207\129", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "sigma", ["tag"] = "mi", ["output"] = "\207\131", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Sigma", ["tag"] = "mo", ["output"] = "\206\163", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "tau", ["tag"] = "mi", ["output"] = "\207\132", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "theta", ["tag"] = "mi", ["output"] = "\206\184", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "vartheta", ["tag"] = "mi", ["output"] = "\207\145", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Theta", ["tag"] = "mo", ["output"] = "\206\152", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "upsilon", ["tag"] = "mi", ["output"] = "\207\133", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "xi", ["tag"] = "mi", ["output"] = "\206\190", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "Xi", ["tag"] = "mo", ["output"] = "\206\158", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "zeta", ["tag"] = "mi", ["output"] = "\206\182", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "*", ["tag"] = "mo", ["output"] = "\226\139\133", ["tex"] = "cdot", ["ttype"] = CONST}),
            _obj({["input"] = "**", ["tag"] = "mo", ["output"] = "\226\136\151", ["tex"] = "ast", ["ttype"] = CONST}),
            _obj({["input"] = "***", ["tag"] = "mo", ["output"] = "\226\139\134", ["tex"] = "star", ["ttype"] = CONST}),
            _obj({["input"] = "//", ["tag"] = "mo", ["output"] = "/", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "\\\\", ["tag"] = "mo", ["output"] = "\\", ["tex"] = "backslash", ["ttype"] = CONST}),
            _obj({["input"] = "setminus", ["tag"] = "mo", ["output"] = "\\", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "xx", ["tag"] = "mo", ["output"] = "\195\151", ["tex"] = "times", ["ttype"] = CONST}),
            _obj({["input"] = "|><", ["tag"] = "mo", ["output"] = "\226\139\137", ["tex"] = "ltimes", ["ttype"] = CONST}),
            _obj({["input"] = "><|", ["tag"] = "mo", ["output"] = "\226\139\138", ["tex"] = "rtimes", ["ttype"] = CONST}),
            _obj({["input"] = "|><|", ["tag"] = "mo", ["output"] = "\226\139\136", ["tex"] = "bowtie", ["ttype"] = CONST}),
            _obj({["input"] = "-:", ["tag"] = "mo", ["output"] = "\195\183", ["tex"] = "div", ["ttype"] = CONST}),
            _obj({["input"] = "divide", ["tag"] = "mo", ["output"] = "-:", ["tex"] = null, ["ttype"] = DEFINITION}),
            _obj({["input"] = "@", ["tag"] = "mo", ["output"] = "\226\136\152", ["tex"] = "circ", ["ttype"] = CONST}),
            _obj({["input"] = "o+", ["tag"] = "mo", ["output"] = "\226\138\149", ["tex"] = "oplus", ["ttype"] = CONST}),
            _obj({["input"] = "ox", ["tag"] = "mo", ["output"] = "\226\138\151", ["tex"] = "otimes", ["ttype"] = CONST}),
            _obj({["input"] = "o.", ["tag"] = "mo", ["output"] = "\226\138\153", ["tex"] = "odot", ["ttype"] = CONST}),
            _obj({["input"] = "sum", ["tag"] = "mo", ["output"] = "\226\136\145", ["tex"] = null, ["ttype"] = UNDEROVER}),
            _obj({["input"] = "prod", ["tag"] = "mo", ["output"] = "\226\136\143", ["tex"] = null, ["ttype"] = UNDEROVER}),
            _obj({["input"] = "^^", ["tag"] = "mo", ["output"] = "\226\136\167", ["tex"] = "wedge", ["ttype"] = CONST}),
            _obj({["input"] = "^^^", ["tag"] = "mo", ["output"] = "\226\139\128", ["tex"] = "bigwedge", ["ttype"] = UNDEROVER}),
            _obj({["input"] = "vv", ["tag"] = "mo", ["output"] = "\226\136\168", ["tex"] = "vee", ["ttype"] = CONST}),
            _obj({["input"] = "vvv", ["tag"] = "mo", ["output"] = "\226\139\129", ["tex"] = "bigvee", ["ttype"] = UNDEROVER}),
            _obj({["input"] = "nn", ["tag"] = "mo", ["output"] = "\226\136\169", ["tex"] = "cap", ["ttype"] = CONST}),
            _obj({["input"] = "nnn", ["tag"] = "mo", ["output"] = "\226\139\130", ["tex"] = "bigcap", ["ttype"] = UNDEROVER}),
            _obj({["input"] = "uu", ["tag"] = "mo", ["output"] = "\226\136\170", ["tex"] = "cup", ["ttype"] = CONST}),
            _obj({["input"] = "uuu", ["tag"] = "mo", ["output"] = "\226\139\131", ["tex"] = "bigcup", ["ttype"] = UNDEROVER}),
            _obj({["input"] = "!=", ["tag"] = "mo", ["output"] = "\226\137\160", ["tex"] = "ne", ["ttype"] = CONST}),
            _obj({["input"] = ":=", ["tag"] = "mo", ["output"] = ":=", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "lt", ["tag"] = "mo", ["output"] = "<", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "<=", ["tag"] = "mo", ["output"] = "\226\137\164", ["tex"] = "le", ["ttype"] = CONST}),
            _obj({["input"] = "lt=", ["tag"] = "mo", ["output"] = "\226\137\164", ["tex"] = "leq", ["ttype"] = CONST}),
            _obj({["input"] = "gt", ["tag"] = "mo", ["output"] = ">", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = ">=", ["tag"] = "mo", ["output"] = "\226\137\165", ["tex"] = "ge", ["ttype"] = CONST}),
            _obj({["input"] = "gt=", ["tag"] = "mo", ["output"] = "\226\137\165", ["tex"] = "geq", ["ttype"] = CONST}),
            _obj({["input"] = "-<", ["tag"] = "mo", ["output"] = "\226\137\186", ["tex"] = "prec", ["ttype"] = CONST}),
            _obj({["input"] = "-lt", ["tag"] = "mo", ["output"] = "\226\137\186", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = ">-", ["tag"] = "mo", ["output"] = "\226\137\187", ["tex"] = "succ", ["ttype"] = CONST}),
            _obj({["input"] = "-<=", ["tag"] = "mo", ["output"] = "\226\170\175", ["tex"] = "preceq", ["ttype"] = CONST}),
            _obj({["input"] = ">-=", ["tag"] = "mo", ["output"] = "\226\170\176", ["tex"] = "succeq", ["ttype"] = CONST}),
            _obj({["input"] = "in", ["tag"] = "mo", ["output"] = "\226\136\136", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "!in", ["tag"] = "mo", ["output"] = "\226\136\137", ["tex"] = "notin", ["ttype"] = CONST}),
            _obj({["input"] = "sub", ["tag"] = "mo", ["output"] = "\226\138\130", ["tex"] = "subset", ["ttype"] = CONST}),
            _obj({["input"] = "sup", ["tag"] = "mo", ["output"] = "\226\138\131", ["tex"] = "supset", ["ttype"] = CONST}),
            _obj({["input"] = "sube", ["tag"] = "mo", ["output"] = "\226\138\134", ["tex"] = "subseteq", ["ttype"] = CONST}),
            _obj({["input"] = "supe", ["tag"] = "mo", ["output"] = "\226\138\135", ["tex"] = "supseteq", ["ttype"] = CONST}),
            _obj({["input"] = "-=", ["tag"] = "mo", ["output"] = "\226\137\161", ["tex"] = "equiv", ["ttype"] = CONST}),
            _obj({["input"] = "~=", ["tag"] = "mo", ["output"] = "\226\137\133", ["tex"] = "cong", ["ttype"] = CONST}),
            _obj({["input"] = "~~", ["tag"] = "mo", ["output"] = "\226\137\136", ["tex"] = "approx", ["ttype"] = CONST}),
            _obj({["input"] = "prop", ["tag"] = "mo", ["output"] = "\226\136\157", ["tex"] = "propto", ["ttype"] = CONST}),
            _obj({["input"] = "and", ["tag"] = "mtext", ["output"] = "and", ["tex"] = null, ["ttype"] = SPACE}),
            _obj({["input"] = "or", ["tag"] = "mtext", ["output"] = "or", ["tex"] = null, ["ttype"] = SPACE}),
            _obj({["input"] = "not", ["tag"] = "mo", ["output"] = "\194\172", ["tex"] = "neg", ["ttype"] = CONST}),
            _obj({["input"] = "=>", ["tag"] = "mo", ["output"] = "\226\135\146", ["tex"] = "implies", ["ttype"] = CONST}),
            _obj({["input"] = "if", ["tag"] = "mo", ["output"] = "if", ["tex"] = null, ["ttype"] = SPACE}),
            _obj({["input"] = "<=>", ["tag"] = "mo", ["output"] = "\226\135\148", ["tex"] = "iff", ["ttype"] = CONST}),
            _obj({["input"] = "AA", ["tag"] = "mo", ["output"] = "\226\136\128", ["tex"] = "forall", ["ttype"] = CONST}),
            _obj({["input"] = "EE", ["tag"] = "mo", ["output"] = "\226\136\131", ["tex"] = "exists", ["ttype"] = CONST}),
            _obj({["input"] = "_|_", ["tag"] = "mo", ["output"] = "\226\138\165", ["tex"] = "bot", ["ttype"] = CONST}),
            _obj({["input"] = "TT", ["tag"] = "mo", ["output"] = "\226\138\164", ["tex"] = "top", ["ttype"] = CONST}),
            _obj({["input"] = "|--", ["tag"] = "mo", ["output"] = "\226\138\162", ["tex"] = "vdash", ["ttype"] = CONST}),
            _obj({["input"] = "|==", ["tag"] = "mo", ["output"] = "\226\138\168", ["tex"] = "models", ["ttype"] = CONST}),
            _obj({["input"] = "(", ["tag"] = "mo", ["output"] = "(", ["tex"] = null, ["ttype"] = LEFTBRACKET}),
            _obj({["input"] = ")", ["tag"] = "mo", ["output"] = ")", ["tex"] = null, ["ttype"] = RIGHTBRACKET}),
            _obj({["input"] = "[", ["tag"] = "mo", ["output"] = "[", ["tex"] = null, ["ttype"] = LEFTBRACKET}),
            _obj({["input"] = "]", ["tag"] = "mo", ["output"] = "]", ["tex"] = null, ["ttype"] = RIGHTBRACKET}),
            _obj({["input"] = "{", ["tag"] = "mo", ["output"] = "{", ["tex"] = null, ["ttype"] = LEFTBRACKET}),
            _obj({["input"] = "}", ["tag"] = "mo", ["output"] = "}", ["tex"] = null, ["ttype"] = RIGHTBRACKET}),
            _obj({["input"] = "|", ["tag"] = "mo", ["output"] = "|", ["tex"] = null, ["ttype"] = LEFTRIGHT}),
            _obj({["input"] = "(:", ["tag"] = "mo", ["output"] = "\226\140\169", ["tex"] = "langle", ["ttype"] = LEFTBRACKET}),
            _obj({["input"] = ":)", ["tag"] = "mo", ["output"] = "\226\140\170", ["tex"] = "rangle", ["ttype"] = RIGHTBRACKET}),
            _obj({["input"] = "<<", ["tag"] = "mo", ["output"] = "\226\140\169", ["tex"] = null, ["ttype"] = LEFTBRACKET}),
            _obj({["input"] = ">>", ["tag"] = "mo", ["output"] = "\226\140\170", ["tex"] = null, ["ttype"] = RIGHTBRACKET}),
            _obj({["input"] = "{:", ["tag"] = "mo", ["output"] = "{:", ["tex"] = null, ["ttype"] = LEFTBRACKET, ["invisible"] = true}),
            _obj({["input"] = ":}", ["tag"] = "mo", ["output"] = ":}", ["tex"] = null, ["ttype"] = RIGHTBRACKET, ["invisible"] = true}),
            _obj({["input"] = "int", ["tag"] = "mo", ["output"] = "\226\136\171", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "dx", ["tag"] = "mi", ["output"] = "{:d x:}", ["tex"] = null, ["ttype"] = DEFINITION}),
            _obj({["input"] = "dy", ["tag"] = "mi", ["output"] = "{:d y:}", ["tex"] = null, ["ttype"] = DEFINITION}),
            _obj({["input"] = "dz", ["tag"] = "mi", ["output"] = "{:d z:}", ["tex"] = null, ["ttype"] = DEFINITION}),
            _obj({["input"] = "dt", ["tag"] = "mi", ["output"] = "{:d t:}", ["tex"] = null, ["ttype"] = DEFINITION}),
            _obj({["input"] = "oint", ["tag"] = "mo", ["output"] = "\226\136\174", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "del", ["tag"] = "mo", ["output"] = "\226\136\130", ["tex"] = "partial", ["ttype"] = CONST}),
            _obj({["input"] = "grad", ["tag"] = "mo", ["output"] = "\226\136\135", ["tex"] = "nabla", ["ttype"] = CONST}),
            _obj({["input"] = "+-", ["tag"] = "mo", ["output"] = "\194\177", ["tex"] = "pm", ["ttype"] = CONST}),
            _obj({["input"] = "O/", ["tag"] = "mo", ["output"] = "\226\136\133", ["tex"] = "emptyset", ["ttype"] = CONST}),
            _obj({["input"] = "oo", ["tag"] = "mo", ["output"] = "\226\136\158", ["tex"] = "infty", ["ttype"] = CONST}),
            _obj({["input"] = "aleph", ["tag"] = "mo", ["output"] = "\226\132\181", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "...", ["tag"] = "mo", ["output"] = "...", ["tex"] = "ldots", ["ttype"] = CONST}),
            _obj({["input"] = ":.", ["tag"] = "mo", ["output"] = "\226\136\180", ["tex"] = "therefore", ["ttype"] = CONST}),
            _obj({["input"] = "/_", ["tag"] = "mo", ["output"] = "\226\136\160", ["tex"] = "angle", ["ttype"] = CONST}),
            _obj({["input"] = "/_\\", ["tag"] = "mo", ["output"] = "\226\150\179", ["tex"] = "triangle", ["ttype"] = CONST}),
            _obj({["input"] = "'", ["tag"] = "mo", ["output"] = "\226\128\178", ["tex"] = "prime", ["ttype"] = CONST}),
            _obj({["input"] = "tilde", ["tag"] = "mover", ["output"] = "~", ["tex"] = null, ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "\\ ", ["tag"] = "mo", ["output"] = " ", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "frown", ["tag"] = "mo", ["output"] = "\226\140\162", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "quad", ["tag"] = "mo", ["output"] = "  ", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "qquad", ["tag"] = "mo", ["output"] = "    ", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "cdots", ["tag"] = "mo", ["output"] = "\226\139\175", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "vdots", ["tag"] = "mo", ["output"] = "\226\139\174", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "ddots", ["tag"] = "mo", ["output"] = "\226\139\177", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "diamond", ["tag"] = "mo", ["output"] = "\226\139\132", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "square", ["tag"] = "mo", ["output"] = "\226\150\161", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "|__", ["tag"] = "mo", ["output"] = "\226\140\138", ["tex"] = "lfloor", ["ttype"] = CONST}),
            _obj({["input"] = "__|", ["tag"] = "mo", ["output"] = "\226\140\139", ["tex"] = "rfloor", ["ttype"] = CONST}),
            _obj({["input"] = "|~", ["tag"] = "mo", ["output"] = "\226\140\136", ["tex"] = "lceiling", ["ttype"] = CONST}),
            _obj({["input"] = "~|", ["tag"] = "mo", ["output"] = "\226\140\137", ["tex"] = "rceiling", ["ttype"] = CONST}),
            _obj({["input"] = "CC", ["tag"] = "mo", ["output"] = "\226\132\130", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "NN", ["tag"] = "mo", ["output"] = "\226\132\149", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "QQ", ["tag"] = "mo", ["output"] = "\226\132\154", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "RR", ["tag"] = "mo", ["output"] = "\226\132\157", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "ZZ", ["tag"] = "mo", ["output"] = "\226\132\164", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "f", ["tag"] = "mi", ["output"] = "f", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "g", ["tag"] = "mi", ["output"] = "g", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "lim", ["tag"] = "mo", ["output"] = "lim", ["tex"] = null, ["ttype"] = UNDEROVER}),
            _obj({["input"] = "Lim", ["tag"] = "mo", ["output"] = "Lim", ["tex"] = null, ["ttype"] = UNDEROVER}),
            _obj({["input"] = "sin", ["tag"] = "mo", ["output"] = "sin", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "cos", ["tag"] = "mo", ["output"] = "cos", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "tan", ["tag"] = "mo", ["output"] = "tan", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "sinh", ["tag"] = "mo", ["output"] = "sinh", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "cosh", ["tag"] = "mo", ["output"] = "cosh", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "tanh", ["tag"] = "mo", ["output"] = "tanh", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "cot", ["tag"] = "mo", ["output"] = "cot", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "sec", ["tag"] = "mo", ["output"] = "sec", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "csc", ["tag"] = "mo", ["output"] = "csc", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "arcsin", ["tag"] = "mo", ["output"] = "arcsin", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "arccos", ["tag"] = "mo", ["output"] = "arccos", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "arctan", ["tag"] = "mo", ["output"] = "arctan", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "coth", ["tag"] = "mo", ["output"] = "coth", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "sech", ["tag"] = "mo", ["output"] = "sech", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "csch", ["tag"] = "mo", ["output"] = "csch", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "exp", ["tag"] = "mo", ["output"] = "exp", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "abs", ["tag"] = "mo", ["output"] = "abs", ["tex"] = null, ["ttype"] = UNARY, ["rewriteleftright"] = _arr({[0] = "|", "|"}, 2)}),
            _obj({["input"] = "norm", ["tag"] = "mo", ["output"] = "norm", ["tex"] = null, ["ttype"] = UNARY, ["rewriteleftright"] = _arr({[0] = "\226\136\165", "\226\136\165"}, 2)}),
            _obj({["input"] = "floor", ["tag"] = "mo", ["output"] = "floor", ["tex"] = null, ["ttype"] = UNARY, ["rewriteleftright"] = _arr({[0] = "\226\140\138", "\226\140\139"}, 2)}),
            _obj({["input"] = "ceil", ["tag"] = "mo", ["output"] = "ceil", ["tex"] = null, ["ttype"] = UNARY, ["rewriteleftright"] = _arr({[0] = "\226\140\136", "\226\140\137"}, 2)}),
            _obj({["input"] = "log", ["tag"] = "mo", ["output"] = "log", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "ln", ["tag"] = "mo", ["output"] = "ln", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "det", ["tag"] = "mo", ["output"] = "det", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "dim", ["tag"] = "mo", ["output"] = "dim", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "mod", ["tag"] = "mo", ["output"] = "mod", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "gcd", ["tag"] = "mo", ["output"] = "gcd", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "lcm", ["tag"] = "mo", ["output"] = "lcm", ["tex"] = null, ["ttype"] = UNARY, ["func"] = true}),
            _obj({["input"] = "lub", ["tag"] = "mo", ["output"] = "lub", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "glb", ["tag"] = "mo", ["output"] = "glb", ["tex"] = null, ["ttype"] = CONST}),
            _obj({["input"] = "min", ["tag"] = "mo", ["output"] = "min", ["tex"] = null, ["ttype"] = UNDEROVER}),
            _obj({["input"] = "max", ["tag"] = "mo", ["output"] = "max", ["tex"] = null, ["ttype"] = UNDEROVER}),
            _obj({["input"] = "uarr", ["tag"] = "mo", ["output"] = "\226\134\145", ["tex"] = "uparrow", ["ttype"] = CONST}),
            _obj({["input"] = "darr", ["tag"] = "mo", ["output"] = "\226\134\147", ["tex"] = "downarrow", ["ttype"] = CONST}),
            _obj({["input"] = "rarr", ["tag"] = "mo", ["output"] = "\226\134\146", ["tex"] = "rightarrow", ["ttype"] = CONST}),
            _obj({["input"] = "->", ["tag"] = "mo", ["output"] = "\226\134\146", ["tex"] = "to", ["ttype"] = CONST}),
            _obj({["input"] = ">->", ["tag"] = "mo", ["output"] = "\226\134\163", ["tex"] = "rightarrowtail", ["ttype"] = CONST}),
            _obj({["input"] = "->>", ["tag"] = "mo", ["output"] = "\226\134\160", ["tex"] = "twoheadrightarrow", ["ttype"] = CONST}),
            _obj({["input"] = ">->>", ["tag"] = "mo", ["output"] = "\226\164\150", ["tex"] = "twoheadrightarrowtail", ["ttype"] = CONST}),
            _obj({["input"] = "|->", ["tag"] = "mo", ["output"] = "\226\134\166", ["tex"] = "mapsto", ["ttype"] = CONST}),
            _obj({["input"] = "larr", ["tag"] = "mo", ["output"] = "\226\134\144", ["tex"] = "leftarrow", ["ttype"] = CONST}),
            _obj({["input"] = "harr", ["tag"] = "mo", ["output"] = "\226\134\148", ["tex"] = "leftrightarrow", ["ttype"] = CONST}),
            _obj({["input"] = "rArr", ["tag"] = "mo", ["output"] = "\226\135\146", ["tex"] = "Rightarrow", ["ttype"] = CONST}),
            _obj({["input"] = "lArr", ["tag"] = "mo", ["output"] = "\226\135\144", ["tex"] = "Leftarrow", ["ttype"] = CONST}),
            _obj({["input"] = "hArr", ["tag"] = "mo", ["output"] = "\226\135\148", ["tex"] = "Leftrightarrow", ["ttype"] = CONST}),
            _obj({["input"] = "sqrt", ["tag"] = "msqrt", ["output"] = "sqrt", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "root", ["tag"] = "mroot", ["output"] = "root", ["tex"] = null, ["ttype"] = BINARY}),
            _obj({["input"] = "frac", ["tag"] = "mfrac", ["output"] = "/", ["tex"] = null, ["ttype"] = BINARY}),
            _obj({["input"] = "/", ["tag"] = "mfrac", ["output"] = "/", ["tex"] = null, ["ttype"] = INFIX}),
            _obj({["input"] = "stackrel", ["tag"] = "mover", ["output"] = "stackrel", ["tex"] = null, ["ttype"] = BINARY}),
            _obj({["input"] = "overset", ["tag"] = "mover", ["output"] = "stackrel", ["tex"] = null, ["ttype"] = BINARY}),
            _obj({["input"] = "underset", ["tag"] = "munder", ["output"] = "stackrel", ["tex"] = null, ["ttype"] = BINARY}),
            _obj({["input"] = "_", ["tag"] = "msub", ["output"] = "_", ["tex"] = null, ["ttype"] = INFIX}),
            _obj({["input"] = "^", ["tag"] = "msup", ["output"] = "^", ["tex"] = null, ["ttype"] = INFIX}),
            _obj({["input"] = "hat", ["tag"] = "mover", ["output"] = "^", ["tex"] = null, ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "bar", ["tag"] = "mover", ["output"] = "\194\175", ["tex"] = "overline", ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "vec", ["tag"] = "mover", ["output"] = "\226\134\146", ["tex"] = null, ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "dot", ["tag"] = "mover", ["output"] = ".", ["tex"] = null, ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "ddot", ["tag"] = "mover", ["output"] = "..", ["tex"] = null, ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "ul", ["tag"] = "munder", ["output"] = "\204\178", ["tex"] = "underline", ["ttype"] = UNARY, ["acc"] = true}),
            _obj({["input"] = "ubrace", ["tag"] = "munder", ["output"] = "\226\143\159", ["tex"] = "underbrace", ["ttype"] = UNARYUNDEROVER, ["acc"] = true}),
            _obj({["input"] = "obrace", ["tag"] = "mover", ["output"] = "\226\143\158", ["tex"] = "overbrace", ["ttype"] = UNARYUNDEROVER, ["acc"] = true}),
            _obj({["input"] = "text", ["tag"] = "mtext", ["output"] = "text", ["tex"] = null, ["ttype"] = TEXT}),
            _obj({["input"] = "mbox", ["tag"] = "mtext", ["output"] = "mbox", ["tex"] = null, ["ttype"] = TEXT}),
            _obj({["input"] = "color", ["tag"] = "mstyle", ["ttype"] = BINARY}),
            _obj({["input"] = "cancel", ["tag"] = "menclose", ["output"] = "cancel", ["tex"] = null, ["ttype"] = UNARY}),
            AMquote,
            _obj({["input"] = "bb", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "bold", ["output"] = "bb", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "mathbf", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "bold", ["output"] = "mathbf", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "sf", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "sans-serif", ["output"] = "sf", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "mathsf", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "sans-serif", ["output"] = "mathsf", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "bbb", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "double-struck", ["output"] = "bbb", ["tex"] = null, ["ttype"] = UNARY, ["codes"] = AMbbb}),
            _obj({["input"] = "mathbb", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "double-struck", ["output"] = "mathbb", ["tex"] = null, ["ttype"] = UNARY, ["codes"] = AMbbb}),
            _obj({["input"] = "cc", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "script", ["output"] = "cc", ["tex"] = null, ["ttype"] = UNARY, ["codes"] = AMcal}),
            _obj({["input"] = "mathcal", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "script", ["output"] = "mathcal", ["tex"] = null, ["ttype"] = UNARY, ["codes"] = AMcal}),
            _obj({["input"] = "tt", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "monospace", ["output"] = "tt", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "mathtt", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "monospace", ["output"] = "mathtt", ["tex"] = null, ["ttype"] = UNARY}),
            _obj({["input"] = "fr", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "fraktur", ["output"] = "fr", ["tex"] = null, ["ttype"] = UNARY, ["codes"] = AMfrk}),
            _obj({["input"] = "mathfrak", ["tag"] = "mstyle", ["atname"] = "mathvariant", ["atval"] = "fraktur", ["output"] = "mathfrak", ["tex"] = null, ["ttype"] = UNARY, ["codes"] = AMfrk})
        },
        230
    )
    AMnames = _arr({}, 0)
    asciimath.newcommand = newcommand
    asciimath.newsymbol = newsymbol
    asciimath.AMprocesssNode = AMprocessNode
    asciimath.parseMath = parseMath
    asciimath.translate = translate
    asciimath.processNodeR = processNodeR
    asciimath.strarr2docFrag = strarr2docFrag
end)(_ENV)

--------------------------------------------------------------------

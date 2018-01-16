asciimath.lua
=============

A Lua port from JavaScript of [asciimathml](https://github.com/asciimath/asciimathml).

asciimath.lua is a compact Lua program that translates
simple calculator-style math expressions on a webpage to MathML.

IMPORTANT NOTE: the Lua code itself is **MIT-licensed**, as the original ASCIIMathML.js;
but given that it's based on an automatic port of JS to Lua done using the cool
[castl](https://github.com/PaulBernier/castl) app (thanks Paul!), it currently
includes required castl.runtime library, which is **LGPL licensed**. Eventually, it
should be possible to remove this requirement, by gradually porting the code by hand
to "normal" Lua + lpeg (instead of lrexlib).

NOTE: currently, this port requires Lua 5.2 and lrexlib (because of castl.runtime).

TODO:
- [ ] refactor by hand to "normal" Lua code, then drop castl.runtime dependency
  - [ ] or maybe try [pinecone](https://github.com/zekesonxx/pinecone) to boost this,
    now that we have passing tests?
- [ ] translate regular expressions to LPEG, then change NOTE text above

nix-shell --run 'castl --cat asciimath.js | luafmt --stdin > asciimath.lua' shell-js2lua.nix
nix-shell --run 'cp -r $castl_amalgm/lib/node_modules/castl/lua/castl ./' shell-js2lua.nix
nix-shell --run 'cp -r $castl_amalgm/lib/node_modules/castl/LICENSE.txt ./castl/' shell-js2lua.nix

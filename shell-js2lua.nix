#!/usr/bin/env nix-shell
#! nix-shell shell-js2lua.nix --show-trace

with import <nixpkgs> {};

let
  env = stdenv.mkDerivation {
    name = "shell-js2lua";
    buildInputs = [
      lua5_2 lrexlib_pcre
      castl_amalgm
      luafmt_amalgm
      pinecone_2_amalgm
    ];

    inherit lrexlib_pcre;
    inherit castl_amalgm;
    LUA_PATH = "${castl_amalgm}/lib/node_modules/castl/lua/?.lua";
    LUA_CPATH = "${lrexlib_pcre}/lib/lua/5.2/?.so";
    inherit luafmt_amalgm;
    inherit pinecone_2_amalgm;
  };

  pinecone_2_amalgm = stdenv.mkDerivation rec {
    name = "pinecone-2-npm-amalgm-${version}";
    version = "89be4d5";
    src = fetchFromGitHub {
      owner = "zekesonxx"; repo = "pinecone"; rev = "${version}";
      sha256 = "1k1zh0xwbvzllkavglgbc70cp157i8sf20441wax2mjamln3rv0h";
    };
    # TODO(akavel): are below paths incorrect/abuse?
    buildPhase = ''
      export NPM_CONFIG_PREFIX=$out
      export NPM_CONFIG_CACHE=$out/lib/node_modules
      npm install -g
    '';
    buildInputs = [ nodejs ];
    dontInstall = true;
  };

  luafmt_amalgm = stdenv.mkDerivation rec {
    name = "luafmt-npm-amalgm-${version}";
    version = "v2.1.0";
    src = fetchFromGitHub {
      owner = "trixnz"; repo = "lua-fmt"; rev = "${version}";
      sha256 = "0jg912s7g7jvp75a1ipm8pzshjkn6r38g2imlskr0v4hxmm7bg3h";
    };
    # TODO(akavel): are below paths incorrect/abuse?
    # TODO(akavel): can we maybe automate below stuff by detecting gulpfile and running gulp?
    buildPhase = ''
      export NPM_CONFIG_PREFIX=$out
      export NPM_CONFIG_CACHE=$out/lib/node_modules
      npm install
      npm run compile
      npm install -g
    '';
    buildInputs = [ nodejs git ];
    dontInstall = true;
  };

  castl_amalgm = stdenv.mkDerivation rec {
    name = "castl_amalgm-${version}";
    version = "1.2.4";
    src = fetchFromGitHub {
      owner = "PaulBernier"; repo = "castl"; rev = "${version}";
      sha256 = "071nqaapb3lx55bj6xqan24yxa977na8m4a4i3jcidsm8hfziv2p";
    };
    # TODO(akavel): are below paths incorrect/abuse?
    buildPhase = ''
      export NPM_CONFIG_PREFIX=$out
      export NPM_CONFIG_CACHE=$out/lib/node_modules
      npm install -g
    '';
    buildInputs = [ nodejs ];
    dontInstall = true;
  };

  luaPackages = lua52Packages; # SILE uses Lua 5.2 in Nixpkgs
  lrexlib_pcre = luaPackages.buildLuaPackage rec {
    name = "lrexlib-pcre-${version}";
    version = "2.8.0";
    src = fetchFromGitHub {
      owner = "rrthomas"; repo = "lrexlib"; rev = "rel-2-8-0";
      sha256 = "1c62ny41b1ih6iddw5qn81gr6dqwfffzdp7q6m8x09zzcdz78zhr";
    };
    buildInputs = [ luaPackages.luastdlib pcre luarocks ];
    inherit (luaPackages) luastdlib;
    # TODO(akavel): below paths should be auto-detected by Nix wrappers for `lua` and `luarocks`
    # TODO(akavel): same for PCRE_DIR etc.
    LUA_PATH = "${luastdlib}/share/lua/${lua.luaversion}/?.lua;${luastdlib}/share/lua/${lua.luaversion}/?/init.lua";
    configurePhase = ''
      lua mkrockspecs.lua lrexlib ${version}
    '';
    buildPhase = ''
      luarocks --tree=$out \
        make ${name}-1.rockspec \
        PCRE_DIR=${pcre.dev} \
        PCRE_LIBDIR=${pcre.out}/lib
    '';
    dontInstall = true;
  };
in
  env


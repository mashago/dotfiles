" add into /usr/share/vim/vim74/syntax/lua.vim
syn match luaCustomFunction "\(\<function\>\)\@<=\s\+\S\+\s*(\@="
HiLink luaCustomFunction Identifier

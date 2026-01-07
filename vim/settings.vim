let vimsettings = '~/.vim/settings'

for fpath in split(globpath(vimsettings, '*.vim'), '\n')
  exe 'source' fpath
endfor

if has('nvim')
  for fpath in split(globpath(vimsettings, '*.lua'), '\n')
    exe 'luafile' fpath
  endfor
endif

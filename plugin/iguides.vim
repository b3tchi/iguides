" Auto commands
augroup i_guides
  autocmd!

  " if g:indent_guides_enable_on_vim_startup
  "   autocmd VimEnter * :IndentGuidesEnable
  " endif

  let avoid = ['netrw', 'startify', 'help', 'coc-explorer', 'which_key', 'vista_markdown']

  autocmd FileType * if index(avoid, &ft) == -1 | call iguides#start_guides() | endif
  " autocmd BufEnter,WinEnter,FileType * if &ft != 'netrw' && &ft != 'startify' | call iguides#start_guides() | endif

  " Trigger BufEnter and process modelines.
  autocmd ColorScheme * doautocmd i_guides BufEnter

augroup END

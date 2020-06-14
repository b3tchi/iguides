" Auto commands
augroup i_guides
  autocmd!

  " if g:indent_guides_enable_on_vim_startup
  "   autocmd VimEnter * :IndentGuidesEnable
  " endif

  autocmd BufEnter,WinEnter,FileType * if &ft != 'netrw' || &ft != 'startify' | call iguides#start_guides() | endif

  " Trigger BufEnter and process modelines.
  autocmd ColorScheme * doautocmd i_guides BufEnter

augroup END

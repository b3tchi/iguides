" Auto commands
augroup i_guides
  autocmd!

  " if g:indent_guides_enable_on_vim_startup
  "   autocmd VimEnter * :IndentGuidesEnable
  " endif

  autocmd BufEnter,WinEnter,FileType * call iguides#start_guides()

  " Trigger BufEnter and process modelines.
  autocmd ColorScheme * doautocmd i_guides BufEnter

augroup END

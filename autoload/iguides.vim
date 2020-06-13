echom "starting Config"

setlocal foldmethod=expr
setlocal foldexpr=GetPotionFold(v:lnum)

function! GetPotionFold(lnum)

  let thisLine = a:lnum
  let next_indent = IndentLevel(NextNonBlankLine(thisLine))

  if getline(thisLine) =~? '\v^\s*$'
    " return '-1'
    "-1 special foldlevel string => take foldlevel around lines
    let prev_indent = IndentLevel(PrevNonBlankLine(thisLine)) "WIP

    if next_indent == prev_indent
      return prev_indent
    elseif next_indent < prev_indent
      return prev_indent
    elseif next_indent > prev_indent
      return next_indent "return begin fold return 1>
    endif

  endif

  " let next_indent = IndentLevel(NextNonBlankLine(a:lnum))
  let this_indent = IndentLevel(thisLine)

  if next_indent == this_indent
    return this_indent
  elseif next_indent < this_indent
    return this_indent
  elseif next_indent > this_indent
    return '>' . next_indent "return begin fold return 1>
  endif

  return '0'
endfunction

function! IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfunction

function! PrevNonBlankLine(lnum)
  let current = a:lnum - 1

  while current > 0

    if getline(current) =~? '\v\S'
      return current
    endif

    let current -=1

  endwhile

  "-2 error return code
  return -2
endfunction

function! NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1

  while current <=numlines
    if getline(current) =~? '\v\S'
      return current
    endif

    let current +=1

  endwhile

  "-2 error return code
  return -2
endfunction

":help fold-foldtext
function! MyFoldText()
  let line = getline(v:foldstart)

  let nucolwidth = &fdc + &number * &numberwidth
  let windowwidth = winwidth(0) - nucolwidth - 3
  let foldedlinecount = v:foldend - v:foldstart

  " expand tabs into spaces
  let onetab = strpart('          ', 0, &tabstop)
  let line = substitute(line, '\t', onetab, 'g')

  let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
  let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
  return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction

set foldtext=MyFoldText()

"Indentation line guides test
" function! s:IndentLinesEnableb3() "comment because of s: not sure what it means
function! IndentLinesEnableb3()

  if !exists("w:indentLine_indentLineId")
    let w:indentLine_indentLineId = []
  endif

  " let &l:concealcursor = "inc"
  " let &l:conceallevel = "2"

  " call add(w:indentLine_indentLineId, matchadd('Conceal', '^ ', 0, -1, {'conceal': '│'}))

  let space = &l:shiftwidth == 0 ? &l:tabstop : &l:shiftwidth

  "loop till all possible indent levels changed to 20
  " for i in range(space+1, space * 20 + 1, space)
  for i in range(2, 20 , 2)
    " let char = '│' "g:indentLine_char
    " call add(w:indentLine_indentLineId, matchadd('Conceal', '^\s\+\zs\%'.i.'v ', 0, -1, {'conceal': char})) "original replace with |
    " call add(w:indentLine_indentLineId, matchadd('Conceal', '^\s\+\zs\%'.i.'v\ze')) "working highlight
    " call add(w:indentLine_indentLineId, matchadd('IndentGuide', '^\s\+\zs\%'.i.'v\ze'))
    call add(w:indentLine_indentLineId, matchadd('IndentGuide', '^\s\+\zs\%'.i.'v\ze'))
  endfor
  "^\s\+ - ^ start line, \s folow by blank, \+ one at least or more
  "\zs - start of match
  "\%12v - match in 12 virtual column
  "\ze - end of match

  " let s:color_bg = '#232323'
  " exe 'hi Conceal  guibg=' . s:color_bg . ' guifg=' . s:color_bg
endfunction

let g:pretty_indent_namespace = nvim_create_namespace('pretty_indent')

function! PrettyIndent()
  let l:view=winsaveview()
  call cursor(1, 1)
  call nvim_buf_clear_namespace(0, g:pretty_indent_namespace, 1, -1)

  let l:chunksTemp = []

  for i in range(1,10)
    let l:chunksTemp += [[' ', 'IndentGuide'],[' ', 'IndentGuideSkip']]
  endfor

  while 1 "Search till not all ocurrencies found

    let l:match = search('^$', 'W') "return number of line matching regex for empty line '^$'
    if l:match ==# 0
      break "if all found exit
    endif

    let next_indent = IndentLevel(NextNonBlankLine(l:match)) "WIP
    let prev_indent = IndentLevel(PrevNonBlankLine(l:match)) "WIP

    if next_indent == prev_indent
      let l:indent = prev_indent
    elseif next_indent < prev_indent
      let l:indent = prev_indent
    elseif next_indent > prev_indent
      let l:indent = next_indent
    endif

    "calculate number of columns -1 for first space as added automatically before every virtual text
    let l:spaces = (l:indent * &shiftwidth) - 1

    if l:indent > 0

      let l:chunks = l:chunksTemp[0:l:spaces]

      call nvim_buf_set_virtual_text(
        \   0,
        \   g:pretty_indent_namespace,
        \   l:match - 1,
        \   l:chunks,
        \   {}
        \)
        " \   [[repeat('│' . repeat(' ', &shiftwidth - 1) , l:indent), 'IndentGuide']],
        " \   [[repeat(repeat(' ', &shiftwidth - 1) . '│', l:indent / &shiftwidth), 'IndentGuide']],
    endif
  endwhile

  " let s:change_percent = 90 / 100.0
  " let s:color_bg = '#3c3836'
  " let s:color_bg = '#232323'
  " let s:color_fg = '#FFFFFF'
  " let l:new_color = s:color
  " let l:new_color = color_helper#hex_color_darken (s:color, s:change_percent)
  " exe 'hi IndentGuide  guibg=' . s:color_bg . ' guifg=' . s:color_bg

  call winrestview(l:view)

endfunction

function Colorify()

  " let s:color_bg = '#3c3836'
  let s:color_bg = '#232323'
  " let s:color_fg = '#FFFFFF'

  exe 'hi IndentGuide  guibg=' . s:color_bg . ' guifg=' . s:color_bg

endfunction

function iguides#StartGuides()
  echom "Hello World"
  " IndentGuidesDisable
  call Colorify()
  call IndentLinesEnableb3()
  call PrettyIndent()
endfunction

echom "Loaded Config"

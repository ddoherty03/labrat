" labrat.vim — Print labels via labrat from Vim/Neovim

if exists('g:loaded_labrat')
  finish
endif
let g:loaded_labrat = 1

" -----------------------
" Configuration
" -----------------------

if !exists('g:labrat_executable')
  let g:labrat_executable = 'labrat'
endif

if !exists('g:labrat_nl_sep')
  let g:labrat_nl_sep = '~~'
endif

if !exists('g:labrat_label_sep')
  let g:labrat_label_sep = '@@'
endif

if !exists('g:labrat_output')
  let g:labrat_output = expand('~/labrat.pdf')
endif

" -----------------------
" Helpers
" -----------------------

function! s:strip_comments(lines) abort
  return filter(copy(a:lines), 'v:val !~ "^#"')
endfunction

function! s:normalize_paragraph(lines) abort
  let lines = s:strip_comments(a:lines)
  let text  = trim(join(lines, "\n"))
  return substitute(text, "\n", g:labrat_nl_sep, 'g')
endfunction

function! s:get_paragraph_at_point() abort
  let cur = line('.')

  " Find start
  let start = cur
  while start > 1 && getline(start - 1) !~ '^\s*$'
    let start -= 1
  endwhile

  " Find end
  let end = cur
  let last = line('$')
  while end < last && getline(end + 1) !~ '^\s*$'
    let end += 1
  endwhile

  return getline(start, end)
endfunction

function! s:get_paragraphs_from_visual() abort
  let start = getpos("'<")[1]
  let end   = getpos("'>")[1]

  let paras = []
  let i = start

  while i <= end
    " skip blank lines
    while i <= end && getline(i) =~ '^\s*$'
      let i += 1
    endwhile
    if i > end | break | endif

    let pstart = i
    while i <= end && getline(i) !~ '^\s*$'
      let i += 1
    endwhile

    call add(paras, s:normalize_paragraph(getline(pstart, i - 1)))
  endwhile

  return join(paras, g:labrat_label_sep)
endfunction

function! s:get_label_text() abort
  if mode() =~# 'v'
    return s:get_paragraphs_from_visual()
  else
    return s:normalize_paragraph(s:get_paragraph_at_point())
  endif
endfunction

" -----------------------
" Commands
" -----------------------

function! labrat#run(args) abort
  let label = s:get_label_text()
  let cmd = [g:labrat_executable] + a:args + ['-o', g:labrat_output, label]

  if has('nvim')
    call jobstart(cmd, {'detach': v:true})
  else
    call system(join(map(copy(cmd), 'shellescape(v:val)'), ' '))
  endif

  echo "labrat: label sent"
endfunction

command! -range LabratPrint call labrat#run([])
command! -range LabratView  call labrat#run(['-V'])

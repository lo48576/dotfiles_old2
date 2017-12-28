" Change working directory to the directory of the current file.
function! Cdfile()
	cd %:p:h
endfunction
command! -bar -bang -nargs=0 Cdfile call Cdfile()


" http://vim.wikia.com/wiki/Working_with_CSV_files
" Highlight a column in csv text.
" :Csv 1    " highlight first column
" :Csv 12   " highlight twelfth column
" :Csv 0    " switch off highlight
function! CSVH(colnr)
  if a:colnr > 1
    let n = a:colnr - 1
    execute 'match Keyword /^\([^,]*,\)\{'.n.'}\zs[^,]*/'
    execute 'normal! 0'.n.'f,'
  elseif a:colnr == 1
    match Keyword /^[^,]*/
    normal! 0
  else
    match
  endif
endfunction
command! -nargs=1 Csv :call CSVH(<args>)

" Returns RFC 3339 & ISO 8601 compliant datetime string.
function! GoodDateTime()
    let l:src = strftime("%FT%T%z")
    return substitute(l:src, '\(\%(+\|-\)\d\{2\}\)\(\d\{2\}\)$', '\1:\2', '')
endfunction

" ISO 8601 & RFC 3339 (yyyy-mm-ddThh:mm:ss+hh:mm)
" Note that ISO 8601 accepts `+hhmm`-style timezone, but RFC 3339 doesn't.
" See <http://vim.wikia.com/wiki/Insert_current_date_or_time>.
nnoremap <F5> "=GoodDateTime()<CR>P
inoremap <F5> <C-R>=GoodDateTime()<CR>

" Save file and create directory if necessary.
function! SaveAndWrite()
	" FIXME: Don't mkdir normally on path starts with `sudo:`.
	!mkdir -p %:p:h
	w
endfunction
command! -bar -nargs=0 WW call SaveAndWrite()

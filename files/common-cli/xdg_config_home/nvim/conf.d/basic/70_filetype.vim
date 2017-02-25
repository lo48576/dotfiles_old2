" File type specific settings.

" Plain text
autocmd Filetype text setlocal textwidth=0 noexpandtab

" AsciiDoc
autocmd FileType asciidoc setlocal expandtab softtabstop=4 shiftwidth=4 tabstop=4
" Haskell
autocmd FileType haskell setlocal expandtab softtabstop=2 shiftwidth=2 tabstop=2
" TeX
autocmd FileType tex setlocal expandtab softtabstop=4 shiftwidth=4 tabstop=4
" Ruby
autocmd FileType ruby setlocal expandtab softtabstop=2 shiftwidth=2 tabstop=2
" YAML
autocmd FileType yaml setlocal expandtab softtabstop=2 shiftwidth=2 tabstop=2

" vim
autocmd FileType yaml setlocal expandtab softtabstop=2 shiftwidth=2 tabstop=2


" Long long line can make vim quite heavy.
" Disable syntax highlighting on plain text.
function! DisableSyntax()
	"if &ft =~ 'cmake\|asciidoc'
	if &ft =~ 'cmake'
		return
	endif
	set syntax=off
endfunction

augroup PlainText
	autocmd!
	"au BufEnter,BufNewFile,BufRead *.txt set syntax=off
	au BufEnter,BufNewFile,BufRead *.txt call DisableSyntax()
augroup END


""" Temporary setting.
" temporary.
augroup filetypedetect
	autocmd BufRead,BufNewFile,BufEnter *.rs set filetype=rust
augroup END

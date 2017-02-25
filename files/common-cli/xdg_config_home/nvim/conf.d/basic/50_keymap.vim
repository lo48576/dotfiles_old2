" Keymaps.

" Ctrl+@ or Ctrl+`, for JIS keyboard.
inoremap <C-@>		<ESC>
" Ctrl+/ (@dvorak) , Ctrl+[ (@qwerty, US keyboard)
inoremap <C-_>		<ESC>

inoremap <C-d>		<Delete>

" I'd like to use C-g to move cursor, so swap their bindings.
inoremap <C-S-g>u	<C-g>u
iunmap <C-g>u
inoremap <C-S-g>k	<C-g>k
iunmap <C-g>k
inoremap <C-S-g>j	<C-g>j
iunmap <C-g>j

" Disable F1 (built-in) help.
nmap	<F1>		<nop>
imap	<F1>		<nop>
" Use F3 instead of C-j because input method with SKK uses C-j to switch mode.
imap	<F3>		<C-j>
nmap	<F3>		<C-j>

map <silent> <F2> :bp<cr>
map <silent> <F4> :bn<cr>

"" Moving cursor at insert mode (for dvorak)
"" U @ qwerty
"inoremap <C-g>		<Left>
"" I @ qwerty
"inoremap <C-c>		<Down>
"inoremap <C-k>		<Up>
"inoremap <C-l>		<Right>

inoremap <A-h>		<Left>
inoremap <A-j>		<Down>
inoremap <A-k>		<Up>
inoremap <A-l>		<Right>

" Use incremental search by C-n / C-p in command mode.
cnoremap <C-n>		<Down>
cnoremap <C-p>		<Up>

" Close quickfix buffer by 'q' on the buffer.
au FileType qf nnoremap <silent><buffer>q :quit<CR>

" Toggle paste mode.
" See http://qiita.com/quwa/items/019250dbca167985fe32 .
imap <F11> <nop>
set pastetoggle=<F11>

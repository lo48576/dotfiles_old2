" Don't save options ("globals") to session file.
set sessionoptions=blank,buffers,curdir,folds,help,winsize,tabpages

" Prevent automatic breaking long line, because I use Japanese.
set textwidth=0

" Enable autoindent.
set autoindent

" If the terminal can show Japanese, prefer Japanese help.
if $LANG == "ja_JP.UTF-8"
	set helplang=ja,en
else
	set helplang=en
endif

" Encodings and newlines.
set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp,default,latin
set ffs=unix,dos,mac

" Leader.
let maplocalleader = ";"
let mapleader = ";"

" Enable to delete characters with Bksp at any position
" (including head of line).
set backspace=2

" Enable opening another file when the opened buffer is unsaved.
set hidden

" Enable modeline.
set modeline
set modelines=5

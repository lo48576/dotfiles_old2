" Default tab width is 4.
set tabstop=4

" Prevent inserting two tab characters by autoindent
set softtabstop=4
set shiftwidth=4

" Use spaces for default indent.
set expandtab
if exists('&ambiwidth')
	set ambiwidth=double
endif

" Too long line may make vim slower, because of work of syntax highlighting.
" Lower limit of column number to be highlighted can make vim faster.
set synmaxcol=1000

" Scroll offset.
set scrolloff=3

" Disable conceal.
set conceallevel=0
let g:vim_json_syntax_conceal = 0
let g:tex_conceal = ''

" Show line number always.
set number

" Use highlight `CursorLineNr`.
set cursorline

" Make whitespace characters visible.
set list

" tab:tab(capital,subsequent), trail:whitespace(0x20) at the end of line, eol:end of line, nbsp:0xa0
" these must be halfwidth characters.
set listchars=tab:>\ ,trail:-,eol:$,extends:>,precedes:<,nbsp:.

" Don't use bell or visual bell
set vb t_vb=

" TODO: Check if the terminal supports true colors.
if has("nvim") && version >= 704 && ($TERM =~# '-256color$' || $TERM =~# ':Tc$')
	set t_8f=[38;2;%lu;%lu;%lum
	set t_8b=[48;2;%lu;%lu;%lum
	" From neovim-0.1.5
	set termguicolors
endif

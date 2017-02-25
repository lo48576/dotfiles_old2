function! larry_config#dein#memolist#hook_add() abort
	let g:memolist_path = "~/Documents/memo1"
	let g:memolist_memo_suffix = "adoc"
	let g:memolist_memo_date = "%FT%T%z"
	let g:memolist_prompt_tags = 1
	let g:memolist_prompt_categories = 1
	let g:memolist_qfixgrep = 1
	let g:memolist_vimfiler = 1
	let g:memolist_template_dir_path = "~/.config/nvim/template/memolist.vim"

	let g:memolist_unite = 1
	let g:memolist_unite_source = 'file_rec'
	let g:memolist_unite_option = '-start-insert'
endfunction

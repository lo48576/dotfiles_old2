function! larry_config#dein#ag#hook_post_source() abort
	call denite#custom#var('file_rec', 'command',
				\ ['ag', '--follow', '--nocolor', '--nogroup', '--column', '-g', ''])
	call denite#custom#var('grep', 'command', ['ag'])
	call denite#custom#var('grep', 'recursive_opts', [])
	call denite#custom#var('grep', 'final_opts', [])
	call denite#custom#var('grep', 'separator', [])
	call denite#custom#var('grep', 'default_opts', [])
endfunction

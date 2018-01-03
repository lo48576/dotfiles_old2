" About `CFG_RELEASE_CHANNEL`, see
" <https://github.com/rust-lang-nursery/rustfmt/issues/2227> and
" <https://github.com/rust-lang-nursery/rustfmt/commit/dcd6ed7d5eb9329548d849c4cfe5277636cb81da>.
"let g:rustfmt_command = "env CFG_RELEASE_CHANNEL=nightly rustfmt +nightly"
let g:rustfmt_command = "env CFG_RELEASE_CHANNEL=nightly rustup run nightly rustfmt"

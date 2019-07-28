"
" neovim configuration

" tell nvim that we have a dark background, so it won't print dark blue on black
set background=dark

" Show whitespace
set showbreak=#\
set listchars=tab:>-,nbsp:_,trail:!,extends:},precedes:{
set list
" override the override that makes whitespace invisible
" (assuming https://github.com/amix/vimrc is installed)
hi NonText guifg=#6080f0 guibg=#101010 gui=NONE

" I like tabs for indentation.  Wide tabs.
set noexpandtab
set shiftwidth=8
set tabstop=8

" I also like to see line numbers while I'm editing
set number

" case insensitive searches unless mixed case search expression
set ignorecase
set smartcase

" if we don't highlight the current line, neovim under SmarTTY behaves badly
set cursorline

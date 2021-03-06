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
" Hybrid, so it shows current line number and relative offset above & below
" when in normal mode, but absolute line numbers in insert mode
set number relativenumber
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
	autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

" case insensitive searches unless mixed case search expression
set ignorecase
set smartcase

" if we don't highlight the current line, neovim under SmarTTY behaves badly
set cursorline


" amix/vimrc's 'basic' vimrc maps 0 to ^, which means that to go to the actual
" beginning of the line you have to use 'g0' or '|' or '1|'.  I prefer to keep
" the original/expected vim behavior:
"   0 goes to the beginning of the line
"   ^ goes to the first non-blank character on the line
unmap 0

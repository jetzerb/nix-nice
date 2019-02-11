"
" neovim configuration

" tell nvim that we have a dark background, so it won't print dark blue on black
set background=dark

" case insensitive searches unless mixed case search expression
set ignorecase
set smartcase

" Show tabs and trailing whitespace
set listchars=tab:>-,trail:!
set list

" if we don't highlight the current line, neovim under SmarTTY behaves badly
set cursorline

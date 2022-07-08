set nocompatible               " be iMproved
filetype off                   " required!

"Basic VIM Settings

set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set background=dark

set t_Co=256
syntax on


set laststatus=2
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set nocp
set nowrap
set number

set tw=125

set showmatch

set comments=sl:/*,mb:\ *,elx:\ */

autocmd VimEnter * redraw!

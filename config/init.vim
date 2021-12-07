let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0

let g:python3_host_prog = '/usr/bin/python3'

call plug#begin('~/.config/nvim/plugged')

Plug 'crusoexia/vim-monokai'
Plug 'ekalinin/Dockerfile.vim'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
Plug 'fatih/vim-go'
" Plug 'ctrlpvim/ctrlp.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

call plug#end()

source $HOME/.config/nvim/config/vim-go.vim
source $HOME/.config/nvim/config/coc.vim
source $HOME/.config/nvim/config/others.vim

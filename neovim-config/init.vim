let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0

let g:python3_host_prog = '/usr/bin/python3'

call plug#begin('~/.config/nvim/plugged')

Plug 'crusoexia/vim-monokai'
Plug 'ekalinin/Dockerfile.vim'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
Plug 'fatih/vim-go'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

source $HOME/.config/nvim/plug-config/vim-go.vim
source $HOME/.config/nvim/plug-config/coc.vim
source $HOME/.config/nvim/plug-config/others.vim

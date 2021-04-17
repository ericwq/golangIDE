# golangIDE

A neovim based golang IDE, includes go, vim-go, tagbar, lightline, nerdtree and coc.nvim.  just pull docker image from [hub.docker.com](https://hub.docker.com/r/ericwq057/golangide) and run it.

```sh
% docker pull ericwq057/golangide:latest
```

Based on [alpine](https://www.alpinelinux.org/) container. Go language server enabled, syntax highlight IDE.

## Features

- neovim
- golang
- bash
- git
- [htop](https://htop.dev/) - Interactive process viewer.
- [gopls](https://github.com/golang/tools) - go language server.
- [vim-go](https://github.com/fatih/vim-go) - Go development plugin for Vim.
- [coc.nvim](https://github.com/neoclide/coc.nvim) - Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers.
  - coc-go
  - coc-json
  - coc-snippets
  - coc-pairs
  - coc-markdownlint
- [protoc - protocol buffer compiler](https://developers.google.com/protocol-buffers/docs/downloads)
  - [protoc-gen-go](google.golang.org/grpc/cmd/protoc-gen-go-grpc) - Go plugin for the protocol compiler.
- [fzf](https://github.com/junegunn/fzf) - A command-line fuzzy finder.
- [ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern while respecting your gitignore.
- [crusoexia/vim-monokai](https://github.com/crusoexia/vim-monokai) - Refined Monokai color scheme for vim, inspired by Sublime Text.
- [ekalinin/Dockerfile.vim](https://github.com/ekalinin/Dockerfile.vim) - Vim syntax file & snippets for Docker's Dockerfile.
- [itchyny/lightline.vim](https://github.com/itchyny/lightline.vim) - A light and configurable statusline/tabline plugin for Vim.
- [preservim/nerdtree](https://github.com/preservim/nerdtree)- A tree explorer plugin for vim.
- [preservim/tagbar](https://github.com/preservim/tagbar) - Vim plugin that displays tags in a window, ordered by scope.
- [junegunn/fzf](https://github.com/junegunn/fzf) - 🌸 A command-line fuzzy finder.
- [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) - fzf ❤️  vim.

## Reference

- [shared gopls daemon](shared-gopls-daemon.md) - the problem has been fixed by coc.nvim team.
- [How to setup a shared gopls "daemon" process](setup.md) - hands-on experience.
- [Vim as a Go (Golang) IDE using LSP and vim-go](https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/)

## Status

- The golangIDE is verified by [grpc/grpc-go](https://github.com/grpc/grpc-go) project.

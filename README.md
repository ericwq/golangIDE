# golangIDE

A neovim based golang IDE, based on [alpine](https://www.alpinelinux.org/) linux, go language server enabled, syntax highlight IDE. Just pull docker image from [hub.docker.com](https://hub.docker.com/r/ericwq057/golangide) and run it.

## Features

For a full list of integrated softwares, please run `% apk info` in golangIDE.

- [neovim](https://neovim.io) - Vim-fork focused on extensibility and agility.
- [golang](https://golang.org/) - The Go programming language.
- [bash](https://www.gnu.org/software/bash/bash.html) - The GNU Bourne Again shell.
- [git](https://www.git-scm.com/) - Distributed version control system
- [htop](https://htop.dev/) - Interactive process viewer.
- [gopls](https://github.com/golang/tools) - The [go language server](https://pkg.go.dev/golang.org/x/tools/gopls#section-directories).
- [vim-go](https://github.com/fatih/vim-go) - Go development plugin for Vim.
- [coc.nvim](https://github.com/neoclide/coc.nvim) - Nodejs extension host for vim & neovim, load extensions like VSCode and host language servers.
  - [coc-go](https://github.com/josa42/coc-go) - Go language server extension using gopls for coc.nvim.
  - [coc-json](https://github.com/neoclide/coc-json) - Json language extension for coc.nvim.
  - [coc-snippets](https://github.com/neoclide/coc-snippets) - Snippets solution for coc.nvim.
  - [coc-pairs](https://github.com/neoclide/coc-pairs) - Basic auto pairs extension of coc.nvim.
  - [coc-markdownlint](https://github.com/fannheyward/coc-markdownlint) - markdownlint extension for coc.nvim.
- [protoc](https://developers.google.com/protocol-buffers/docs/downloads) - protocol buffer compiler.
  - [protoc-gen-go](google.golang.org/grpc/cmd/protoc-gen-go-grpc) - Go plugin for the protocol compiler.
- [fzf](https://github.com/junegunn/fzf) - 🌸 A command-line fuzzy finder.
- [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) - fzf ❤️  vim.
- [ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern while respecting your gitignore.
- [crusoexia/vim-monokai](https://github.com/crusoexia/vim-monokai) - Refined Monokai color scheme for vim, inspired by Sublime Text.
- [ekalinin/Dockerfile.vim](https://github.com/ekalinin/Dockerfile.vim) - Vim syntax file & snippets for Docker's Dockerfile.
- [itchyny/lightline.vim](https://github.com/itchyny/lightline.vim) - A light and configurable statusline/tabline plugin for Vim.
- [preservim/nerdtree](https://github.com/preservim/nerdtree)- A tree explorer plugin for vim.
- [preservim/tagbar](https://github.com/preservim/tagbar) - Vim plugin that displays tags in a window, ordered by scope.

Please suggest any software which deserved to be integrated into this IDE.

## Quick guide

```sh
% docker pull ericwq057/golangide:latest

% docker run -it -d -h golangide  --env TZ=Asia/Shanghai  --name golang \
  --mount source=proj-vol,target=/home/ide/proj \
  --mount type=bind,source=YOUR-SHARED-DIRECTORY,target=/home/ide/develop \
  golangide:latest

$ docker exec -u ide -it golang bash
```

- `YOUR-SHARED-DIRECTORY` is you local source code directory shared with native OS. E.g. "/Users/qiwang/dev".
- You may need to create a docker volume `proj-vol` first:

```sh
% docker volume create proj-vol
```

- `proj-vol` is also your source code directory, which you don't need to access from native OS. It's faster comparing with shared one.
- Check `% ls /usr/share/zoneinfo` to get the TZ value for your location.

## Reference

- [Shared gopls daemon](shared-gopls-daemon.md) - the problem has been fixed by coc.nvim team.
- [How to setup a shared gopls "daemon" process](setup.md) - hands-on experience.
- [Vim as a Go (Golang) IDE using LSP and vim-go](https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/)

## Status

- Working on detail guide.
- The golangIDE is verified by [grpc/grpc-go](https://github.com/grpc/grpc-go) project.

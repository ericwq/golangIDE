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

## How to setup a shared gopls "daemon" process

If setup incorrectly, gopls will occupied very huge memory >6G memory. I have spent a lot of time to setup vim-go and coc and coc-go. Now gopls only consumes 100M-2G memory for my daily development. Here is a notes about how to setup it correctly. According to the [Running gopls as a daemon](https://github.com/golang/tools/blob/master/gopls/doc/daemon.md)  and my verification. gopls already support this kind of scenario. See the following. My original post is [here](https://github.com/josa42/coc-go/issues/76#issuecomment-678752724), this is a rewrite one.

### Action:  config coc-setting.json for coc-go

```json
{
  "go.goplsArgs": ["-remote=auto", "-logfile", "/tmp/gopls.log"],
  "go.goplsPath": "/home/ide/go/bin/gopls",
}
```

- The 1st thing is the **go.goplsPath** . You need to use the absolute path to specify the gopls, otherwise it might use different gopls version: like `coc/extensions/coc-go-data/bin/gopls`. Please change it to your gopls install path.
- The 2nd thing is the **go.goplsArgs** part. You need to provide the `-remote=auto` parameter, because that is what gopls required. `-logfile` parameter is not must, but it helps us to identify gopls process. See bellow.
- Do **NOT** perform any special gopls configuration for vim-go, just use the default value. In vim-go, gopls will use `remote=auto` by default. That is good for our purpose.

### Action:  enable gopls for vim-go

```vim
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
```

This is an important step to setup vim-go. According to my experience, this can reduce 50% memory consumption by gopls.

### Caution: don't setup language server in coc-setting.json and install coc-go at the same time

If you setup language server in coc-setting.json and instal coc-go at the same time, just as I did before. You will get into trouble. Just install coc-go is enough. If you do both thing, you will start two(maybe more) gopls process by coc. That will occupied double memory than you expect.

### Top output

```txt
Mem: 3683700K used, 4473996K free, 820K shrd, 306808K buff, 2000004K cached
CPU:   0% usr   1% sys   0% nic  98% idle   0% io   0% irq   0% sirq
Load average: 0.46 0.36 0.27 8/490 920
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
  616   588 ide      S    1309m  16%   2   0% /home/ide/go/bin/gopls serve -listen unix;/tmp/gopls-0285b6-daemon.shared -listen.timeout 1m0s
  588   580 ide      S     705m   9%   2   0% /home/ide/go/bin/gopls -remote=auto
  625   581 ide      S     704m   9%   0   0% /home/ide/go/bin/gopls -remote=auto -logfile /tmp/gopls.log
  581   580 ide      S     264m   3%   2   0% node --no-warnings /home/ide/.vim/pack/coc/start/coc.nvim-0.0.78/build/index.js
  197    26 root     R     1584   0%   1   0% top
  580     6 ide      S     8976   0%   3   0% vim clientconn.go
    6     0 ide      S     2424   0%   0   0% bash
   26     0 root     S     2412   0%   0   0% bash
    1     0 ide      S     2408   0%   2   0% /bin/bash
```

- Shared gopls "daemon" process: `PID=616`, occupied 1.3G VSZ mem.
- A gopls sidecar process (start by coc-go ): `PID=625`, occupied 704m VSZ mem. We can identified it by `-logfile /tmp/gopls.log` parameter.
- A gopls sidecar process (start by vim-go): `PID=588`, occupied 705m VSZ mem.

### Analysis

From the above information, we can conclude that:

- vim-go first starts gopls with the default parameter "-remote=auto".  `PID=588` the sidecar process
- `PID=588` starts the shared gopls "daemon" process. `PID=616`
- coc-go starts gopls with the custom parameter `" -remote=auto -logfile /tmp/gopls.log"`. `PID=625` the sidecar process

That above information is exactly what gopls describe in its [document](https://github.com/golang/tools/blob/master/gopls/doc/daemon.md).

### VSZ ? 704M explanation

Don't be confused with the 704M displayed by top command.  Actually each sidecar process only occupied 20M. In my case the daemon process occupied 2.1G. Two sidecar process occupied 40M .

```txt
VSZ: How much virtual memory the process is using.
RES: How much physical RAM the process is using, measured in kilobytes.
```

You can use `htop` command to see the detail, see [using htop](https://www.deonsworld.co.za/2012/12/20/understanding-and-using-htop-monitor-system-resources/#:~:text=RES%20stands%20for%20the%20resident,actually%20sharable%20memory%20or%20libraries.) and [install htop](https://www.cyberciti.biz/faq/install-htop-on-alpine-linux-using-apk/) for detail.

## Analysis of two gopls daemon servers

You can read this [shared gopls daemon](shared-gopls-daemon.md) as a story. The problem has been fixed by coc.nvim team.

# Content
* Release notes
* Important notes
  * Useful command
  * Environment variable
  * About fzf and Rg
  * Fn Key definition
  * source code directory and GOPATH
* Dockerfile
* Quick start
* GolangIDE component
* Screen shot

# Release notes 

2021-04-07: 0.5.3
* upgrade to golang 1.16.3
* upgrade all the components to the latest version.

2021-03-11: 0.5.2
* upgrade to golang 1.16.1
* upgrade all the components to the latest version.

2021-02-19: 0.5.1
* upgrade to golang 1.16.
* upgrade all the components to the latest version.
 
2021-02-05: 0.5.0
* upgrade to golang 1.15.8. 

<!--
2021-01-27: 0.4.11
* upgrade alpine to 3.13. 
* add `ripgrep` package. 
* Hot Key: `F4` starts `:FZF`. (file name search)
* Hot Key: `,`+`space` starts `:Rg`. (file content search)

2021-01-26: 0.4.10
* upgrade to go 1.15.7 and neovim 0.4.4, upgrade all the neovim plugin.

2021-01-19: 0.4.9
* add `coc-markdownlint` with reasonable config. Now the markdown file is checked by default.

2021-01-18: 0.4.8
* Install the protocol compiler plugins for Go according to the official document.
* please don't use v 0.4.7, use this one instead. 

2021-01-16: 0.4.7
* add `colordiff` package, to support `git diff` command.
* refactor the docker file to remove the the following package:  `python3-dev`, `g++`, `gcc`, `make`, `musl-dev`, which is not used in runtime.
* update all the components. 

2020-12-14: 0.4.6
* add fzf 
* add ```Plug 'junegunn/fzf', { 'tag': '0.21.1' }```. For the fzf plugin, only 0.21.1 version is compatible. 
* use ```ctrl+g``` or ```,```+```space``` to search type and file.

2020-12-08: 0.4.5
* change majutsushi/tagbar to preservim/tagbar. 
* memory reduced significantly. gopls upgrade?

2020-12-04: 0.4.4
* upgrade to go 1.15.6 and upgrade all the neovim plugin.

2020-11-19: 0.4.3
* enable g:go_def_mode and g:go_info_mode according to the document. This configuration can reduce the memory consumption (nearly 50% reduction) by gopls.

2020-11-15: 0.4.2
* upgrade to go 1.15.5
* simplify the version scheme: delete the "-alpine-nvim" suffix and "v" prefix.

2020-11-11: v0.4.1-alpine-nvim
* upgrade to go 1.15.4 

2020-10-16: v0.4.0-alpine-nvim
* upgrade to go 1.15.3 

2020-10-15: v0.3.5-alpine-nvim
* upgrade all the nvim plugin to the latest version 

2020-09-15: v0.3.4-alpine-nvim
* upgrade to go 1.15.2
* with this update, now vim-go and coc.nvim can share the gopls daemon process. try it. 

2020-09-14: v0.3.3-alpine-nvim
* add coc-pairs extension

2020-09-09: v0.3.2-alpine-nvim
* Position the (global) quickfix window at the very bottom of the window

2020-09-06: v0.3.1-alpine-nvim
* open NERDTree and tagbar automatically (when open .go file)
* move *.vim to the back end of dockerfile, to speed up the image build

2020-09-02: v0.3-alpine-nvim
* replace vim by neovim
* add F9 for NERDTreeFind
* add python provider support

2020-8-29: v0.3-alpine
* change to vim-plug instead of vim 8 package manager for easy installation
* coc-implementation is working now. 
* reduce the image size without compromise functions. 

2020-8-26: v0.2.5-alpine
* refactor dockerfile
* add go.goplsOptions

2020-8-25: v0.2.4-alpine
* add htop (only 200K, it's more powerful than busybox's top)
* create the empty "proj" directory for volume under $HOME, owned by normal user (ide:develop).  (otherwise you will get a root owned volume)

2020-8-23: v0.2.2-alpine: 
* reduce the memory required by gopls. [share gopls "daemon" proccess](https://github.com/josa42/coc-go/issues/76#issuecomment-678752724). 
 
2020-8-22: v0.2.1-alpine: 
* update golang to v1.15. 
* update .bashrc 
  * add alias "vi=vim" to avoid mistyping
  * add LANG=en_US.UTF-8
* add  .bash_profile   
* remove gcc 
-->

# Important notes
now the alpine version is **267M** after compressed. before compressed, it's around **700M**. 

the **debian version is not maintained** any more. because its size is too huge. please use alpine version instead. and use the latest tag version.
## Useful command

### start the container
```sh
% docker run -it -d -h golangide  --env TZ=Asia/Shanghai  --name v0.4-nvim \
	--mount source=proj-vol,target=/home/ide/proj \
	--mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
	golangide:0.4.5
```
### Login as normal user
```sh
% docker exec -u ide -it v0.4-nvim bash
```
### Login as root user
```sh
% docker exec -u 0 -it v0.4-nvim bash
```
### Build the image and push it to git hub.
```sh
% docker build -t golangide:0.4.5 -f golangide.dockerfile .

% docker tag golangide:0.4.5 ericwq057/golangide:0.4.5

% docker push ericwq057/golangide:0.4.5
```

## Environment variable
```sh
export GO111MODULE=on
export GOPATH=/go
export LANG=en_US.UTF-8
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
```

## About fzf and Rg
In neovim, type `,`+`space` to activate Rg. to perform file content search. F4 to activate fzf, to perform file name search. You can change the Hot-keys in `others.vim`.
Using ```ctrl+g``` command to search golang type and function for current package. 

## Fn Key definition
NERDTree is ON by default. Tagbar is OFF by default.
```
nmap <F4> :FZF<CR>
nmap <F5> :NERDTreeToggle<CR>
nmap <F6> :nohlsearch<CR>
autocmd FileType go nmap <F7> :GoSameIdsToggle<CR>
nmap <F8> :TagbarToggle<CR>
nmap <F9> :NERDTreeFind <CR>
nnoremap <silent> <F10> :set spell!<cr>
```
## source code directory and GOPATH
the following is the explanation of directories in golanIDE. all this directories belong to user **ide** (group: develop). 

* **/go** directory is your GOPATH, a lot of go package will be stored in it. you can mount a volume to persist the go directory
* **/home/ide/develop**  this is my personal setting.  DEVELOP directory is a bind-mount directory, it's purpose is to exchange files between container and my Mac OS, 
* **/home/ide/proj** directory is an empty directory, you can mount a volume to persist your PROJ directory.

```sh
ide@golangide:~ $ ls -l
total 8
drwxr-xr-x   17 ide      develop       544 Aug 26 11:49 develop
drwxr-sr-x    5 ide      develop       4096 Aug 25 07:43 proj

ide@golangide:/go $ ls -al
total 24
drwxrwxrwx    1 ide      develop       4096 Aug 29 14:01 .
drwxr-xr-x    1 root     root          4096 Aug 29 14:19 ..
drwxrwxrwx    1 ide      develop       4096 Aug 29 14:12 bin
drwxr-xr-x    1 ide      develop       4096 Aug 29 14:22 pkg
drwxrwxrwx    1 ide      develop       4096 Aug 29 14:11 src
```
# Dockerfile
check [golangIDE](https://github.com/ericwq/golangIDE) for other config file and more dockerfile.

* [golangide.dockerfile](https://github.com/ericwq/golangIDE/blob/master/golangide.dockerfile)

# Quick start
```
% docker images
REPOSITORY                        TAG             IMAGE ID       CREATED        SIZE
ericwq057/golangide               0.4.5           bd69f3836d02   5 days ago     827MB
golangide                         0.4.5           bd69f3836d02   5 days ago     827MB
ericwq057/golangide               0.4.4           e483288a2fb4   8 days ago     827MB
golangide                         0.4.4           e483288a2fb4   8 days ago     827MB
golang                            1.15.6-alpine   53efefffaa70   9 days ago     300MB
golang                            1.15.5-alpine   1de1afaeaa9a   4 weeks ago    299MB
alpine                            3.12            a24bb4013296   6 months ago   5.57MB
```
Actually, I use the following command to start golangIDE.
```
" start golangide:alpine
docker run -it -d -h golangide  --env TZ=Asia/Shanghai  --name v0.4-nvim \
	--mount source=proj-vol,target=/home/ide/proj \
	--mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
	golangide:0.4.5

" login as root 
% docker exec -u 0 -it v0.4-nvim bash
" login as ide user
% docker exec -u ide -it v0.4-nvim bash
```
Please note: TZ environment variable is necessary for me. Its purpose is to set the correct time zone for your container. You should replace it by your TZ value or just ignore it. **tips**: using the following command to get the right TZ value on Mac.
```
% export TZ=$(readlink /etc/localtime | sed 's#/var/db/timezone/zoneinfo/##')
% env | grep TZ
```
# GolangIDE components

From the screenshot. We know there is vim, tagbar, lightline, nerdtree, vim-go and coc.nvim. Actually, that's just what you can see from the UI. Besides the above components, GolangIDE includes the following items to build the base of IDE:

* nvim (v 0.4.4)
* golang (v 1.16) 
* git (v 2.30)
* protobuf-compiler (v 3.3)

it also contains the following items

* [vim-go](https://github.com/fatih/vim-go)
* [lightline](https://github.com/itchyny/lightline.vim) 
* [coc.nvim](https://github.com/neoclide/coc.nvim)
* [nerdtree](https://github.com/preservim/nerdtree)
* [tagbar](https://github.com/preservim/tagbar)
* [Dockerfile](https://github.com/ekalinin/Dockerfile.vim)
* bash (preferred SHELL)
* coc-json, coc-snippets, coc-pair
* go tools: asmfmt, errcheck, godef, golangci-lint, gomodifytags, gorename, guru, impl, motion, dlv, fillstruct, goimports, golint, gopls, gotags, iferr, keyify      
* nodejs, npm (required by coc.nvim)
* protoc-gen-go (Go plugin for the protocol compiler)
* ctags (required by tagbar)
* curl.

# Screen shot
here is the screen shot when you run the nvim command in the container.

![ScreenShot](https://github.com/ericwq/golangIDE/raw/master/ScreenShot3.png)


# golangIDE

a neovim based golang IDE. includes go, vim-go, tagbar, lightline, nerdtree and coc.nvim. This site is just a support site for the docker container.
just pull docker image from [hub.docker.com](https://hub.docker.com/r/ericwq057/golangide) and run it. 
```
% docker pull docker push ericwq057/golangide:v0.5.3
```

# Before read the following, 
you need to read [shared gopls daemon](shared-gopls-daemon.md) first. 

### How to setup a shared gopls "daemon" process
if setup incorrectly, gopls will occupied very huge memory >6G mem. I have spent a lot of time to setup vim-go and coc and coc-go. Now gopls  only comsume 100M-4G mem for my daily development. Here is a notes about how to setup it correctly. according to the [Running gopls as a daemon](https://github.com/golang/tools/blob/master/gopls/doc/daemon.md)  and my verificaiton. gopls already support this kind of scenario. see the following.
this is a rewrite content. my original post is [here](https://github.com/josa42/coc-go/issues/76#issuecomment-678752724)

### Action:  config coc-setting.json for coc-go
```json
{
  "go.goplsArgs": ["-remote=auto", "-logfile", "/tmp/gopls.log"],
  "go.goplsPath": "/home/ide/go/bin/gopls",
}
```
- [x] the 1st thing is the **go.goplsPath** part. you need to use the absolute path to specify the gopls, otherwise it might use different gopls version, like ```coc/extensions/coc-go-data/bin/gopls```. please change it to your gopls install path.
- [x] the 2nd thing is the **go.goplsArgs** part. you need to provide the ```-remote=auto``` args, because that is what gopls required. i add the ```-logfile``` args to help us identify gopls process. see bellow.
- [x] do **NOT** perform any special gopls configuration for vim-go, just leave it. in vim-go gopls will use ```remote=auto``` by default. that is enough for our purpose.

### Action:  enable gopls for vim-go
```vimscript
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
```
this is an important step to setup vim-go. according to my experience, this can reduce 50% memory consumption by gopls.

### Caution: don't config languageserver in coc-setting.json and install coc-go at the same time
if you config languageserver in coc-setting.json, and instal coc-go, just as i did before. you will get into trouble.  just install coc-go is enough. if you do both thing, you will start two(maybe more) gopls process by coc. that will occupied double memory than you expect.

### Top output 
```sh
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
* shared gopls "daemon" process: ```PID=616```, occupied 1.3G VSZ mem.
* a gopls sidecar  process (start by coc-go ): ```PID=625```, occupied 704m VSZ mem. we can identified it by ```-logfile /tmp/gopls.log``` args.
* a gopls sidecar process (start by vim-go): ```PID=588```, occupied 705m VSZ mem.
### Analysis
from the above information, we can conclude that: 
* vim-go first start gopls with the default args "-remote=auto".  ```PID=588``` the sidecar process
* ```PID=588``` start the shared gopls "daemon" process. ```PID=616```
* coc-go start gopls with the custom args ```" -remote=auto -logfile /tmp/gopls.log"```. ```PID=625``` the sidecar process

that above process is exactly what gopls describe in its [document](https://github.com/golang/tools/blob/master/gopls/doc/daemon.md).

### VSZ ? 704M explanation
Don't be confused with the 704m displayed by top command.  Actually each sidecar process only occupied 20M mem. In my case the daemon process occupied 2.1G mem. two sidecar process occupied 40M mem.
```
VSZ: How much virtual memory the process is using.
RES: How much physical RAM the process is using, measured in kilobytes.
```
you can use ```htop``` command to see the detail, see [using htop](https://www.deonsworld.co.za/2012/12/20/understanding-and-using-htop-monitor-system-resources/#:~:text=RES%20stands%20for%20the%20resident,actually%20sharable%20memory%20or%20libraries.) and [install htop](https://www.cyberciti.biz/faq/install-htop-on-alpine-linux-using-apk/) for detail

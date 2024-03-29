# Problem: two gopls daemon servers

After install vim-go and coc.nvim and setup gopls correctly, I found there are two gopls servers when I start my neovim/vim. see bellow:

```sh
Mem: 3897112K used, 2196200K free, 708K shrd, 88764K buff, 581780K cached
CPU:   0% usr   2% sys   0% nic  97% idle   0% io   0% irq   0% sirq
Load average: 0.10 0.12 0.09 1/506 22264
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
21606 21582 ide      S    2916m  48%   2   3% /go/bin/gopls serve -listen unix;/tmp/nvimPaFflp/gopls-0285b6-daemon.shared -listen.timeout 1m0s
14426     1 ide      S    1042m  17%   2   0% /go/bin/gopls serve -listen unix;/tmp/gopls-0285b6-daemon.shared -listen.timeout 1m0s
21430 21421 ide      S     705m  12%   1   0% /go/bin/gopls -remote=auto -logfile=auto
21582 21423 ide      S     705m  12%   3   0% /go/bin/gopls -remote=auto -logfile=auto
21423 21421 ide      S     292m   5%   2   0% /usr/bin/node --no-warnings /home/ide/.config/nvim/plugged/coc.nvim/build/index.js
21421  1192 ide      S    32552   1%   2   0% nvim main.go
```

Note the two gopls process with the 'serve' parameters, that means vim-go and coc.nvim both start a gopls daemon server. Why? And there are a lot of discussion about how to share the gopls daemon process on the internet. This problem involves at least 4 different open source projects: gopls, vim-go, coc.nvim and coc-go. Each one believes they are doing the right things.

After several days digging, I found the reason.

## Root cause: vim-go and coc.nvim use different TMPDIR

The gopls daemon process `/go/bin/gopls serve -listen` was stared by the sidecar process `/go/bin/gopls -remote=auto` . Follow this hint, I found the setup code for gopls daemon process. In [autostart_posix.go](https://github.com/golang/tools/blob/master/internal/lsp/lsprpc/autostart_posix.go), line 71 use the `os.TempDir()` to build the unix socket address. (How to find autostart_posix.go is another long story.)

vim-go did nothing special to TMPDIR, it's just use plain `/tmp/`, While coc.nvim changed TMPDIR to `/tmp/nvimPaFflp/`. Both did the right thing. But put it together, gopls will start with two daemon process instead of share it.

## Verify

Force coc.nvim to use the `/tmp/` directory for TMPDIR is the easiest way to verify the analysis. The modification procedure is too brute to show here (sorry coc.nvim guys). While the result is what we expected, see bellow.

```txt
Mem: 1469560K used, 4623752K free, 708K shrd, 89236K buff, 582528K cached
CPU:   0% usr   0% sys   0% nic  98% idle   0% io   0% irq   0% sirq
Load average: 0.49 0.32 0.22 2/495 23634
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
23315 23313 ide      S     290m   5%   3   1% /usr/bin/node --no-warnings /home/ide/.config/nvim/plugged/coc.nvim/build/index.js
23360 23315 ide      S     704m  12%   3   0% /go/bin/gopls -remote=auto -logfile=auto
23346 23322 ide      S     975m  16%   1   0% /go/bin/gopls serve -listen unix;/tmp/gopls-0285b6-daemon.shared -listen.timeout 1m0s
23322 23313 ide      S     704m  12%   1   0% /go/bin/gopls -remote=auto -logfile=auto
23313  1192 ide      S    21660   0%   0   0% nvim main.go
23368 23313 ide      S    18184   0%   2   0% /usr/bin/python3 -c import sys; sys.path.remove(""); import neovim; neovim.start_host() script_host.py
```

Now there is only ONE **shared daemon process**.

## Solution

The suggest solution is to change the gopls code. Because `TMPDIR` is very easy to be changed by others. How to modify gopls code is up to the gopls developer. I already reported the issue to the gopls team. See this [post](https://groups.google.com/g/golang-tools/c/y3OQNIudLzQ/m/7JYRgEZSAgAJ)

## Code clue

```sh
ide@golangide:~/proj $ cd coc.nvim

ide@golangide:~/proj/coc.nvim $ grep -r TMPDIR *
autoload/coc/client.vim:            \ 'TMPDIR': tmpdir,
autoload/coc/client.vim:      \ 'TMPDIR': getenv('TMPDIR'),
autoload/coc/client.vim:    call setenv('TMPDIR', tmpdir)
jest.js:  process.env.TMPDIR = '/tmp/coc-test'
src/workspace.ts:      let dir = path.join(process.env.TMPDIR, `coc.nvim-${process.pid}`)
src/util/logger.ts:  dir = path.join(process.env.TMPDIR, `coc.nvim-${process.pid}`)

ide@golangide:~/proj/coc.nvim $ cd ../vim-go/

ide@golangide:~/proj/vim-go $ grep -r TMPDIR *
autoload/go/util.vim:    let l:dirs = [$TMPDIR, '/tmp', './', $HOME]
```

Then open the `autoload/coc/client.vim` and changed the TMPDIR setting. You can verify it by yourself. client.vim is script. Easy to change and see the result.

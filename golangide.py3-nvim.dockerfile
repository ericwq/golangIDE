FROM golang:1.15-alpine

# golangci-lint need gcc, make and musl-dev
# python3 for coc python provider
RUN apk add --no-cache \
        bash \
        neovim \
        git \
        curl \
        ctags \
        nodejs-current \
        npm \
        tzdata \
        htop \
        protoc \
	py3-pip \
	python3-dev \
	gcc \
	make \
	musl-dev

SHELL ["/bin/bash", "-c"]

ENV HOME /home/ide
ENV GOPATH /go

# Create user/group : ide/develop
RUN addgroup develop && adduser -D -h $HOME -s /bin/bash -G develop ide
RUN chown -R ide:develop $GOPATH

USER ide:develop
WORKDIR $HOME

# Prepare for the nvim
RUN mkdir -p $HOME/.config/nvim/ && \
	mkdir -p $HOME/.config/nvim/plugged && \
	mkdir -p $HOME/.config/nvim/plug-config && \
	mkdir -p $HOME/.config/coc/extensions

# Install vim-plug
# https://github.com/junegunn/vim-plug
WORKDIR $HOME
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Copy the .init.vim : init0.vim contains only the plugin part
COPY --chown=ide:develop ./neovim-config/init0.vim 	$HOME/.config/nvim/init.vim

# Install neovim python provider pynvim
RUN pip install pynvim

# Install all the vim-plug plugins
RUN nvim --headless -c 'PlugInstall' -c qall

# Prepare the coc-settings.json and package.json
COPY --chown=ide:develop ./neovim-config/package.json 	$HOME/.config/coc/extensions/package.json
COPY --chown=ide:develop coc-settings.json 		$HOME/.config/nvim/

# GoInstallBinaries for vim-go: need to wait a very long time for install
RUN nvim --headless -c 'GoInstallBinaries' -c qall && \
	go clean -cache -modcache -testcache

# Install COC extension: coc-go coc-json coc-snippets
WORKDIR  $HOME/.config/coc/extensions
RUN nvim --headless -c 'CocInstall -sync coc-go coc-json coc-snippets' -c qall &&\
	npm cache clean --force

# Go plugin for the protocol compiler:protoc-gen-go
RUN go get github.com/golang/protobuf/protoc-gen-go && \
	go clean -cache -modcache -testcache && \
	rm -rf /go/src/*

# Copy the init.vim: this is the full version
COPY --chown=ide:develop ./neovim-config/init.vim 	$HOME/.config/nvim/init.vim

# Prepare the coc, vim-go and others config file
COPY --chown=ide:develop ./neovim-config/coc.vim 	$HOME/.config/nvim/plug-config/coc.vim
COPY --chown=ide:develop ./neovim-config/vim-go.vim 	$HOME/.config/nvim/plug-config/vim-go.vim
COPY --chown=ide:develop ./neovim-config/others.vim 	$HOME/.config/nvim/plug-config/others.vim

# create the empty proj directory for volume mount
RUN mkdir -p $HOME/proj

# Setup the shell environement
RUN touch $HOME/.bash_profile && \
	echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> $HOME/.bash_profile
RUN touch $HOME/.bashrc && \
	echo >> $HOME/.bashrc && \
	echo 'export GO111MODULE=on' >>  $HOME/.bashrc && \
	echo 'export GOPATH=/go' >> $HOME/.bashrc && \
 	echo 'export LANG=en_US.UTF-8' >> $HOME/.bashrc  && \
	echo 'export PATH=$PATH' >> $HOME/.bashrc  && \
	echo 'alias vi=nvim' >> $HOME/.bashrc && \
	echo "export PS1='\u@\h:\w $ '" >> $HOME/.bashrc

WORKDIR $HOME

CMD ["/bin/bash"]

######################################
FROM golang:1.15-alpine AS idebase

ENV GOCACHE /tmp
ENV HOME /home/ide
ENV GOPATH $HOME/go
ENV PATH $GOPATH/bin:$PATH
ENV GO111MODULE=on

# Install vim git etc.
RUN apk update && apk add --no-cache \
	bash \
	vim \
	git \
	ctags \
	nodejs \
	tzdata \
	htop \
	npm \
	protoc

SHELL ["/bin/bash", "-c"]

# Create user/group : ide/develop
RUN addgroup develop && adduser -D -h $HOME -s /bin/bash -G develop ide

######################################
FROM idebase AS idebuilder

# Add build utils
RUN apk add --no-cache \
	make \
	curl 

# Switch to ide user
USER ide:develop
WORKDIR $HOME

# Prepare for the vim 8 plugin
RUN mkdir -m 0755 -p ~/.vim

# Install molokai colorscheme
WORKDIR /tmp
RUN git clone https://github.com/tomasr/molokai.git && \ 
	cd molokai/ && mv colors ~/.vim && cd .. && rm -rf molokai/

# Install Dockerfile plugin
WORKDIR /tmp
RUN git clone https://github.com/ekalinin/Dockerfile.vim.git && \
	cd Dockerfile.vim && make install && cd .. &&  rm -rf Dockerfile.vim

# Install lightline
RUN git clone https://github.com/itchyny/lightline.vim ~/.vim/pack/plugins/start/lightline && \
	vim +"helptags ~/.vim/pack/plugins/start/lightline/doc" +qall

# Install nerdtree
RUN git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree && \ 
	vim +"helptags ~/.vim/pack/vendor/start/nerdtree/doc" +qall
#RUN vim -u NONE -c "helptags ~/.vim/pack/vendor/start/nerdtree/doc" -c q

# Install tagbar 
RUN git clone https://github.com/majutsushi/tagbar.git ~/.vim/pack/plugins/start/tagbar && \
	vim +"helptags ~/.vim/pack/plugins/start/tagbar/doc" +qall

# Setup vim-go
RUN git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
# Perform vim-go :GoInstallBinaries command
# v1 vim +GoInstallBinaries +qall
# v2 vim +'silent :GoInstallBinaries' +qall
# v3 bash -c 'echo | echo | vim +GoInstallBinaries +qall &>/dev/null'
# see .vim/pack/plugins/start/vim-go/plugin/go.vim for more detail
RUN go get github.com/klauspost/asmfmt/cmd/asmfmt@master
RUN go get github.com/go-delve/delve/cmd/dlv@master
RUN go get github.com/kisielk/errcheck@master
RUN go get github.com/davidrjenni/reftools/cmd/fillstruct@master
RUN go get github.com/rogpeppe/godef@master
RUN go get golang.org/x/tools/cmd/goimports@master
RUN go get golang.org/x/lint/golint@master
RUN go get golang.org/x/tools/gopls@latest

# RUN go get github.com/golangci/golangci-lint/cmd/golangci-lint@master
# refer to https://golangci-lint.run/usage/install/
# use curl to remove gcc dependency
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.30.0

RUN go get github.com/fatih/gomodifytags@master
RUN go get golang.org/x/tools/cmd/gorename@master
RUN go get github.com/jstemmer/gotags@master
RUN go get golang.org/x/tools/cmd/guru@master
RUN go get github.com/josharian/impl@master
RUN go get honnef.co/go/tools/cmd/keyify@master
RUN go get github.com/fatih/motion@master
RUN go get github.com/koron/iferr@master

# Go plugin for the protocol compiler:protoc-gen-go
RUN go get github.com/golang/protobuf/protoc-gen-go

# Install coc.nvim
RUN mkdir -m 0755 -p ~/.vim/pack/coc/start
WORKDIR /tmp
RUN curl -O -L https://github.com/neoclide/coc.nvim/archive/v0.0.78.tar.gz
RUN tar xvf v0.0.78.tar.gz && \
	mv coc.nvim-0.0.78/  ~/.vim/pack/coc/start && \
	rm -rf  v0.0.78.tar.gz

# Prepare coc.nvim ~ extensions
RUN mkdir -m 0755 -p ~/.config/coc/extensions 
WORKDIR /tmp
RUN touch package.json && \
 	echo '{"dependencies":{}}' >> package.json && \
	mv package.json ~/.config/coc/extensions

# Install COC extension 
WORKDIR  ~/.config/coc/extensions
RUN cd ~/.config/coc/extensions && npm install coc-go coc-json coc-snippets --global-style \
        --ignore-scripts --no-bin-links --no-package-lock --only=prod

# Copy the .vimrc file and coc-settings.json
COPY --chown=ide:develop coc-settings.json $HOME/.vim/
COPY --chown=ide:develop vimrc $HOME/.vimrc

# Setup the shell environement
RUN touch $HOME/.bash_profile && \
	echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> $HOME/.bash_profile 
RUN touch $HOME/.bashrc && \
	echo >> $HOME/.bashrc && \
	echo 'export GOCACHE=/tmp' >> $HOME/.bashrc && \
	echo 'export GO111MODULE=on' >>  $HOME/.bashrc && \
	echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc && \
 	echo 'export LANG=en_US.UTF-8' >> $HOME/.bashrc  && \
	echo 'export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH' >> $HOME/.bashrc  && \
	echo 'alias vi=vim' >> $HOME/.bashrc && \ 
	echo "export PS1='\u@\h:\w $ '" >> $HOME/.bashrc

######################################
FROM idebase  

# Switch to ide:develop
USER ide:develop
WORKDIR $HOME

# Preparing the GOPATH pkg directory
RUN mkdir -p $HOME/go/pkg

# Preparing the coc environment 
COPY --from=idebuilder --chown=ide:develop $HOME/.config/ 	$HOME/.config/
COPY --from=idebuilder --chown=ide:develop $HOME/.npm/ 		$HOME/.npm/

# Preparing the vim envrionment
COPY --from=idebuilder --chown=ide:develop $HOME/.vim/  	$HOME/.vim/

# Preparing the GOPATH/bin/*
COPY --from=idebuilder --chown=ide:develop $HOME/go/bin/ 	$HOME/go/bin/

# Preparing the vim and bash configuration
COPY --from=idebuilder --chown=ide:develop $HOME/.vimrc 	$HOME/.vimrc
COPY --from=idebuilder --chown=ide:develop $HOME/.bashrc 	$HOME/.bashrc
COPY --from=idebuilder --chown=ide:develop $HOME/.bash_profile 	$HOME/.bash_profile

# Create the empty proj directory for volume mount
RUN mkdir -p $HOME/proj

# Final command
CMD ["/bin/bash"]

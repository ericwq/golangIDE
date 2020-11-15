FROM golang:1.15-alpine

# golangci-lint need gcc, make and musl-dev
RUN apk add --no-cache \
        bash \
        vim \
        git \
        curl \
        ctags \
        nodejs-current \
        npm \
        tzdata \
        htop \
        protoc \
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

# Prepare for the vim 8 plugin
RUN mkdir -m 0755 -p ~/.vim

# Install molokai colorscheme
WORKDIR /tmp
RUN git clone https://github.com/tomasr/molokai.git && \
        cd molokai/ && mv colors ~/.vim && cd .. && rm -rf molokai/

# Copy the .vimrc : vimrc1 contains only the plugin part
COPY --chown=ide:develop vim-config/vimrc1 $HOME/.vimrc

# Install vim-plug
# https://github.com/junegunn/vim-plug
WORKDIR $HOME
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \ 
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install all the plugins
RUN vim +'silent :PlugInstall' +qall

# Prepare coc/extensions/package.json
# TODO: this is a hack, just my guess, but it does work!
RUN mkdir -m 0755 -p ~/.config/coc/extensions
WORKDIR /tmp
RUN touch package.json && \
 	echo '{"dependencies":{}}' >> package.json && \
	mv package.json ~/.config/coc/extensions

# move coc/extensions/package.json to the front did solve the docker bulid problem, 
# but you need to wait a very long time for the installation
# DOES'T WORK for Dockerfile: vim -c "execute 'silent GoUpdateBinaries' | execute 'quit'" 
RUN vim +'silent :GoInstallBinaries' +qall && \
	go clean -cache -modcache -testcache

# Copy the coc-settings.json
COPY --chown=ide:develop coc-settings.json $HOME/.vim/

# Install COC extension: coc-go coc-json coc-snippets
# DOES'T WORK for Dockerfile: vim +'silent :CocInstall coc-go coc-json coc-snippets' +qall
#WORKDIR  ~/.config/coc/extensions
#RUN cd ~/.config/coc/extensions && npm install coc-go coc-json coc-snippets --global-style \
#        --ignore-scripts --no-bin-links --no-package-lock --only=prod
RUN vim -c 'CocInstall -sync coc-go coc-snippets coc-json |q' +qall && \
	npm cache clean --force

# Go plugin for the protocol compiler:protoc-gen-go
RUN go get github.com/golang/protobuf/protoc-gen-go && \
	go clean -cache -modcache -testcache && \
	rm -rf /go/src/*

# Copy the .vimrc : vimrc2 is the complete version
COPY --chown=ide:develop vim-config/vimrc2 $HOME/.vimrc

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
	echo 'alias vi=vim' >> $HOME/.bashrc && \
	echo "export PS1='\u@\h:\w $ '" >> $HOME/.bashrc

# Cleaning
# RUN go clean -cache -modcache -testcache 

WORKDIR $HOME
CMD ["/bin/bash"]

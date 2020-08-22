FROM golang1.5:debian10

# Install vim git ctags etc.
USER root
RUN apt-get install -y \
	vim \
	git \
	ctags 

# Install Node.js 
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs 
		   
USER ide:dev
ENV PATH /usr/local/go/bin:$PATH
ENV GOCACHE /tmp

# Install molokai colorscheme
RUN mkdir -p ~/.vim 
WORKDIR /tmp
RUN git clone https://github.com/tomasr/molokai.git
RUN cd molokai/ && mv colors ~/.vim && cd .. && rm -rf molokai/

# Install lightline
RUN git clone https://github.com/itchyny/lightline.vim ~/.vim/pack/plugins/start/lightline
RUN vim +"helptags ~/.vim/pack/plugins/start/lightline/doc" +qall
#RUN vim -u NONE -c "helptags ~/.vim/pack/plugins/start/lightline/doc"  -c q

# Install nerdtree
RUN git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree
RUN vim +"helptags ~/.vim/pack/vendor/start/nerdtree/doc" +qall
#RUN vim -u NONE -c "helptags ~/.vim/pack/vendor/start/nerdtree/doc" -c q

# Install tagbar and gotags
RUN git clone https://github.com/majutsushi/tagbar.git ~/.vim/pack/plugins/start/tagbar
RUN vim +"helptags ~/.vim/pack/plugins/start/tagbar/doc" +qall
# RUN go get -u github.com/jstemmer/gotags

# Install coc.nvim 
RUN mkdir -p ~/.vim/pack/coc/start 
WORKDIR /tmp
RUN curl -O -L https://github.com/neoclide/coc.nvim/archive/v0.0.78.tar.gz
RUN tar xvf v0.0.78.tar.gz
RUN mv coc.nvim-0.0.78/  ~/.vim/pack/coc/start
RUN rm -rf  v0.0.78.tar.gz

# Install coc.nvim ~ extensions
RUN mkdir -p ~/.config/coc/extensions 
WORKDIR /tmp
RUN touch package.json
RUN echo '{"dependencies":{}}' >> package.json
RUN mv package.json ~/.config/coc/extensions

# Install COC extension 
WORKDIR  ~/.config/coc/extensions
RUN cd ~/.config/coc/extensions && npm install coc-json coc-go coc-snippets --global-style \
	--ignore-scripts --no-bin-links --no-package-lock --only=prod

USER root
RUN apt-get install -y build-essential
USER ide:dev

# Install Dockerfile plugin
WORKDIR /tmp
RUN git clone https://github.com/ekalinin/Dockerfile.vim.git && \
	cd Dockerfile.vim && make install && cd .. &&  rm -rf Dockerfile.vim

# Setup vim-go
RUN git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
# Install go binaries *this will take a very long time
RUN vim +GoInstallBinaries +qall
# RUN vim +'silent :GoInstallBinaries' +qall
# RUN bash -c 'echo | echo | vim +GoInstallBinaries +qall &>/dev/null'

USER root
RUN apt-get autoremove --purge -y build-essential
USER ide:dev

# Clean go environement
RUN go clean -cache && go clean -testcache

# Copy the .vimrc file and coc-settings.json
WORKDIR /tmp
RUN git clone https://github.com/ericwq/golangIDE && \
	cd golangIDE/ && cp coc-settings.json ~/.vim/ && cp vimrc ~/.vimrc && cd .. && rm -rf golangIDE/

#RUN cd ~/go && rm -rf src pkg 

# Change to the workspace directory
WORKDIR /home/ide/
CMD ["/bin/bash"]

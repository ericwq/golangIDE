FROM debian:buster

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Install vim git ctags curl
RUN apt-get update && apt-get install -y curl 

# Install Golang **** Download Golang 1.1.5 * this will take a very long time
WORKDIR /tmp
RUN curl -O https://dl.google.com/go/go1.15.linux-amd64.tar.gz 
RUN tar xvf go1.15.linux-amd64.tar.gz 
RUN mv go /usr/local 
RUN rm -rf go1.15.linux-amd64.tar.gz 

ENV PATH /usr/local/go/bin:$PATH 
ENV GOCACHE /tmp

# Create a user to setup for developing
RUN groupadd dev  && useradd -g dev -ms /bin/bash ide
USER ide:dev
WORKDIR /home/ide
RUN tail -n +9 /home/ide/.bashrc > /home/ide/.bashrc && \
	echo >> /home/ide/.bashrc && \
	echo 'export GOCACHE=/tmp' >> /home/ide/.bashrc && \
	echo 'export GOPATH=$HOME/go' >> /home/ide/.bashrc && \
	echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /home/ide/.bashrc && \
	source ~/.bashrc

WORKDIR /home/ide/
CMD ["/bin/bash"]

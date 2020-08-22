FROM golang1.5:vim

# Install gcc and protobuf-compiler
USER root
RUN apt-get install -y \
	gcc \
	protobuf-compiler

USER ide:dev
WORKDIR /home/ide/
# Go plugin for the protocol compiler:protoc-gen-go
ENV GO111MODULE=on
RUN go get github.com/golang/protobuf/protoc-gen-go
RUN echo 'export GO111MODULE=on' >> /home/ide/.bashrc


# Change to the workspace directory
WORKDIR /home/ide/
CMD ["/bin/bash"]

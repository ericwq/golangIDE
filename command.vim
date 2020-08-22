" get into the docker host machine
docker run -it --rm --privileged --pid=host alpine nsenter -t 1 -m -u -n -i sh

"### Remove Dangling Volumes
docker volume rm $(docker volume ls -q -f "dangling=true")

"### Remove Exited Containers
docker rm $(docker ps -q -f "status=exited")

"### Remove Dangling Images
docker rmi $(docker images -q -f "dangling=true")


"docker build -t golangide:v0.1 -f golang.vim.dockerfile . 
"docker run --rm -it -h IDE golangide:v0.1

" build golangide:debian
docker build -t golangide:v0.1 -f golangide.debian.dockerfile .

" build golangide:alpine
docker build -t golangide:v0.2-alpine -f golangide.alpine.dockerfile .

" A. Create a new volume: 
% docker volume create golangide-vol

" B. Mount it
% docker run -it  --rm -h IDE \
 	--name golangide  \
	--mount source=golangide-vol,target=/home/ide/go  \
	--mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
	golangide:v0.1

" C. Find timezone on Mac
% export TZ=$(readlink /etc/localtime | sed 's#/var/db/timezone/zoneinfo/##')
%env | grep TZ
TZ=Asia/Shanghai

" start golangide:debian
docker run -it  --rm -h golangide --env TZ=Asia/Shanghai --name golangide  \
	--mount source=golangide-vol,target=/home/ide/go  \
	--mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
	golangide:v0.1

" start golangide:alpine
docker run -it  --rm -h golangide --env TZ=Asia/Shanghai  --name golangide \
	--mount source=golangide-vol,target=/home/ide/go  \
	--mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
	golangide:v0.2-alpine

" Share images on Docker Hub
" 1. Tag the image correctly
% docker tag golangide:v0.1-alpine ericwq057/golangide:v0.1-alpine
" 2. sign in with your account at hub.docker.com 
" 3. Push to docker.io
% docker push ericwq057/golangide:v0.1-alpine

" run as root 
% docker exec -u 0 -it golangide-alpine bash

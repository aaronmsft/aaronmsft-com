# README
# ------

# go build + docker build
GOOS=linux GOARCH=amd64 go build -o main main.go
docker build -t hello-golang .

# docker build (multi-stage)
docker build -f Dockerfile-multistage -t hello-golang .

# docker run
docker run --rm -p 8080:8080/tcp -it hello-golang

# build && run
docker build -t hello-golang . && docker run --rm -p 8080:8080/tcp -it hello-golang

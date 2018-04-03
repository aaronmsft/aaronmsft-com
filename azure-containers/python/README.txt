# README
# ------

# docker build
docker build -t hello-python .

# docker run
docker run --rm -p 8080:8080/tcp -it hello-python

# build && run
docker build -t hello-python . && docker run --rm -p 8080:8080/tcp -it hello-python

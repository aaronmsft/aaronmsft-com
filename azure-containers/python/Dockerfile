FROM ubuntu:latest
MAINTAINER Aaron Wislang <aaron.wislang@microsoft.com>

RUN apt-get update \
 && apt-get install -y python3 python3-pip curl \
 && pip3 install --upgrade pip \
 && pip3 install requests flask tornado

ENV LC_ALL="C.UTF-8" LANG="C.UTF-8"

COPY hello.py hello_tornado.py /home/

EXPOSE 8080

WORKDIR /home/

ENTRYPOINT ["python3", "/home/hello_tornado.py"]

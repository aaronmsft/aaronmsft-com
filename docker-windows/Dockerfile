FROM ubuntu:latest
RUN echo "installing tools" \
    && apt-get update && apt-get install -y curl git jq
RUN echo "installing docker cli" \
    && cd /tmp/ \
    && curl -OL https://download.docker.com/linux/static/stable/x86_64/docker-18.09.5.tgz \
    && tar xzvf docker-18.09.5.tgz \
    && cp docker/* /usr/bin/ \
    && rm -rf docker/
EXPOSE 8080

FROM alpine:latest

# We'll likely need to add SSL root certificates
RUN apk --no-cache add ca-certificates curl bash vim git

RUN curl -L https://github.com/gohugoio/hugo/releases/download/v0.37.1/hugo_0.37.1_Linux-64bit.tar.gz | tar -zOxf - hugo > /usr/bin/hugo && chmod +x /usr/bin/hugo

ENTRYPOINT ["bash"]

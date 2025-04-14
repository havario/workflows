FROM --platform=$BUILDPLATFORM golang:alpine AS builder
WORKDIR /go/src/github.com/honeok/Tools/myip
COPY main.go .
RUN set -ex \
    && go mod init github.com/honeok/Tools/myip \
    && go mod tidy \
    && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    && go build -tags netgo -ldflags '-w -s' -o /go/bin/myip main.go

FROM --platform=$TARGETPLATFORM alpine:latest
RUN set -ex \
    && apk update && apk upgrade \
    && apk add tzdata \
    && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/myip /usr/local/bin/myip
ENV TZ=Asia/Shanghai
EXPOSE 8080
ENTRYPOINT ["myip"]
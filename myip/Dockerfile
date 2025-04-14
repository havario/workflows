FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS builder
WORKDIR /go/src/github.com/honeok/Tools/myip
COPY . .
RUN set -ex \
    && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    && go build -tags netgo -ldflags '-w -s' -o /go/bin/myip main.go

FROM alpine:latest
RUN set -ex \
    && apk update && apk upgrade \
    && apk add --no-cache tzdata \
    && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/myip /usr/local/bin/myip
ENV TZ=Asia/Shanghai
EXPOSE 8080
ENTRYPOINT ["myip"]
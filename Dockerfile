FROM golang:1.16-alpine as builder
RUN apk add --no-cache git make
ENV GOOS=linux
ENV CGO_ENABLED=0
ENV GO111MODULE=on
COPY . /src
WORKDIR /src
RUN rm -f go.sum
RUN go get ./...
#No test files in testapp
#RUN go test ./...
RUN make release
RUN go get github.com/rakyll/hey

FROM alpine:3.8
RUN apk add --no-cache ca-certificates curl vim bind-tools netcat-openbsd nmap socat bash openssl tcpdump tcptraceroute strace iperf busybox-extras
WORKDIR /app
COPY --from=builder /src/bin/testapp /app/testapp
COPY --from=builder /go/bin/hey /usr/bin/hey
CMD ["/app/testapp"]

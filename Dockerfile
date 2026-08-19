FROM golang:1.27.0-alpine@sha256:4c9fe60190a2a3350ddc51de80d0224b8a6698d12bdfc999fee45ea9d6c46dbc AS runner-compilation

ARG ARCH
ARG RUNNER_VERSION
ENV GOPATH=""
ENV CGO_ENABLED=0

RUN apk add --no-cache git && \
    git clone https://github.com/drone-runners/drone-runner-docker -b "${RUNNER_VERSION}" && \
    cd drone-runner-docker && \
    GOOS=linux GOARCH=${ARCH} go build -o release/linux/${ARCH}/drone-runner-docker



FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS tmate-installation

ARG ARCH
ARG ARCH_AUX
ARG VARIANT
ARG TMATE_VERSION

RUN apk add -U --no-cache ca-certificates wget && \
    wget https://github.com/tmate-io/tmate/releases/download/${TMATE_VERSION}/tmate-${TMATE_VERSION}-static-linux-"${ARCH}""${ARCH_AUX:-}""${VARIANT:-}".tar.xz && \
    tar -xf tmate-${TMATE_VERSION}-static-linux-"${ARCH}""${ARCH_AUX:-}""${VARIANT:-}".tar.xz && \
    mv tmate-${TMATE_VERSION}-static-linux-"${ARCH}""${ARCH_AUX:-}""${VARIANT:-}"/tmate /bin/ && \
    chmod +x /bin/tmate



FROM scratch

ARG ARCH

EXPOSE 3000

ENV GODEBUG=netdns=go
ENV DRONE_PLATFORM_OS=linux
ENV DRONE_PLATFORM_ARCH=${ARCH}

COPY --from=tmate-installation /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=tmate-installation /bin/tmate /bin/

LABEL com.centurylinklabs.watchtower.stop-signal="SIGINT"

COPY --from=runner-compilation /go/drone-runner-docker/release/linux/${ARCH}/drone-runner-docker /bin/

ENTRYPOINT ["/bin/drone-runner-docker"]

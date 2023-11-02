FROM golang:1.21.3-alpine@sha256:96a8a701943e7eabd81ebd0963540ad660e29c3b2dc7fb9d7e06af34409e9ba6 AS runner-compilation

ARG ARCH
ARG RUNNER_VERSION
ENV GOPATH=""
ENV CGO_ENABLED=0

RUN apk add --no-cache git && \
    git clone https://github.com/drone-runners/drone-runner-docker -b "${RUNNER_VERSION}" && \
    cd drone-runner-docker && \
    GOOS=linux GOARCH=${ARCH} go build -o release/linux/${ARCH}/drone-runner-docker



FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978 as tmate-installation

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

ENV GODEBUG netdns=go
ENV DRONE_PLATFORM_OS linux
ENV DRONE_PLATFORM_ARCH ${ARCH}

COPY --from=tmate-installation /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=tmate-installation /bin/tmate /bin/

LABEL com.centurylinklabs.watchtower.stop-signal="SIGINT"

COPY --from=runner-compilation /go/drone-runner-docker/release/linux/${ARCH}/drone-runner-docker /bin/

ENTRYPOINT ["/bin/drone-runner-docker"]

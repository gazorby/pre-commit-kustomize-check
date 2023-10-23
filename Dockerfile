ARG ALPINE_VERSION=3.18.4

FROM alpine:${ALPINE_VERSION} AS build_base

ENV KUSTOMIZE_VERSION=v5.2.1
ENV KUBECONFORM_VERSION v0.6.3

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG TARGETVARIANT

# Install wget
RUN apk update && apk add --no-cache curl wget
RUN wget -q -O- https://zyedidia.github.io/eget.sh | sh && mv ./eget /usr/bin

# Install kustomize and kubeconform
RUN eget kubernetes-sigs/kustomize --tag ${KUSTOMIZE_VERSION} --to /tmp
RUN eget yannh/kubeconform --tag ${KUBECONFORM_VERSION} --to /tmp

# Published Image
FROM alpine:${ALPINE_VERSION}

COPY --from=build_base /tmp/kustomize /usr/local/bin/kustomize
COPY --from=build_base /tmp/kubeconform /usr/local/bin/kubeconform
COPY ./run.sh /src/run.sh

RUN adduser kustomize -D \
  && apk add git openssh \
  && git config --global url.ssh://git@github.com/.insteadOf https://github.com/

RUN chmod +x /usr/local/bin/kustomize \
  && mkdir ~/.ssh \
  && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

USER kustomize
WORKDIR /src

ENTRYPOINT [ "run.sh" ]

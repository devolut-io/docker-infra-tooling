FROM alpine:3.18 AS builder

ENV VERSION_KUBERNETES  v1.28.8
ENV VERSION_HELM        v3.14.0
ENV VERSION_HELMFILE    0.164.0
ENV VERSION_TERRAFORM   1.8.3
ENV VERSION_VAULT_CLI   1.16.2

RUN apk --update --no-cache add \
  curl \
  git \
  tar \
  wget

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_linux_amd64.zip -o terraform_${VERSION_TERRAFORM}_linux_amd64.zip && \
    unzip terraform_${VERSION_TERRAFORM}_linux_amd64.zip && \
    rm terraform_${VERSION_TERRAFORM}_linux_amd64.zip

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${VERSION_KUBERNETES}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN wget https://get.helm.sh/helm-${VERSION_HELM}-linux-amd64.tar.gz -O helm-${VERSION_HELM}-linux-amd64.tar.gz && \
    tar -xvf helm-${VERSION_HELM}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64 && \
    chmod +x /usr/local/bin/helm

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

RUN helm plugin install https://github.com/databus23/helm-diff && \
    helm plugin install https://github.com/jkroepke/helm-secrets && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git && \
    helm plugin install https://github.com/aslafy-z/helm-git.git && \
    helm plugin install https://github.com/rimusz/helm-tiller

RUN wget https://github.com/helmfile/helmfile/releases/download/v${VERSION_HELMFILE}/helmfile_${VERSION_HELMFILE}_linux_amd64.tar.gz -O helmfile.tar.gz && \
     tar -xvf helmfile.tar.gz && chmod +x helmfile && mv helmfile /usr/local/bin/helmfile

RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

RUN wget https://releases.hashicorp.com/vault/${VERSION_VAULT_CLI}/vault_${VERSION_VAULT_CLI}_linux_amd64.zip && \
    unzip vault_${VERSION_VAULT_CLI}_linux_amd64.zip && \
    mv vault /usr/bin

FROM alpine:3.18

ENV VERSION_AWS_CLI 2.15.14-r0

RUN apk --update --no-cache add \
    bash \
    git \
    python3 \
    aws-cli=${VERSION_AWS_CLI}

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/bin/vault /usr/local/bin
COPY --from=builder /root/.local/share/helm/plugins /root/.local/share/helm/plugins

RUN rm -rf /var/cache/apk/*

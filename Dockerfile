FROM alpine:3.15 AS builder

ENV KUBE_RUNNING_VERSION v1.23.5
ENV HELM_VERSION v3.6.3
ENV HELMFILE_VERSION 0.155.1
ENV TERRAFORM_VERSION 1.1.7

RUN apk --update --no-cache add \
  curl \
  git \
  tar \
  wget

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_RUNNING_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
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

RUN wget https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz -O helmfile.tar.gz && \
     tar -xvf helmfile.tar.gz && chmod +x helmfile && mv helmfile /usr/local/bin/helmfile

RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

RUN wget https://releases.hashicorp.com/vault/1.7.2/vault_1.7.2_linux_amd64.zip && \
    unzip vault_1.7.2_linux_amd64.zip && \
    mv vault /usr/bin

FROM alpine:3.15

ENV AWSCLI 1.17.9

RUN apk --update --no-cache add \
    bash \
    python3 \
    py3-pip

RUN pip3 install --upgrade pip
RUN pip3 install requests awscli==${AWSCLI}

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/bin/vault /usr/local/bin/

RUN rm -rf /var/cache/apk/*

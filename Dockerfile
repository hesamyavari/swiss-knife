#ARG BUILDPLATFORM
FROM alpine:3

ARG KUBE_VERSION
ARG HELM_VERSION
ARG TERRAFORM_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG YQ_VERSION

# kubernetes tools 
RUN apk -U upgrade \
    && apk add --no-cache bash build-base ca-certificates curl gettext git jq openssh python3 python3-dev py3-pip unzip \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl -O /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -O - | tar -xzO ${TARGETOS}-${TARGETARCH}/helm > /usr/local/bin/helm \
    && wget -q https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${TARGETOS}_${TARGETARCH} -O /usr/local/bin/yq \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && unzip -p terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip >  /usr/local/bin/terraform \
    && rm -rf terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/yq /usr/local/bin/terraform \
    && mkdir /config \
    && chmod g+rwx /config /root \
    && helm repo add "stable" "https://charts.helm.sh/stable" --force-update \
    && kubectl version --client \
    && helm version \
## Network tools 
RUN apk add -y \
      tcpdump \
      snmp \
      snmp-mibs-downloader \
      net-tools \
      netcat \
      vim \
      mtr 

RUN helm plugin install https://github.com/chartmuseum/helm-push
# python tools 
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
# docker 
RUN pip install docker-compose-templer

WORKDIR /config

CMD bash
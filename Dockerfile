ARG IMAGE=${IMAGE:-ubuntu:24.04}
ARG NIM_VERSION=${NIM_VERSION:-2.0.14}
ARG HOME=${HOME:-/root}

FROM ${IMAGE}
ARG NIM_VERSION
ARG HOME

WORKDIR ${HOME}
RUN apt-get update && \
  apt-get install -y curl git gcc make && rm -rf /var/lib/apt/lists/* && \
  curl https://raw.githubusercontent.com/emizzle/nimv/refs/heads/master/nimv.sh | bash -s "${NIM_VERSION}"

ENV PATH=${HOME}/.nimble/bin:${PATH}

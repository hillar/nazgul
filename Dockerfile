FROM ubuntu:20.04 as base

MAINTAINER No Maintenance Intended
LABEL description="nazgul :: NMT provider implementation by TartuNLP"

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip \
  wget \
  git \
  swig

FROM base as dependencies

# TODO wait for git+https://github.com/TartuNLP/truecaser.git 
RUN pip3 install git+https://github.com/hillar/truecaser.git

RUN pip3 install mxnet sentencepiece sockeye mosestokenizer estnltk

#TODO wait for https://github.com/TartuNLP/nazgul.git
RUN git clone https://github.com/hillar/nazgul.git


FROM dependencies as runtime
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

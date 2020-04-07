FROM ubuntu:20.04 as base

MAINTAINER No Maintenance Intended
LABEL description="nazgul is NMT provider implementation by TartuNLP https://tartunlp.ai/ "

RUN apt-get update

FROM base as build
RUN apt-get update
RUN  DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip curl swig
# TODO wait for git+https://github.com/TartuNLP/truecaser.git
# RUN pip3 install git+https://github.com/hillar/truecaser.git
RUN pip3 install mxnet sentencepiece sockeye mosestokenizer estnltk
RUN cd /tmp && curl -s -J -O -L https://github.com/hillar/truecaser/archive/master.tar.gz && tar -xf truecaser-master.tar.gz && cd truecaser-master && pip3 install .
RUN pip3 list

RUN mkdir -p /opt/
#TODO wait for https://github.com/TartuNLP/nazgul.git
#RUN cd /opt && git clone https://github.com/hillar/nazgul.git
RUN cd /opt && curl -s -J -O -L https://github.com/hillar/nazgul/archive/master.tar.gz && tar -xf nazgul-master.tar.gz && mv nazgul-master nazgul && rm nazgul-master.tar.gz
RUN cd /opt/nazgul && curl -s -J -O 'https://owncloud.ut.ee/owncloud/index.php/s/sq9FebWmBNe9JGZ/download?path=%2F&files=en-et-lv-ru.tgz' && tar -xf en-et-lv-ru.tgz && rm en-et-lv-ru.tgz
RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge python3-pip


FROM base
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3
COPY --from=build /opt /opt
COPY --from=build /usr/local/lib/python3.8 /usr/local/lib/python3.8
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN echo $(date) > /build.date

EXPOSE 12346
ENTRYPOINT echo "Nazgul Server Docker Image built $(cat /build.date)" \
	    && python3 -V \
      && echo "Sockeye model $(cat /opt/nazgul/en-et-lv-ru/translation/version)" \
      && python3 /opt/nazgul/nmtnazgul.py /opt/nazgul/en-et-lv-ru/translation/ /opt/nazgul/en-et-lv-ru/preprocessing-models/sp.vocab /opt/nazgul/en-et-lv-ru/preprocessing-models/sp.model

#!/bin/bash
FROM jarvice/ubuntu-ibm-mldl-ppc64le

#add Jupyter
RUN pip install ipython==5.0 notebook==5.0 pyyaml
#RUN pip install notebook pyyaml

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
#add startupscripts
RUN apt-get install -y supervisor
RUN apt-get install -y git

# Install packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
    vim \
    jed \
    emacs \
    build-essential \
    python-dev \
    unzip \
    libsm6 \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    libxrender1 \
    inkscape \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
        apt-get install -y --no-install-recommends libav-tools && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install numpy scipy
RUN pip install scikit-learn
RUN pip install --upgrade scikit-learn
RUN pip install pillow
RUN pip install h5py
RUN pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git
RUN pip install keras
RUN pip install seaborn
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install build-essential cmake pkg-config
#RUN apt-get -y install libjpeg62-turbo-dev libtiff5-dev libjasper-dev libpng12-dev
RUN apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
RUN apt-get -y install libxvidcore-dev libx264-dev
RUN apt-get -y install libgtk-3-dev
RUN apt-get -y install libatlas-base-dev gfortran
#RUN apt-get -y install python2.7-dev python3.5-dev
RUN apt-get -y install python-opencv

RUN apt-get -y install lsof
RUN apt-get -y install locate

ENV CACHE_DATE=2017-10-14b

COPY bootstrap.sh /root
COPY wrap_sbin_init.sh /root

USER nimbix
RUN mkdir -p /db && chown nimbix:nimbix /db && cd /db && git clone https://github.com/dustinvanstee/mldl-101.git 
USER root

#
#WORKDIR /tmp
#RUN git clone https://github.com/dustinvanstee/mldl-101.git 
#ADD https://github.com/dustinvanstee/mldl-class-infra/raw/master/bootstrap.sh  /tmp/bootstrap.sh
#RUN bash /tmp/bootstrap.sh

#add NIMBIX application
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


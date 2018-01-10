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
RUN pip install graphviz
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

ENV CACHE_DATE=2017-11-14

RUN apt-get -y install iputils-ping && \
    apt-get -y install software-properties-common && \
    add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" && \ 
    apt update -qq 


COPY bootstrap.sh /root
COPY wrap_sbin_init.sh /root

# for Nimbix, USER nimbix, for now use root
USER root
RUN mkdir -p /data2 && chown nimbix:nimbix /data2 && cd /data2 && \
  git clone https://github.com/dustinvanstee/mldl-101.git && \
  git clone https://github.com/dustinvanstee/nba-rt-prediction.git && \
  wget http://apache.claz.org/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz && \
  wget http://apache.claz.org/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.7.tgz && \
  tar -zxvf spark-2.2.0-bin-hadoop2.7.tgz && \
  tar -zxvf spark-2.1.2-bin-hadoop2.7.tgz

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-8-jdk

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el
ENV SPARK_HOME=/data2/spark-2.1.2-bin-hadoop2.7

# Re-organize once complete

# Add New packages for Tensorflow 1.2 to support coursera
# Add Python3
RUN apt-get install software-properties-common python-software-properties
RUN sudo add-apt-repository -y ppa:jonathonf/python-3.6
RUN apt-get update
RUN python -m ipykernel install --user 
RUN apt-get install -y python3-pip 
RUN  pip3 install --upgrade pip 
RUN  pip3 install ipykernel 
RUN  python3 -m ipykernel install --user
RUN  pip3 install matplotlib
RUN  pip3 install scipy numpy pandas h5py pillow keras


# Add PowerAI Vision





USER root

#
#WORKDIR /tmp
#RUN git clone https://github.com/dustinvanstee/mldl-101.git 
#ADD https://github.com/dustinvanstee/mldl-class-infra/raw/master/bootstrap.sh  /tmp/bootstrap.sh
#RUN bash /tmp/bootstrap.sh

#add NIMBIX application
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


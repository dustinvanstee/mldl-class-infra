#!/bin/bash
FROM nvidia/cuda-ppc64le:8.0-cudnn6-devel-ubuntu16.04

RUN apt-get -y update && \
    apt-get -y install curl && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
        | bash -s -- --setup-nimbix-desktop

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# for standalone use
EXPOSE 5901
EXPOSE 443

# repo
WORKDIR /tmp
ENV POWERAI_LINK https://public.dhe.ibm.com/software/server/POWER/Linux/mldl/ubuntu/mldl-repo-local_4.0.0_ppc64el.deb

RUN curl -O "$POWERAI_LINK" && dpkg --install mldl*.deb && rm -f mldl*.deb

# install packages
RUN apt-get update && apt-get -y install power-mldl numactl && apt-get clean
# COPY motd /etc/motd
# COPY motd /etc/powerai_help.txt
# COPY powerai_help.desktop /etc/skel/Desktop/powerai_help.desktop
# RUN chmod 555 /etc/skel/Desktop/powerai_help.desktop
# RUN echo '\n*** Press Q to exit help.\n' >>/etc/powerai_help.txt


# Run All the apt stuff first ....



# Install packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    supervisor \
    git \
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
    lsof \
    locate \
    iputils-ping \
    libav-tools \
    software-properties-common \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
#     
# Update the repo ...
RUN add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" && \ 
    add-apt-repository -y ppa:jonathonf/python-3.6 && \
    apt update -qq && \
    apt-get install -yq --no-install-recommends \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libv4l-dev \
        libxvidcore-dev \ 
        libx264-dev \
        libgtk-3-dev \
        libatlas-base-dev \
        gfortran \
        cmake \ 
        libgtk2.0-dev \
        pkg-config \
        python-dev \ 
        libtbb2 \
        libtbb-dev \
        python-software-properties \
        python3-pip \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#     #add Jupyter Virtual Envs

# Add Python2 packages
RUN pip install virtualenv && \
  pip install --upgrade pip && \
  virtualenv -p /usr/bin/python2.7 /root/python2_env && \
  . /root/python2_env/bin/activate && \
  pip install tornado \
    ipython==5.0  \
    notebook==5.0  \
    pyyaml \
    numpy \
    scipy \
    scikit-learn \
    pillow \
    h5py \
    seaborn \
    graphviz \
    ipykernel \
  && \
  deactivate

#     
# Add Python3
RUN virtualenv -p /usr/bin/python3 /root/python3_env && \
  . /root/python3_env/bin/activate && \
  pip install numpy \
    pillow \
    h5py \
    seaborn \
    graphviz \
    ipykernel \
    scipy \
    scikit-learn \
  && \
  deactivate


# Add MLDL Frameworks

#     RUN a
#       python -m ipykernel install --user  && \
#       pip3 install --upgrade pip  && \
#       pip3 install ipykernel  && \
#       python3 -m ipykernel install --user 
#     RUN pip3 install matplotlib numpy  pandas h5py pillow
#     RUN pip3 install scipy
#     RUN pip3 install keras
#     
#     
#     
#     
#     
#     
#     COPY bootstrap.sh /root
#     COPY wrap_sbin_init.sh /root
#     
#     # for Nimbix, USER nimbix, for now use root
#     USER root
#     RUN mkdir -p /data2 && chown nimbix:nimbix /data2 && cd /data2 && \
#       git clone https://github.com/dustinvanstee/mldl-101.git && \
#       git clone https://github.com/dustinvanstee/nba-rt-prediction.git && \
#       wget http://apache.claz.org/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz && \
#       wget http://apache.claz.org/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.7.tgz && \
#       tar -zxvf spark-2.2.0-bin-hadoop2.7.tgz && \
#       tar -zxvf spark-2.1.2-bin-hadoop2.7.tgz
#     
#     RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-8-jdk
#     
#     ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el
#     ENV SPARK_HOME=/data2/spark-2.1.2-bin-hadoop2.7
#     
#     # Re-organize once complete
#     
#     # Add New packages for Tensorflow 1.2 to support coursera
#     
#     
#     # Add PowerAI Vision
#     
#     
#     #
#     #WORKDIR /tmp
#     #RUN git clone https://github.com/dustinvanstee/mldl-101.git 
#     #ADD https://github.com/dustinvanstee/mldl-class-infra/raw/master/bootstrap.sh  /tmp/bootstrap.sh
#     #RUN bash /tmp/bootstrap.sh

#add NIMBIX application
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


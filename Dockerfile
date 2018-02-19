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
# A lot of these libs are for opencv ...
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
        libjpeg-dev \
        libdc1394-22-dev \
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
RUN apt update && \
    apt-get install -yq --no-install-recommends \
        python3-dev 

# Add Python3
RUN  pip install virtualenv && \
  pip install --upgrade pip && \
  virtualenv -p /usr/bin/python3 /root/python3_env && \
  . /root/python3_env/bin/activate && \
  pip install numpy \
    scipy \
    scikit-learn \
    pillow \
    h5py \
    seaborn \
    graphviz \
    ipykernel \
    brunel \
  && pip install  --force-reinstall jupyter &&\
  deactivate


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
    brunel \
  && \
  deactivate


# Build and Install opencv ~ long road ..
WORKDIR /root

RUN . /root/python3_env/bin/activate && \
  cd /root && \
  wget -O opencv.zip         https://github.com/opencv/opencv/archive/3.3.0.zip  && \
  wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.3.0.zip  && \
  unzip opencv.zip  && \
  unzip opencv_contrib.zip && \
  cd /root/opencv-3.3.0/ && \
  mkdir /root/opencv-3.3.0/build  && \
  cd /root/opencv-3.3.0/build && \
  sudo cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D INSTALL_C_EXAMPLES=OFF \
      -D OPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib-3.3.0/modules \
      -D WITH_CUDA=OFF \
      -D PYTHON3_EXECUTABLE=/root/python3_env/bin/python3 \
      -D WITH_QT=OFF \
      -D WITH_OPENGL=OFF \
      -D FORCE_VTK=OFF \
      -D WITH_TBB=OFF \
      -D WITH_GDAL=OFF \
      -D WITH_XINE=OFF \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=/root/python3_env/lib/python3.5/site-packages/numpy/core/include/ \
      -D PYTHON3_NUMPY_VERSION=1.14.0 \
      -D BUILD_EXAMPLES=ON ..  && \

  make -j10  && \
  sudo make install  && \
  sudo ldconfig && \
  ln -fs /usr/local/lib/python3.5/site-packages/cv2.cpython-35m-powerpc64le-linux-gnu.so /root/python3_env/lib/python3.5/site-packages/cv2.so  && \
  rm -rf /root/opencv* && \
  deactivate


# for Nimbix, USER nimbix, for now use root
USER root
RUN mkdir -p /data2 && chown nimbix:nimbix /data2 && cd /data2 && \
  git clone https://github.com/dustinvanstee/mldl-101.git && \
  git clone https://github.com/dustinvanstee/nba-rt-prediction.git && \
  wget http://apache.claz.org/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.7.tgz && \
  tar -zxvf spark-2.1.2-bin-hadoop2.7.tgz

# wget http://apache.claz.org/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz && \
# tar -zxvf spark-2.2.0-bin-hadoop2.7.tgz && \

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-8-jdk

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-ppc64el
ENV SPARK_HOME=/data2/spark-2.1.2-bin-hadoop2.7

# Add Custom MLDL Frameworks
#    
WORKDIR /data2 
COPY binaries/tensorflow-1.2.1-cp35-cp35m-linux_ppc64le.whl  /data2/tensorflow-1.2.1-cp35-cp35m-linux_ppc64le.whl
RUN . /root/python3_env/bin/activate && \
  pip install /data2/tensorflow-1.2.1-cp35-cp35m-linux_ppc64le.whl  && \
  git clone https://github.com/keras-team/keras.git  && \
  cd /data2/keras  && \
  git checkout tags/2.0.7 -b origin/master  && \
  python3 setup.py install  && \
  deactivate

# Permissions patching
RUN chown  nimbix:nimbix /root/  && \
 chown -R nimbix:nimbix /root/python2_env  && \
 chown -R nimbix:nimbix /root/python3_env

# Simple utilities
COPY bootstrap.sh /data2
COPY wrap_sbin_init.sh /data2
COPY motd /etc/motd
COPY motd /etc/powerai_help.txt



#add NIMBIX application
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


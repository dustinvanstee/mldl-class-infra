FROM dustinvanstee:powerai-1.5.3-py3
USER root
# Install packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    supervisor \
    git \
    wget \
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
     

################### add NIMBIX application ###################

# RUN apt-get -y update && \
#     apt-get -y install curl && \
#     curl -H 'Cache-Control: no-cache' \
#         https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
#         | bash -s -- --setup-nimbix-desktop
# 
# # Expose port 22 for local JARVICE emulation in docker.
# EXPOSE 22
# 
# # for standalone use
# EXPOSE 5901
# EXPOSE 443


################### add OPENCV application ###################
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

# Build and Install opencv ~ long road ..
WORKDIR /root

RUN cd /root && \
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
      -D PYTHON3_EXECUTABLE=/root/anaconda3/bin/python3 \
      -D WITH_QT=OFF \
      -D WITH_OPENGL=OFF \
      -D FORCE_VTK=OFF \
      -D WITH_TBB=OFF \
      -D WITH_GDAL=OFF \
      -D WITH_XINE=OFF \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=/root/anaconda3/lib/python3.6/site-packages/numpy/core/include/ \
      -D PYTHON3_NUMPY_VERSION=1.14.0 \
      -D BUILD_EXAMPLES=ON ..  && \

  make -j10  && \
  sudo make install  && \
  sudo ldconfig

  RUN ln -fs /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-powerpc64le-linux-gnu.so /root/anaconda3/lib/python3.6/site-packages/cv2.so  && \
  rm -rf /root/opencv* && \
  deactivate



################### add Labs specific ###################

# Simple utilities(cmt)
COPY motd /etc/motd
COPY motd /etc/powerai_help.txt

RUN mkdir -p /dl-labs/supervisor  && cd /dl-labs && \
  git clone https://github.com/dustinvanstee/mldl-101.git && \
  cd /dl-labs/mldl-101/lab4-yolo-keras/model_data && wget https://github.com/dustinvanstee/mldl-101/releases/download/v1.0/yolo_power.h5 -O yolo.h5


# Note, this may override tf 1.8!!
RUN /root/anaconda3/bin/conda install jupyter

#   /root/anaconda3/bin/conda install keras

#&& \
#  /opt/DL/tensorflow/bin/install_dependencies && \
#  /root/anaconda3/bin/conda install -c conda-forge opencv=3.3.0

RUN chown -R pwrai:pwrai /dl-labs

LABEL VERSION="V1.4"

# Autostart Jupyter
COPY conf.d/jupyter_notebook_config.json /dl-labs/.jupyter/
COPY conf.d/jupyter_notebook_config.py /dl-labs/.jupyter/
COPY startjupyter.sh /dl-labs

#add startupscripts
WORKDIR /dl-labs
# ADD startdigits.sh  /root/
#ADD starttensorboard.sh /root/ 
COPY conf.d/tensorflow_jupyter.conf /etc/supervisor/conf.d/

# Add this to autostart jupyter in /dl-labs ... disabling for now ....
COPY rc.local /etc/rc.local
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN chmod 755 /etc/rc.local
RUN update-rc.d rc.local enable 2
EXPOSE 5050

COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


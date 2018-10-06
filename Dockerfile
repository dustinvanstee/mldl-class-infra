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
        python3-dev \
        python3-pip

# Add Python3
RUN  pip install virtualenv && \
  pip install --upgrade pip && \
  virtualenv -p /usr/bin/python3 /root/techulab_env && \
  . /root/techulab_env/bin/activate && \
  pip install numpy \
    scipy \
    scikit-learn \
    pillow \
    h5py \
    ipykernel \
  && pip install  --force-reinstall jupyter &&\
  deactivate


# Build and Install opencv ~ long road ..
WORKDIR /root

RUN . /root/techulab_env/bin/activate && \
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
      -D PYTHON3_EXECUTABLE=/root/techulab_env/bin/python3 \
      -D WITH_QT=OFF \
      -D WITH_OPENGL=OFF \
      -D FORCE_VTK=OFF \
      -D WITH_TBB=OFF \
      -D WITH_GDAL=OFF \
      -D WITH_XINE=OFF \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=/root/techulab_env/lib/python3.5/site-packages/numpy/core/include/ \
      -D PYTHON3_NUMPY_VERSION=1.14.0 \
      -D BUILD_EXAMPLES=ON ..  && \

  make -j10  && \
  sudo make install  && \
  sudo ldconfig && \
  ln -fs /usr/local/lib/python3.5/site-packages/cv2.cpython-35m-powerpc64le-linux-gnu.so /root/techulab_env/lib/python3.5/site-packages/cv2.so  && \
  rm -rf /root/opencv* && \
  deactivate


# Build and Install opencv ~ long road ..
WORKDIR /root
   

# Simple utilities(cmt)
COPY motd /etc/motd
COPY motd /etc/powerai_help.txt




RUN mkdir -p /dl-labs  && cd /dl-labs && \
  git clone https://github.com/dustinvanstee/mldl-101.git && \
  wget http://apache.claz.org/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.7.tgz && \
  tar -zxvf spark-2.1.2-bin-hadoop2.7.tgz && \
  cd /dl-labs/mldl-101/lab4-yolo-keras/model_data && wget https://github.com/dustinvanstee/mldl-101/releases/download/v1.0/yolo_power.h5 -O yolo.h5



#add NIMBIX application
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


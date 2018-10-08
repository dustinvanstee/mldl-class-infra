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
     

#add NIMBIX application

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

   
# Simple utilities(cmt)
COPY motd /etc/motd
COPY motd /etc/powerai_help.txt

RUN mkdir -p /dl-labs/supervisor  && cd /dl-labs && \
  git clone https://github.com/dustinvanstee/mldl-101.git && \
  cd /dl-labs/mldl-101/lab4-yolo-keras/model_data && wget https://github.com/dustinvanstee/mldl-101/releases/download/v1.0/yolo_power.h5 -O yolo.h5


# Note, this may override tf 1.8!!
RUN /root/anaconda3/bin/conda install jupyter && \
    /root/anaconda3/bin/conda install keras

#&& \
#  /opt/DL/tensorflow/bin/install_dependencies && \
#  /root/anaconda3/bin/conda install -c conda-forge opencv

RUN chown -R pwrai:pwrai /dl-labs

LABEL VERSION="V1.3"

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
RUN chmod 744 /etc/rc.local
EXPOSE 5050

COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


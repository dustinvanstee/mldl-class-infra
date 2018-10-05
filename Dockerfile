FROM ibmcom/powerai
RUN apt-get -y install git

# Simple utilities(cmt)
COPY motd /etc/motd
COPY motd /etc/powerai_help.txt

USER root
RUN mkdir -p /dl-labs  && cd /dl-labs && \
  git clone https://github.com/dustinvanstee/mldl-101.git && \
  wget http://apache.claz.org/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.7.tgz && \
  tar -zxvf spark-2.1.2-bin-hadoop2.7.tgz && \
  cd /dl-labs/mldl-101/lab4-yolo-keras/model_data && wget https://github.com/dustinvanstee/mldl-101/releases/download/v1.0/yolo_power.h5 -O yolo.h5



#add NIMBIX application
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate


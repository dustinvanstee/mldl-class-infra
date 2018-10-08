#!/bin/bash
#echo "Pre Env"
#which conda
#env
source /home/pwrai/.bashrc
source /home/pwrai/.profile
source /opt/DL/tensorflow/bin/tensorflow-activate
#echo "Post Env"
#env

CUDA_VERSION_JS=cuda-9.2
FILE=/usr/local/$CUDA_VERSION_JS/targets/ppc64le-linux/lib/stubs/libcuda.so.1
if [ -f $FILE ]; then
   echo "File $FILE exists. Doing nothing, must be on a GPU box"
else
   echo "File $FILE does not exist. Must be on a CPU box .."
   echo linking....
   ln -fs  /usr/local/$CUDA_VERSION_JS/targets/ppc64le-linux/lib/stubs/libcuda.so $FILE  
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/$CUDA_VERSION_JS/targets/ppc64le-linux/lib/stubs/
fi

cd /dl-labs/mldl-101
jupyter notebook --ip=0.0.0.0 --allow-root --port=5050 --no-browser --config /dl-labs/.jupyter/jupyter_notebook_config.json

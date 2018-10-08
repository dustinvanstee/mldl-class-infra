#!/bin/bash
echo "Pre Env"
env
source /home/pwrai/.bashrc
source /home/pwrai/.profile
source /opt/DL/tensorflow/bin/tensorflow-activate
echo "Post Env"
env
cd /dl-labs/mldl-101
jupyter notebook --ip=0.0.0.0 --allow-root --port=5050 --no-browser --config /dl-labs/.jupyter/jupyter_notebook_config.json

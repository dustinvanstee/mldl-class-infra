#!/bin/bash
source /root/yololab_env/bin/activate
cd /dl-labs/mldl-101
sudo git pull origin master
sudo jupyter notebook --ip=0.0.0.0 --allow-root --port=5050 --no-browser --config /dl-labs/.jupyter/jupyter_notebook_config.json

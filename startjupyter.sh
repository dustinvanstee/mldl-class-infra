#!/bin/bash
source /root/python3_env/bin/activate
cd /dl-labs/mldl-101
git pull origin master
nohup jupyter notebook --ip=0.0.0.0 --allow-root --port=5050 --no-browser

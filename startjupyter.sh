#!/bin/bash
jupyter notebook --ip=0.0.0.0 --allow-root --port=5050 > >(tee -a /tmp/tensorflow.stdout.log) 2> >(tee -a /tmp/tensorflow.log >&2) &
tensorboard --logdir=/data/mldl-101/graphs &

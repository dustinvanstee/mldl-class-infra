#!/bin/bash
jupyter notebook --ip=0.0.0.0 --allow-root --port=5050 | tee /tmp/tensorflow.log

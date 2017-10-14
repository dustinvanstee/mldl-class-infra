#!/bin/bash

GPU_MODE=1

cd /home/nimbix
git clone https://github.com/dustinvanstee/mldl-101.git
chown -R nimbix:nimbix mldl-101

cd /home/nimbix/mldl-101
source startClass2.sh -g $GPU_MODE

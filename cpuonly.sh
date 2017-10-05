source setup_powerai_env.sh
ln -fs /usr/local/cuda-8.0/targets/ppc64le-linux/lib/stubs/libcuda.so /usr/local/cuda-8.0/targets/ppc64le-linux/lib/stubs/libcuda.so.1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-8.0/targets/ppc64le-linux/lib/stubs/

#!/bin/bash
set -e

BUILDDIR=/dev/shm

export BUILD_PYTHON=True
export BUILD_BINARY=ON
export BUILD_CUSTOM_PROTOBUF=ON
export BUILD_DOCS=OFF
export BUILD_CAFFE2_OPS=ON
export BUILD_SHARED_LIBS=ON
export BUILD_TEST=False
export BUILD_JNI=OFF
export USE_CUDA=ON
export USE_CUDNN=ON
export USE_FFMPEG=ON
export USE_GFLAGS=ON
export USE_GLOG=ON
export USE_NUMPY=ON
export USE_OPENCL=OFF
export USE_OPENCV=ON
export USE_FBGEMM=OFF
export USE_FAKELOWP=OFF
export USE_NCCL=OFF
export USE_NNPACK=ON
export USE_QNNPACK=OFF
export USE_PYTORCH_QNNPACK=OFF
export PYTORCH_BUILD_VERSION="1.6.0"
export PYTORCH_BUILD_NUMBER=1
export CPPFLAGS="-D_FORTIFY_SOURCE=2"
export CFLAGS="-O2 -pipe -fstack-protector-strong -fno-plt"
export CXXFLAGS="-O2 -pipe -fstack-protector-strong -fno-plt"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"

sudo apt update
sudo apt install -y \
    nvidia-jetpack libgflags-dev libgoogle-glog-dev libnuma-dev libopenblas-dev libatlas-base-dev liblapack-dev libopenmpi-dev \
    libavcodec-dev libavformat-dev libavdevice-dev libavfilter-dev libavresample-dev libavutil-dev libpostproc-dev libswresample-dev libswscale-dev

if [ -f /home/.repository/pip/torch-$PYTORCH_BUILD_VERSION-*-linux_aarch64.whl ]; then
    wget https://raw.githubusercontent.com/pytorch/pytorch/master/requirements.txt -O $BUILDDIR/requirements.txt
    pip install --user --no-binary :all: -r $BUILDDIR/requirements.txt
    pip install --user /home/.repository/pip/torch-$PYTORCH_BUILD_VERSION-*-linux_aarch64.whl
    exit 0
fi

cd $BUILDDIR
if [ -d pytorch ]; then
    sudo rm -rf pytorch
fi

git clone https://github.com/pytorch/pytorch.git -b v$PYTORCH_BUILD_VERSION
cd pytorch
git submodule update --init --recursive
pip install --no-binary :all: meson ninja
pip install --no-binary :all: -r requirements.txt
TORCH_CUDA_ARCH_LIST="6.2" python setup.py bdist_wheel
sudo mkdir -p /home/.repository/pip
sudo cp dist/*.whl /home/.repository/pip
pip install --user /home/.repository/pip/torch-$PYTORCH_BUILD_VERSION-*-linux_aarch64.whl

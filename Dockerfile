# Set the base image
ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION}

# Set versions
ARG DPCPP_VER=2023.2.1-16
ARG MKL_VER=2023.2.0-49495
ARG CMPLR_COMMON_VER=2023.2.1
ARG ICD_VER=23.17.26241.33-647~22.04
ARG LEVEL_ZERO_GPU_VER=1.3.26241.33-647~22.04
ARG LEVEL_ZERO_VER=1.11.0-647~22.04
ARG LEVEL_ZERO_DEV_VER=1.11.0-647~22.04
ARG DEVICE=flex
ARG PYTHON=python3.11

RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    ca-certificates \
    gnupg2 \
    gpg-agent \
    unzip \
    wget \   
    git \
    build-essential \
    cmake \
    git-lfs \
    curl \
    libjpeg-dev libpng-dev && apt-get clean

# Add Intel repositories
# oneAPI packages
RUN no_proxy=$no_proxy wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
   | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
   | tee /etc/apt/sources.list.d/oneAPI.list

# Prepare Intel Graphics driver index
RUN no_proxy=$no_proxy wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | \
    gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
RUN printf 'deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy %s\n' "$DEVICE" | \
    tee /etc/apt/sources.list.d/intel.gpu.jammy.list

RUN apt-get update
RUN apt-get install -y --no-install-recommends --fix-missing \ 
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    libjemalloc-dev \
    python3-venv \
    numactl \
    opencl-headers \
    clblast-utils \
    intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
    libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
    libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
    mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo hwinfo clinfo xpu-smi \
    intel-oneapi-runtime-dpcpp-cpp intel-oneapi-runtime-mkl intel-opencl-icd intel-oneapi-compiler-shared-common-${CMPLR_COMMON_VER} \
    intel-level-zero-gpu level-zero level-zero-dev && \ 
    apt-get clean

# intel-basekit

#  intel-oneapi-runtime-dpcpp-cpp=${DPCPP_VER} \
#     intel-oneapi-runtime-mkl=${MKL_VER} \
#     intel-oneapi-compiler-shared-common-${CMPLR_COMMON_VER}=${DPCPP_VER} \
#     intel-opencl-icd=${ICD_VER} \
#     intel-level-zero-gpu=${LEVEL_ZERO_GPU_VER} \
#     level-zero=${LEVEL_ZERO_VER} \
#     level-zero-dev=${LEVEL_ZERO_DEV_VER} \


RUN echo "source /opt/intel/oneapi/setvars.sh" >> /root/.bashrc

# Set environment variables
ENV venv_dir=/deps/venv
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so
ENV NEOReadDebugKeys=1
ENV ClDeviceGlobalMemSizeAvailablePercent=100
ENV LD_LIBRARY_PATH=/opt/intel/oneapi/lib:/opt/intel/oneapi/lib/intel64

#llama.cpp variables
ENV GGML_OPENCL_PLATFORM=Intel
ENV GGML_OPENCL_DEVICE=0



# RUN apt-get install -y ${PYTHON} lib${PYTHON} python3-pip && apt-get clean
# # Install Python, update pip and setuptools, create symbolic links for Python
# RUN pip --no-cache-dir install --upgrade \
#     pip \
#     setuptools && \
#     ln -sf $(which ${PYTHON}) /usr/local/bin/python && \
#     ln -sf $(which ${PYTHON}) /usr/local/bin/python3 && \
#     ln -sf $(which ${PYTHON}) /usr/bin/python && \
#     ln -sf $(which ${PYTHON}) /usr/bin/python3


# # Install Torch and llama-cpp-python
# RUN python -m pip install torch==2.0.1a0 torchvision==0.15.2a0 intel_extension_for_pytorch==2.0.110+xpu --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ && \
#     CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 pip install llama-cpp-python  --force-reinstall --upgrade --no-cache-dir



# Define volumes and working directory
VOLUME [ "/deps" ]
VOLUME [ "/apps" ]
VOLUME [ "/root/.cache/huggingface" ]
WORKDIR /apps

# Define entrypoint
ENTRYPOINT ["/bin/bash"]
#CMD [""]

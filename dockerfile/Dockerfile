
ARG CUDA_VERSION
ARG CUDNN_VERSION
ARG OS_VERSION
# 注意conda python 环境、tensorrt、pytorch的版本仍需要适配

FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu${OS_VERSION}

# setup timezone
ENV TZ=US/Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub

# Install requried libraries
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    wget \
    zlib1g-dev \
    git \
    sudo \
    ssh \
    libssl-dev \
    pbzip2 \
    pv \
    bzip2 \
    unzip \
    devscripts \
    lintian \
    fakeroot \
    dh-make \
    build-essential \
    curl \
    ca-certificates \
    libx11-6 \
    nano \
    graphviz \
    libgl1-mesa-glx \
    openssh-server \
    apt-transport-https

# Install other dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    libcanberra-gtk-module \
    libsm6 libxext6 libxrender-dev \
    libgtk2.0-dev pkg-config \
    libopenmpi-dev \
 && sudo rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-py38_4.12.0-Linux-x86_64.sh -b \
    && rm -f Miniconda3-py38_4.12.0-Linux-x86_64.sh

ENV CONDA_DEFAULT_ENV=open-mmlab
ENV CONDA_PREFIX=/root/miniconda3/envs/$CONDA_DEFAULT_ENV
ENV PATH=/root/miniconda3/bin:$CONDA_PREFIX/bin:$PATH
RUN conda init && conda create -n open-mmlab python=3.8 -y

RUN alias python='/root/miniconda3/envs/open-mmlab/bin/python3.8'

# Set environment and working directory
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$CUDA_HOME/extras/CUPTI/lib64/:$LD_LIBRARY_PATH
ENV PATH=$CUDA_HOME/bin:$PATH
ENV CFLAGS="-I$CUDA_HOME/include $CFLAGS"
ENV FORCE_CUDA="1"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# 安装pytorch 
RUN python -m pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

# install opencv
RUN python -m pip install opencv-python==4.5.5.62

# install gcc
RUN conda install -c omgarcia gcc-6

# install torchpack
RUN git clone https://gitee.com/aviana-zheng/torchpack
RUN cd torchpack && python -m pip install -e .

# install other dependencies
RUN python -m pip install mmcv-full==1.4.0 -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.9.0/index.html
RUN python -m pip install pillow==8.4.0 \
                          tqdm \
                          mmdet==2.14.0 \
                          mmsegmentation==0.14.1 \
                          numba \
                          mpi4py \
                          nuscenes-devkit \
                          setuptools==59.5.0

# install mmdetection3d from source
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://gitee.com/aviana-zheng/mmdetection3d && \
    cd mmdetection3d && git checkout v0.17.1 && \
    python -m pip install -r requirements/build.txt && \
    python -m pip install --no-cache-dir -e .

# install timm
RUN python -m pip install einops fvcore seaborn iopath==0.1.9 timm==0.6.13  typing-extensions==4.5.0 pylint ipython==8.12  \
    numpy==1.19.5 matplotlib==3.5.2 numba==0.48.0 pandas==1.4.4 scikit-image==0.19.3 setuptools==59.5.0 \
    && python -m pip install 'git+https://gitee.com/aviana-zheng/detectron2'

RUN rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]
# SSH服务相关
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]

#shell color style setting 
ENV TERM=xterm-256color
ENV force_color_prompt=yes
RUN echo 'export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$"' \
            >> /etc/bash.bashrc && \
    echo "export GREP_OPTIONS='--color=auto'" >> /etc/bash.bashrc && \
    echo "export GREP_COLOR='1;35'" >> /etc/bash.bashrc && \
    echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_mb=$'\E[01;31m'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_md=$'\E[01;31m'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_me=$'\E[0m'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_se=$'\E[0m'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_so=$'\E[01;44;33m'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_ue=$'\E[0m'" >> /etc/bash.bashrc && \
    echo "export LESS_TERMCAP_us=$'\E[01;32m'" >> /etc/bash.bashrc

RUN python -m pip uninstall yapf -y && python -m pip install yapf==0.40.1

SHELL ["/bin/bash", "-c"]

WORKDIR /root/BEVFormer
USER root
RUN ["/bin/bash"]

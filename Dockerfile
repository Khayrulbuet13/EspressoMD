FROM ubuntu:20.04
MAINTAINER Khayrul Islam (Khayrulbuet13@gmail.com)

# Install Python
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ="America/New_York" apt-get -y install tzdata \
    && apt-get install -y python3.8 \
    && ln -s /usr/bin/python3.8 /usr/bin/python3
RUN apt-get install -y python3-pip git vim
RUN apt-get install -y build-essential cmake cython3 \
    && pip install --user numpy==1.19 \
    && apt-get install -y libboost-all-dev openmpi-common fftw3-dev libhdf5-dev libhdf5-openmpi-dev \
    python3-opengl libgsl-dev \
    && pip install --user MDAnalysis==2.2 MDAnalysisTests==2.2 scipy==1.9 pandas==1.5 \
    && apt-get -y install nvidia-cuda-toolkit

RUN useradd -rm -d /home/espresso -s /bin/bash -g root -G sudo -u 1001 espresso
USER espresso
WORKDIR /home/espresso
RUN git clone https://github.com/Khayrulbuet13/EspressoMD.git

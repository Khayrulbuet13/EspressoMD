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
    python3-scipy python3-opengl libgsl-dev \
    && pip install --user MDAnalysis==2.2 MDAnalysisTests==2.2 pandas==1.4 \
    && apt-get -y install nvidia-cuda-toolkit

RUN useradd -rm -d /home/espresso -s /bin/bash -g root -G sudo -u 1001 espresso
USER espresso
WORKDIR /home/espresso
RUN git clone https://github.com/Khayrulbuet13/EspressoMD.git
# compile EspressoMD
RUN cd EspressoMD/EspressoMD-4.1.4/Liposome_build && \
    cmake .. -DCMAKE_C_COMPILER=$(which gcc-8) -DMAKE_C_COMPILER=$(which gcc-8) -DCMAKE_CXX_COMPILER=$(which g++-8) -DGMX_GPU=CUDA -DGMX_MPI=ON -D WITH_HDF5=ON && \
    rm myconfig-sample.hpp && \
    cmake .. -DCMAKE_C_COMPILER=$(which gcc-8) -DMAKE_C_COMPILER=$(which gcc-8) -DCMAKE_CXX_COMPILER=$(which g++-8) -DGMX_GPU=CUDA -DGMX_MPI=ON -D WITH_HDF5=ON && \
    make -j $(nproc)
    
RUN cd EspressoMD/EspressoMD-4.1.2/RBC_build && \
    cmake .. -DCMAKE_C_COMPILER=$(which gcc-8) -DMAKE_C_COMPILER=$(which gcc-8) -DCMAKE_CXX_COMPILER=$(which g++-8) -DGMX_GPU=CUDA -DGMX_MPI=ON -D WITH_HDF5=OFF && \
    rm myconfig-sample.hpp && \
    cmake .. -DCMAKE_C_COMPILER=$(which gcc-8) -DMAKE_C_COMPILER=$(which gcc-8) -DCMAKE_CXX_COMPILER=$(which g++-8) -DGMX_GPU=CUDA -DGMX_MPI=ON -D WITH_HDF5=OFF && \
    make -j $(nproc)

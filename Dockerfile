FROM khayrulbuet13/espressomd_cuda:cuda10.1_base

# clone Espressomd from github
RUN git clone https://github.com/Khayrulbuet13/EspressoMD.git
RUN /EspressoMD-4.1.4/Liposome_build/cmake .. && /EspressoMD-4.1.2/RBC_build/cmake ..

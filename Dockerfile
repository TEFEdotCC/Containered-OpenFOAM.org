FROM fedora:32
LABEL author "Thomas Enzinger <info@tefe.cc>"

ARG BUILD_DATE
ARG SOURCE_COMMIT
ARG DOCKERFILE_PATH
ARG SOURCE_TYPE

ARG OPENFOAM_GIT_URL
ARG OPENFOAM_VERSION
ARG OPENFOAM_THIRDPARTY_GIT_URL
ARG OPENFOAM_GIT_BRANCH
ARG OPENFOAM_THIRDPARTY_GIT_BRANCH

RUN echo "export BUILD_DATE=${BUILD_DATE}" >> /etc/profile.d/buildenv.sh \
 && echo "export SOURCE_COMMIT=${SOURCE_COMMIT}" >> /etc/profile.d/buildenv.sh \
 && echo "export DOCKERFILE_PATH=${DOCKERFILE_PATH}" >> /etc/profile.d/buildenv.sh \
 && echo "export OPENFOAM_GIT_URL=${OPENFOAM_GIT_URL}" >> /etc/profile.d/buildenv.sh \
 && echo "export OPENFOAM_VERSION=${OPENFOAM_VERSION}" >> /etc/profile.d/buildenv.sh \
 && echo "export OPENFOAM_THIRDPARTY_GIT_URL=${OPENFOAM_THIRDPARTY_GIT_URL}" >> /etc/profile.d/buildenv.sh \
 && echo "export OPENFOAM_GIT_BRANCH=${OPENFOAM_GIT_BRANCH}" >> /etc/profile.d/buildenv.sh \
 && echo "export OPENFOAM_THIRDPARTY_GIT_BRANCH=${OPENFOAM_THIRDPARTY_GIT_BRANCH}" >> /etc/profile.d/buildenv.sh \
 && chmod +x /etc/profile.d/buildenv.sh


# install software
RUN dnf update -y && dnf upgrade -y                                                         \
 && dnf group install -y "Development Tools"                                                \
 && dnf install -y                                                                          \
      sudo curl wget git nano grep                                                          \
      bash bash-completion                                                                  \
      glibc-locale-source langpacks-en langpacks-de                                         \
      autoconf cmake gawk gnuplot                                                           \
      clang perl kernel-headers                                                             \
      flex bison zlib zlib-devel bc m4 diffutils                                            \
      boost-devel vtk vtk-devel                                                             \
      libjpeg libpng hdf5-devel zeromq blosc bzip2 zfp grads libfabric                      \
      openmpi-devel openmpi readline-devel                                                  \
      python python3 python3-pip                                                            \
      boost-openmpi-python3-devel boost-python3-devel python3-devel                         \
      python3-numpy python3-scipy python3-matplotlib python3-pandas python3-sympy           \
      CGAL-devel fftw-devel                                                                 \
      eigen3-devel libxml2-devel                                                            \
      scons valgrind-devel blas-devel openblas-devel gcc-gfortran                           \
      metis-devel scotch scotch-devel                                                       \
      ptscotch-openmpi ptscotch-openmpi-devel ptscotch-openmpi-devel-parmetis               \
      petsc petsc-devel petsc-openmpi petsc-openmpi-devel                                   \
 && dnf clean all && rm -rf /usr/share/man/* /tmp/* /var/cache/dnf/*

ENV TZ=Europe/Berlin
ENV LANG=de_DE.UTF-8
ENV LC_COLLATE=de_DE.UTF-8
ENV LC_CTYPE=de_DE.UTF-8
ENV LC_NUMERIC=de_DE.UTF-8
ENV LC_TIME=de_DE.UTF-8
ENV LC_MESSAGES=de_DE.UTF-8

RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime                                 \
 && echo $TZ > /etc/timezone                                                                \
 && echo "$LANG UTF-8" >> /etc/locale.gen                                                   \
 && echo "LANG=$LANG" >> /etc/locale.conf                                                   \
 && echo "LC_COLLATE=$LC_COLLATE" >> /etc/locale.conf                                       \
 && echo "LC_CTYPE=$LC_CTYPE" >> /etc/locale.conf                                           \
 && echo "LC_NUMERIC=$LC_NUMERIC" >> /etc/locale.conf                                       \
 && echo "LC_TIME=$LC_TIME" >> /etc/locale.conf                                             \
 && echo "LC_MESSAGES=$LC_MESSAGES" >> /etc/locale.conf

# setup path's
RUN echo 'export PATH=$PATH:/usr/lib64/openmpi/bin' >> /etc/profile.d/openfoam.sh           \
 && echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64:/usr/local/lib64:/usr/lib64/openmpi/lib' >> /etc/profile.d/openfoam.sh \
 && echo 'export OMPI_MCA_btl_vader_single_copy_mechanism=none' >> /etc/profile.d/openfoam.sh \
 && echo 'export WM_NCOMPPROCS=$(grep -c ^processor /proc/cpuinfo)' >> /etc/profile.d/openfoam.sh \
 && chmod +x /etc/profile.d/openfoam.sh

# config os
RUN groupadd foam && useradd -m -s /bin/bash -g foam -G wheel foam                          \
 && echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers                                      \
 && echo 127.0.1.1 dockerhost >> /etc/hosts                                                 \
 && echo 'include /usr/share/nano/*' >> /home/foam/.nanorc

SHELL ["/bin/bash", "-c"]

#
COPY scripts /opt/scripts
RUN /opt/scripts/install/preCICE > /opt/log.preCICE
RUN /opt/scripts/install/openfoam > /opt/log.openfoam
RUN /opt/scripts/install/preCICE-openfoam > /opt/log.preCICE-openfoam
RUN rm -rf rm /opt/scripts && rm -f /opt/log.*

#
VOLUME ["/data"]
WORKDIR /data
USER foam

#
ENTRYPOINT ["/bin/bash", "-ci"]

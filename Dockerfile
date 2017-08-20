FROM crystallang/crystal:0.23.1

RUN apt-get update
RUN apt-get install -qy git zsh build-essential tmux ca-certificates ruby curl \
  build-essential libtool automake autoconf \
  make \
  gcc-arm-none-eabi \
  binutils-arm-none-eabi \
  gdb-arm-none-eabi \
  libstdc++-arm-none-eabi-newlib \
  libnewlib-arm-none-eabi \
  qemu-system-arm

RUN mkdir -p /opt
WORKDIR /opt

RUN git clone https://github.com/ivmai/bdwgc.git && \
  cd bdwgc && \
  git clone https://github.com/ivmai/libatomic_ops.git && \
  autoreconf -vif && \
  automake --add-missing && \
  ./configure && \
  make && \
  make check && \
  make install

RUN git clone https://github.com/crystal-lang/crystal.git crystal-llvm

RUN apt-get install -qy llvm

RUN cd /opt/crystal-llvm && make

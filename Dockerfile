FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y build-essential clang bison flex libreadline-dev \
                       gawk tcl-dev libffi-dev git mercurial graphviz   \
                       xdot pkg-config python python3 libftdi-dev gperf \
                       libboost-program-options-dev autoconf libgmp-dev \
                      cmake

RUN git clone https://github.com/cliffordwolf/yosys.git yosys
RUN cd yosys && make -j$(nproc) && make install

RUN git clone https://github.com/cliffordwolf/SymbiYosys.git SymbiYosys
RUN cd SymbiYosys && make install

RUN git clone https://github.com/SRI-CSL/yices2.git yices2
RUN cd yices2 && autoconf && ./configure && make -j$(nproc) && make install

RUN git clone https://github.com/Z3Prover/z3.git z3
RUN cd z3 && python scripts/mk_make.py && cd build && make -j$(nproc) && make install

RUN apt-get install -y wget
RUN wget https://downloads.bvsrc.org/super_prove/super_prove-hwmcc17_final-2-d7b71160dddb-Ubuntu_14.04-Release.tar.gz
RUN tar -xvf super_prove-hwmcc17_final-2-d7b71160dddb-Ubuntu_14.04-Release.tar.gz -C /usr/local

RUN echo '#!/bin/bash \
tool=super_prove; if [ "$1" != "${1#+}" ]; then tool="${1#+}"; shift; fi \
exec /usr/local/super_prove/bin/${tool}.sh "$@"' > /usr/local/bin/suprove

RUN git clone https://bitbucket.org/arieg/extavy.git
RUN cd extavy && git submodule update --init && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc) && cp avy/src/avy /usr/local/bin/ && avy/src/avybmc /usr/local/bin/

RUN git clone https://github.com/boolector/boolector
RUN cd boolector && ./contrib/setup-btor2tools.sh && ./contrib/setup-lingeling.sh && ./configure.sh && make -C build -j$(nproc) && cp build/bin/{boolector,btor*} /usr/local/bin/ && cp deps/btor2tools/bin/btorsim /usr/local/bin/
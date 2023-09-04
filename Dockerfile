FROM ubuntu:20.04

RUN 	apt-get -qq update \
	&& apt-get install -qqy wget \
	&& echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal main\ndeb-src http://apt.llvm.org/focal/ llvm-toolchain-focal main" > /etc/apt/sources.list.d/llvm.list \
	&& wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
	&& apt-get -qq update \
	&& apt-get install -qqy clang-tidy-18 \
	&& DEBIAN_FRONTEND=noninteractive TZ=Asia/Kolkata apt-get install -qqy \
        	sudo git build-essential make \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

RUN 	mkdir /arm \
	&&  mkdir /tmp/12.3.1 \
	&& cd /tmp/12.3.1 \
	&& wget 'https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz' \
	&& tar -xf *.tar.xz \
	&& rm -f *.tar.xz \
	&& mv * /arm/12.3.1 \
	&& mkdir /tmp/arm-8.2.1 \
	&& cd /tmp/arm-8.2.1 \
	&& wget 'https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2' \
	&& tar -xf *.tar.bz2 \
	&& rm -f *.tar.bz2 \
	&& mv * /arm/8.2.1 \
	&& mkdir /tmp/arm-7.3.1 \
	&& cd /tmp/arm-7.3.1 \
	&& wget 'https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2' \
	&& tar -xf *.tar.bz2 \
	&& rm -f *.tar.bz2 \
	&& mv * /arm/7.3.1

RUN 	mkdir /opt/cmake \
	&& cd /opt/cmake \
	&& wget 'https://github.com/Kitware/CMake/releases/download/v3.27.3/cmake-3.27.3-linux-x86_64.sh' \
	&& bash cmake-3.27.3-linux-x86_64.sh --prefix=/usr/local/ --skip-license \
	&& rm -f cmake-3.27.3-linux-x86_64.sh

RUN 	mkdir /opt/llvm \
	&& cd /opt/llvm \
	&& git clone --depth=1 https://github.com/llvm/llvm-project llvm-project \
	&& cd /opt/llvm/llvm-project \
	&& mkdir build \
	&& cd /opt/llvm/llvm-project/build \
	&& cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=lld -DCMAKE_INSTALL_PREFIX=/usr/local ../llvm \
	&& make -j$(nproc) \
	&& make install \
	&& cd / \
	&& rm -rf /opt/llvm/*

ARG USER=ubuntu

RUN 	useradd -m $USER \
	&& echo "$USER:$USER" | chpasswd \
	&& adduser $USER sudo \
	&& mkdir -p /etc/sudoers.d \
        && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER

USER $USER

WORKDIR /app

ENTRYPOINT ["tail", "-f", "/dev/null"]

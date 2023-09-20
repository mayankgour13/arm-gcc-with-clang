FROM ubuntu:20.04

RUN 	apt-get -qq update \
	&& apt-get install -qqy wget software-properties-common \
	&& add-apt-repository ppa:ubuntu-toolchain-r/test \
	&& wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
	&& apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' \
	&& echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal main\ndeb-src http://apt.llvm.org/focal/ llvm-toolchain-focal main" > /etc/apt/sources.list.d/llvm.list \
	&& wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
	&& apt-get -qq update \
	&& DEBIAN_FRONTEND=noninteractive TZ=Asia/Kolkata apt-get install -qqy \
        	sudo gcc-11 g++-11 git make clang-tidy-18 lld-18 clang-18 llvm-18 gcovr cmake \
	&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11 --slave /usr/bin/g++ g++ /usr/bin/g++-11 \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

#RUN 	mkdir /opt/cmake \
#	&& cd /opt/cmake \
#	&& wget 'https://github.com/Kitware/CMake/releases/download/v3.27.3/cmake-3.27.3-linux-x86_64.sh' \
#	&& bash cmake-3.27.3-linux-x86_64.sh --prefix=/usr/local/ --skip-license \
#	&& rm -f cmake-3.27.3-linux-x86_64.sh

RUN 	mkdir /arm \
	&&  mkdir /tmp/12.3.1 \
	&& cd /tmp/12.3.1 \
	&& wget 'https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/12.3.rel1/binrel/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz' \
	&& tar -xf *.tar.xz \
	&& rm -f *.tar.xz \
	&& mv * /arm/12.3.1 \
	&& ln -s /arm/12.3.1 /arm/default

ENV PATH="${PATH}:/arm/12.3.1/bin"
	
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

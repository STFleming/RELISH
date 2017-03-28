FROM ubuntu:14.04
MAINTAINER Shane T. Fleming <sf306@ic.ac.uk>

#	    ____  ________    _________ __  __
#	   / __ \/ ____/ /   /  _/ ___// / / /
#	  / /_/ / __/ / /    / / \__ \/ /_/ / 
#	 / _, _/ /___/ /____/ / ___/ / __  /  
#	/_/ |_/_____/_____/___//____/_/ /_/   
#		created by Shane T. Fleming
                                      

RUN dpkg --add-architecture i386

RUN apt-get -y update

RUN echo 'mysql-server mysql-server/root_password password shiny' | debconf-set-selections 
RUN echo 'mysql-server mysql-server/root_password_again password shiny' | debconf-set-selections 

RUN apt-get -y install git tcl8.5-dev dejagnu expect texinfo build-essential \
    liblpsolve55-dev libgmp3-dev automake libtool clang-3.5 libmysqlclient-dev \
    qemu-system-arm qemu-system-mips gcc-4.8-plugin-dev libc6-dev-i386 meld \
    libqt4-dev libgraphviz-dev libfreetype6-dev buildbot-slave vim gitk kdiff3 \
    clang-3.5 openssh-server mysql-server python3-mysql.connector python3-serial \
    python3-pyqt5 libxft2

RUN apt-get -y install libc6-i386 libXi6:i386 \
    libpng12-dev:i386 libfreetype6-dev:i386 libfontconfig1:i386 libxft2:i386 \
    libncurses5:i386 libsm6:i386 libxtst6:i386

RUN apt-get -y install git tcl8.5-dev dejagnu expect texinfo build-essential \
    liblpsolve55-dev libgmp3-dev automake libtool clang-3.5 libmysqlclient-dev \
    qemu-system-arm qemu-system-mips gcc-4.8-plugin-dev libc6-dev-i386 libqt4-dev \
    libfreetype6-dev

RUN wget http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gxemul/gxemul-doc_0.4.7.2-1_all.deb 
RUN dpkg -i gxemul-doc_0.4.7.2-1_all.deb

#Create the relish user and give it root access
RUN useradd -m relish && \
    echo relish:relish | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'relish  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers

ADD . /home/relish/
RUN wget http://legup.eecg.utoronto.ca/releases/legup-4.0.tar.gz
RUN tar -xvf legup-4.0.tar.gz -C /home/relish/ 
RUN chown -R relish:relish /home/relish/* 

USER relish
WORKDIR /home/relish

#RUN sed -i -r -e "s/CONFIG\s+\+= debug_and_release display_graphs/CONFIG \+= debug_and_release #display_graphs/g" legup-4.0/gui/scheduleviewer/scheduleviewer.pro

#TODO: Temp fix, remove some things that were causing problems in build flow
RUN sed -i '/pcie/d' /home/relish/legup-4.0/Makefile
RUN sed -i '/gui/d' /home/relish/legup-4.0/Makefile

#Applying patches for Xilinx RAM fixes, some of them are homemade and dirty
RUN wget http://legup.eecg.utoronto.ca/docs/4.0/_downloads/legup-4.0-to-319115.patch
RUN cp legup-4.0-to-319115.patch /home/relish/legup-4.0/
RUN (cd /home/relish/legup-4.0 && patch -p1 < legup-4.0-to-319115.patch)
RUN cp ./config/xilinx_dirty_RAM_patch.patch /home/relish/legup-4.0/llvm/lib/Target/Verilog/
RUN (cd /home/relish/legup-4.0/llvm/lib/Target/Verilog && patch < xilinx_dirty_RAM_patch.patch)

RUN (cd /home/relish/legup-4.0 && make)

 
USER root
RUN apt-get -y install doxygen
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y update
RUN apt-get -y install gcc-4.9 g++-4.9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
USER relish

RUN ./patch /home/relish/legup-4.0

RUN echo "echo \"    ____  ________    _________ __  __   \""  >> /home/relish/.bashrc
RUN echo "echo \"   / __ \\/ ____/ /   /  _/ ___// / / /  \"" >> /home/relish/.bashrc  
RUN echo "echo \"  / /_/ / __/ / /    / / \\__ \\/ /_/ /  \"" >> /home/relish/.bashrc
RUN echo "echo \" / _, _/ /___/ /____/ / ___/ / __  /     \"" >> /home/relish/.bashrc
RUN echo "echo \"/_/ |_/_____/_____/___//____/_/ /_/      \"" >> /home/relish/.bashrc 
RUN echo "echo \"                                         \"" >> /home/relish/.bashrc

RUN cp /home/relish/legup-4.0/ip/QSYS_setup/legup_components.ipx /home/relish/legup-4.0/boards/

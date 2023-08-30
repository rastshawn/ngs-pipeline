FROM ubuntu:22.04

ENTRYPOINT ["bash", "/root/pipeline.sh"]

# install base components: java, R, samtools 1.10 using htslib 1.10.2, bamtools 2.5.1 
RUN apt update && \
    apt install -y zip openjdk-19-jre-headless unzip bzip2 python3 python-is-python3

COPY downloads-to-install/ /root/setup/downloads-to-install/

RUN cd /root/setup/downloads-to-install && \
	./installfile-cleanup.sh

# unzip bowtie2 and add to path
RUN cd /root/setup/downloads-to-install/bowtie2 && \
    unzip *.zip && \
    cd $(ls -d */|head -n 1)  && \
    bash -l -c 'echo export PATH=$PATH:$(pwd) >> /etc/bash.bashrc'


# rename picard version jar to "picard.jar" and add to path
RUN cd /root/setup/downloads-to-install/picard && \
    cp $(ls *.jar |head -n 1) ~/picard.jar 

# compile and install samtools
RUN apt update && \
    apt install -y libbz2-dev build-essential libncurses-dev zlib1g-dev liblzma-dev libcurl4-openssl-dev libssl-dev
    
RUN cd /root/setup/downloads-to-install/samtools && \
    tar -xf $(ls *.bz2 |head -n 1) && \
    cd $(ls -d */|head -n 1) && \
    ./configure --enable-plugins --enable-libcurl --enable-s3 --with-htslib=$PWD/$(ls -d htslib* | head -n 1) && \
    make all && \
    make install

# add pip to the container for convenience
RUN apt update && apt install -y wget
RUN cd /root/setup && mkdir python && cd python && \
	wget https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py

# add lofreq to the container
RUN apt update &&  apt install -y bcftools
RUN cd /root/setup/downloads-to-install/lofreq && \
	tar -xf $(ls *.tgz | head -n 1) && \
	cp -rf ./$(ls -d lofreq*/ | head -n 1)* /usr/local

# compile and install bamtools
RUN apt update && apt install -y cmake
RUN cd /root/setup/downloads-to-install/bamtools && \
    mkdir stage && \
    tar -xf $(ls *.tar.gz |head -n 1) && \
    cd $(ls -d bamtools*/|head -n 1) && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/ .. && \
    make && make install

RUN apt remove -y libbz2-dev build-essential libncurses-dev zlib1g-dev liblzma-dev cmake

# # install R
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt update && \
    apt install -y --no-install-recommends tzdata wget software-properties-common dirmngr && \
    add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
      wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
      apt install -y --no-install-recommends r-base && \
      R -e "install.packages('BiocManager')" && R -e "BiocManager::install(version = '3.14')"
      


COPY pipeline.sh /root/pipeline.sh
RUN chmod 744 /root/pipeline.sh

COPY script.r /root/script.r
RUN chmod 744 /root/script.r

!/bin/bash

mainDir=$PWD
cd $mainDir


echo "Fetching bamtools 2.5.2 from https://github.com/pezmaster31/bamtools/archive/refs/tags/v2.5.2.tar.gz"
cd downloads-to-install/bamtools
curl -o v2.5.2.tar.gz https://github.com/pezmaster31/bamtools/archive/refs/tags/v2.5.2.tar.gz
cd $mainDir

echo "Fetching bowtie2 from https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.5.1/bowtie2-2.5.1-linux-x86_64.zip/download"
cd downloads-to-install/bowtie2
curl -o bowtie2-2.5.1-linux-x86_64.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.5.1/bowtie2-2.5.1-linux-x86_64.zip/download
cd $mainDir

echo "Fetching lofreq from https://github.com/CSB5/lofreq/raw/master/dist/lofreq_star-2.1.5_linux-x86-64.tgz"
cd downloads-to-install/lofreq
curl -o lofreq_star-2.1.5_linux-x86-64.tgz https://github.com/CSB5/lofreq/raw/master/dist/lofreq_star-2.1.5_linux-x86-64.tgz
cd $mainDir

echo "Fetching picard from https://github.com/broadinstitute/picard/releases/download/3.1.0/picard.jar"
cd downloads-to-install/picard
curl -o picard.jar https://github.com/broadinstitute/picard/releases/download/3.1.0/picard.jar
cd $mainDir

echo "Fetching samtools 1.18 from https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2"
cd downloads-to-install/samtools
curl -o samtools-1.18.tar.bz2 https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2
cd $mainDir

echo "The requirements should now be installed."
 

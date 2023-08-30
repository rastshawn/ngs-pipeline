#!/bin/bash

# make sure bowtie2 is in the path.
cd /root/setup/downloads-to-install/bowtie2 && \
    cd $(ls -d */|head -n 1)  && \
    export PATH=$PATH:$(pwd)

cd /root/

NAME=$1
DEBUG=$2

if [ -z "$NAME" ]; then
    echo -e "Specify a name by repeating your command, adding a space, then typing a name (ex: TYF5521)"
    exit 1
fi;

if [ ! -d input ]; then
    echo -e "No input directory is mapped to the container."
    exit 1
fi;
if [ ! -d output ]; then 
    echo -e "No output directory is mapped to the container."
    exit 1
fi;

cd output
numFiles=`ls -a | wc -l`
if [ $numFiles -ne 2 ];
then
	echo "ERROR: The output folder isn't empty! Make sure to either copy your work to a new folder or delete it. Check for hidden files, or delete the output folder and make a new one."
	exit 1;
else 
    rm -rf -- ..?* .[!.]* *
fi
cd ..



cd input
cp *.* ../output/
cd ../output


# delete all hidden files - https://unix.stackexchange.com/questions/77127/rm-rf-all-files-and-all-hidden-files-without-error
rm -rf -- ..?* .[!.]* 

numFiles=`ls -a | wc -l`
if [ $numFiles -ne 4 ];
then
	echo "ERROR: There were too many input files. There should only be one .fasta file and one .bam file - make sure the input folder is cleared of anything else, including hidden files."
	exit 1;
fi


inputFasta=$(ls *.fasta|head -n 1)
inputBam=$(ls *.bam|head -n 1)

declare -a commands=("bowtie2-build $inputFasta $NAME"
        "java -jar -Xmx3g /root/picard.jar SamToFastq -INPUT $inputBam -FASTQ _1.R1.fastq -SECOND_END_FASTQ _1.R2.fastq"
        "bowtie2 --very-sensitive-local -q -x ${NAME} -1 _1.R1.fastq -2 _1.R2.fastq -S ${NAME}_alignment.sam"
        "samtools view -b -o ${NAME}_alignment.bam ${NAME}_alignment.sam"
        "samtools sort -O bam -o ${NAME}_sort.bam -T ${NAME}_temp.nnnn.bam ${NAME}_alignment.bam"
        "bamtools coverage -in ${NAME}_sort.bam -out ${NAME}_precoverage.txt"
        "java -jar -Xmx3g /root/picard.jar SortSam -INPUT ${NAME}_sort.bam  -OUTPUT ${NAME}_coordinate.bam -SORT_ORDER coordinate -USE_JDK_DEFLATER true -USE_JDK_INFLATER true"
        "java -jar -Xmx3g /root/picard.jar MarkDuplicates -INPUT ${NAME}_coordinate.bam -OUTPUT ${NAME}_MarkDuplicates.bam -METRICS_FILE ${NAME}_MarkDuplicates.txt -OPTICAL_DUPLICATE_PIXEL_DISTANCE 0 -REMOVE_DUPLICATES true -USE_JDK_DEFLATER true -USE_JDK_INFLATER true"
        "samtools flagstat ${NAME}_MarkDuplicates.bam"
        "bamtools coverage -in ${NAME}_MarkDuplicates.bam -out ${NAME}_coverage.txt"
        "samtools index ${NAME}_MarkDuplicates.bam"
        "samtools faidx ${inputFasta}"
        "Rscript --vanilla /root/script.r ${NAME}"
)


#if [ -z "DEBUG" ]; then # If not in debug, just run the 
rm pipeline-log.txt
if [ -n "$DEBUG" ]; then #if in debug mode, save off each step
        mkdir zips
fi
i=1

for command in "${commands[@]}"
do

    echo "ngs-pipeline step $i: $command" |& tee -a pipeline_log.txt
    $command |& tee -a pipeline_log.txt

    if [ -n "$DEBUG" ]; then #if in debug mode, save off each step
        cd zips
        zip -r "after_step_${i}.zip" .. -x "*.zip"
        cd ..
    fi
    i=$((i+1))
done



echo "ngs-pipeline complete!"

# else # debug mode

    # mv **/!(*.[z][i][p]) ../zips

    # move the zips output folder to parent dir
    # zip the entire dir
    # copy to zips dir 
    # copy from parent dir to output dir


#fi


# P="0.6369" 
# java -jar -Xmx3g ~/picard.jar DownsampleSam -INPUT ${NAME}_MarkDuplicates.bam -OUTPUT ${NAME}_downsample.bam -P ${P}


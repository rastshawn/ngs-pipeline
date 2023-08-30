#!/bin/bash
cd /root/setup/downloads-to-install/

declare -a folders=("bamtools"
	"samtools"
	"bowtie2"
	"picard"
)

for folder in "${folders[@]}"
do
	cd "$folder"
	# delete all hidden files - https://unix.stackexchange.com/questions/77127/rm-rf-all-files-and-all-hidden-files-without-error
	rm -rf -- ..?* .[!.]*  
	
	# how many files are there?
	# ls -a includes . and .. as files in the dir, so add 2 to the number we want (1)
	numFiles=`ls -a | wc -l`
	if [ $numFiles -ne 3 ];
	then
		echo "There are either too many or too few files in /downloads-to-install/${folder}. Make sure there is only a single file - check README.md for information on which files you need. Make sure there aren't hidden files either!"
		exit 1;
	fi

	cd ..
		
done

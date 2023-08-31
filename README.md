## ngs-pipeline

This is a pipeline for analyzing next-generation sequencing results. An aligned sequence in a BAM file is compared to a reference fasta file in order to assess depth of coverage as well as assist in determining single nucleotide variants and calculating Shannon entropy of the genome. 

This project consists of a Docker image, the script and prerequisites to build that Docker image, and a script that runs within the Docker image. 
For most tasks only the image and the script that it runs should be necessary - the build script is included for future maintenance. The image should work on any amd64 machine without being rebuilt, but Apple Silicon Macs may need to build it before using it. 

Because the Docker image contains an operating system and all programs required to run the pipeline, it should behave the same way on any computer. If the script fails or produces questionable results, it is possible to log into the container itself to run any of these commands manually. 

## Aliases
Many of the commands for building and running the docker image and pipeline are long and frustrating to type out. To mitigate this, there are a list of shortened commands - aliases - that launch the full command. 

In Windows, aliases are automatically loaded into the Command Prompt window that launches when you double-click `windows.bat`. You can use them without taking any further action.

In MacOS or Linux, to add these aliases to your terminal:
* Open a terminal and set the working directory to the ngs-pipeline folder.
	* On MacOS, you can do this by right-clicking the folder and choosing "New Terminal At Folder". 
* Run `. aliases` (don't forget the dot).
The aliases will continue to work until you close your terminal window. Aliases are reset when you open new terminal windows, so you'll need to run it in each terminal you open. This command produces no output, so it's okay if it looks like it didn't do anything. You can test to see if it worked by running the command `_aliastest`, which outputs "Aliases are enabled" if they are enabled.


Aliases are optional, but helpful. You can just run the full commands instead.

## First-time setup
0. (Windows only) Update WSL2.
Docker requires WSL to be up to date. Open a Command Prompt window and run `wsl --update`.
If you see any errors that mention virtualization, check out the section of this guide labeled "Enabling Virtualization in BIOS."

1. Install Docker
[Docker](https://docker.com) is a containerization tool. A container is sort of like a virtual machine, and combined with an OS and programs contained in an image, can run programs. You can create an image from a set of instructions, or you can just copy an already-built image into a container to use it, but in order to do any of that you'll need to download Docker Desktop from [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/).

	* On Linux, Docker Desktop is not required. You can install `docker` from your system's package manager.
    * On MacOS, make sure to open Docker by clicking the icon after you've dragged it into your Applications folder. You'll need to complete the setup before you can use the docker command in terminal. As of July 2023, you don't need to create an account to use Docker Desktop -  you should be able to proceed by selecting "continue without signing in" when prompted to create an account. 
	* On Windows, after the installer completes and you restart your machine, you'll need to open Docker Desktop (you should be able to search in the Start menu). 
		* If after accepting terms of service and waiting a few moments to load you are taken to the Containers menu and see no errors, count your blessings and proceed to step 2. 
		* If you see an error that mentions enabling virtualization in BIOS, read the section of this guide labeled "Enabling Virtualization in BIOS." Without following these additional steps, none of the docker-related commands will work prope   rly.

2. Navigate your terminal to your ngs-pipeline directory. 
    * On MacOS, you can do this by right-clicking the folder and choosing "New Terminal At Folder". 
		* If you would like to enable aliases, run `. aliases`. 
    * On Windows, double click `windows.bat` inside the ngs-pipeline folder to open up a Command Prompt window with aliases already loaded.

3. Load in the pre-built image. If image.tar isn't in the folder or if these steps don't seem to work correctly, try building the image with the instructions in the Maintenance section.
	* Make sure there are no other images labeled `ngs-pipeline` on your machine:
		* With aliases enabled, run `_clean`.
		* Without aliases enabled, run `docker image remove -f ngs-pipeline`.
		* It's okay if this command returns an error - it likely means it tried to delete an old version that didn't exist. 
    * Run `docker load --input image.tar`
		* If this command fails on Windows, make sure you've opened Docker Desktop and start step 3 again.
		* Otherwise, if this fails, make sure your terminal is in the ngs-pipeline folder and ensure that image.tar exists. If not, see "Building using the Dockerfile" under Maintenance.

4. Make sure that the image is loaded. Run `docker images` and you should see ngs-pipeline under REPOSITORY. (Don't worry if the created date is wrong - there seems to be a Docker bug at time of writing). 

        
## Each-use setup

0. (Windows only) - open Docker Desktop, wait for it to load, then close it. You'll need to do this once each time your machine restarts, as opening Docker Desktop starts some background tasks that are required later.  

1. Copy the `ngs-pipeline` folder onto your machine. It can run on an external drive, but especially in Windows, it's safer to run this on an internal drive. To be safe, you'll want around 10 gigabytes of storage space to run the pipeline. 

2. Make sure that folders called input and output are in the ngs-pipeline folder. This is case-sensitive. Different names will prevent the docker image and the script from being able to read or write outside of the container.

3. Place exactly one bam file and exactly one fasta file into the input directory. 

Example: `Sample_TYF5521.final.bam` and `TYF5521_1.final.fasta`

4. Be sure to copy any important files out of the output directory! They may be overwritten. 


## Running the pipeline automatically
Run `docker run --rm --platform linux/amd64 -v ./output:/root/output -v ./input:/root/input -w /root  ngs-pipeline [name]`.
Example: `docker run --rm --platform linux/amd64 -v ./output:/root/output -v ./input:/root/input -w /root  ngs-pipeline TYF5521`.

If you're using aliases, simply run `_run TYF5521`. On Windows, either use aliases or change the slashes to the left of the colons to backslashes, like so:
`-v ./output:/root/output -v ./input:/root/input` -> `-v .\output:/root/output -v .\input:/root/input`

This will read in the bam and fasta files in the input directory, and place any generated files in the output directory. The application generates a log (`pipeline_log.txt`) containing the output of each command in the pipeline. 

If something isn't working correctly, you can investigate by running the command again but with DEBUG at the end. Be careful! This may use a lot of disk space, as it creates a zip file with the state of the output folder at the end of each step.
Example: `docker run --rm --platform linux/amd64 -v ./output:/root/output -v ./input:/root/input -w /root  ngs-pipeline TYF5521 DEBUG`.

When the pipeline completes (this does not mean it succeeded), "ngs-pipeline complete!" is printed onscreen and in `pipeline_log.txt`. 

## Killing a stuck pipeline
In a second terminal opened to any directory, run `docker kill [name-of-container]`. The container name is randomly generated each time the pipeline runs. On some machines, this tab-completes, so you should be able to type only `docker kill`, add a space, then hit tab - docker should fill in the name of the container. If this doesn't work, you can get the names of all running containers by running `docker container ps`. Unless you use docker for other tasks, `docker container ps` should only ever list one container.

Running `docker kill [name-of-container]` will kill the container and pipeline. 

Example: `docker kill goofy_hopper`

## Entering the image to interact with it (also - running commands outside of the pipeline)
Run `docker run --rm --platform linux/amd64 -it --entrypoint bash -v ./output:/root/output -v ./input:/root/input -w /root  ngs-pipeline`.

On Windows, either use aliases or change the slashes to the left of the colons to backslashes, like so:
`-v ./output:/root/output -v ./input:/root/input` -> `-v .\output:/root/output -v .\input:/root/input`

With aliases, run `_interactive`.

That will open the image, mapping the input and output folders on your computer to input and output folders inside the image. The required tools are already installed for running manually. In order to follow older instructions for running the pipeline manually, I would recommend:
* Copy picard.jar into the output directory so that it's there while you work in that directory with `cp picard.jar output/`.
* Copy any input files into the output directory so that the scripts can see them. `cp input/* output/`
* Enter the output directory with `cd output`. 
Then any of the commands from pipeline documentation should run. Viewing the contents of pipeline.sh should demonstrate the commands required, though you will need to edit them with correct names. 

This container  also has lofreq installed, and you can use it in this interactive shell as well.  

## Maintenance (and if cloned from GitHub)
If the built image (the .tar file) either doesn't run on your machine or it needs to be updated with newer versions of any of the tools used by the pipeline, you'll need to be able to build a new one from the Dockerfile.

Building using the Dockerfile:
* Ensure that the required programs are present in the downloads-to-install directory:
	* The easiest way to do this is to run `./get-requirements.sh`, or on Windows, double-click `get-requirements.bat`. This should download the versions of bamtools, bowtie2, lofreq, picard, and samtools that were originally used in the development of this image and place them in the correct folders. These scripts may break in the future if the providers of those programs change their links.
	* Otherwise, or if you are upgrading/modifying your image to include specific versions of the software, manually download and copy the software into the downloads-to-install folder:
		* Make sure that the downloads-to-install folder contains only one version of each software.
		* Bamtools' download should be a zipped source folder, ending in .tar.gz
		* Bowtie2 should be a linux binary ending in .zip
		* lofreq should be a linux binary ending in .tgz - not the source ending in .tar.gz
		* picard should just be the jarfile, ending in .jar
		* samtools is built from source as well with .tar.bz2.
		* In most cases, these downloads came from the GitHub releases page for each project, but you can also read the get-requirements script contents for more information.
* Ensure that there are the following files and folders in the ngs-pipeline directory:
	* downloads-to-install
	* Dockerfile
	* pipeline.sh
	* input
	* output
* If possible, use aliases (check the aliases section of this document). 
* Clean the build environment:
	* With aliases, run `_clean`.
	* Without aliases, run `docker image remove -f ngs-pipeline`.
	* Note - it's okay if this command returns an error. 
* Build the image:
	* Make sure your terminal is in the ngs-pipeline folder. 
	* With aliases, run `_build`.
	* Without aliases, run `docker build --platform linux/amd64 -t ngs-pipeline .`
	* Note - Any number of problems can happen with this command. What this does is it tells Docker to read the contents of the Dockerfile and try to build a container with them. It could fail because you don't have the correct folder layout mentioned above, because certain software packages are no longer available, or because the pipeline tools have been updated in such a way that the scripts currently used to compile them will no longer work. Commands in a Dockerfile are executed sequentially when `docker build` is ran, so you should be able to see what command failed. Each RUN command in the Dockerfile should be able to be separated into individual shell commands by removing the `&& \` at the end of each line. Commenting out the failing command in the Dockerfile, building, and then running these shell commands in _interactive mode should help narrow down the problem.   
* Run the image:
	* With aliases, run `_run`. 
	* Without aliases, run `docker run --rm --platform linux/amd64 -v ./output:/root/output -v ./input:/root/input -w /root  ngs-pipeline`.
* If the pipeline builds and runs as you expect, export the image you built for future use:
	* Run `docker save ngs-pipeline --output image.tar`. 
	* This will allow others to install and use the image without needing to build it. It makes an archive of the docker image named "ngs-pipeline".

Upgrading a package:
If one of the programs used in the pipeline has a new version available, it is possible to upgrade this image to include it. In short, what you'll need to do is:
* Download the software release. If a package mentions architecture (like x86_64) you're looking for either x86_64 or amd64. You're also looking for the linux version, regardless of the operating system you're using.
	* The included bamtools is from: https://github.com/pezmaster31/bamtools/releases
	* bowtie2: https://sourceforge.net/projects/bowtie-bio/files/bowtie2/
	* picard: https://github.com/broadinstitute/picard/releases/
	* samtools: https://github.com/samtools/samtools/releases
	* lofreq: https://github.com/CSB5/lofreq/tree/master/dist
* Drop it into the downloads-to-install subfolder that matches the software to be upgraded.
* Ensure that the previous version and the current version have the same file extension. Otherwise, the docker image build script will fail. If the extensions differ and you've downloaded an official release, the build script will likely require modification to use the new software.
* Build and export the new image using the "Building Using the Dockerfile" section above.

Modifying the pipeline script:
* Edit `pipeline.sh` and build/export the resultant image using the "Building Using the Dockerfile" section above. 

## Enabling Virtualization in BIOS (Windows only)
Most Windows machines will require a BIOS setting to be changed in order for Docker to run correctly. This process will be different for every PC, but is broadly broken down into two questions:
1. How do I enter BIOS settings on my machine?
2. Once in BIOS settings, how do I enable virtualization?

On most machines, you'll enter BIOS by repeatedly pressing a particular key (esc, F12, delete, or others) during startup. This will open a BIOS settings menu, which will contain an option to enable virtualization - but further complicating things, that option goes by different names and is in different menus depending on your computer's manufacturer, so it's not possible to write a complete guide on how to do this. Fortunately, lots of other people already have, so you should be able to find them for your machine!

You might get lucky and find a single virtualization video that covers everything, but you will probably want to find two different guides or YouTube videos - one for entering BIOS for your specific machine, and one for enabling virtualization. Videos are probably more helpful than text walkthroughs.

Here are the search terms I would use: 
`enter bios [motherboard]` and, once I knew how to do that, `enable virtualization [motherboard]`. If you're using a laptop or a prebuilt desktop, replace "motherboard" with your model number - like ThinkPad P15s or dell optiplex 9020. If you're using a custom-built PC or you've not found anything useful for your model number, try searching using your motherboard specifically.

In order to find what your motherboard is:
* press WindowsKey+R
* type "msinfo32"
* press ok. 
* click "System Summary" in the top left
* in the panel on the right side of the screen:
	* find "BaseBoard Manufacturer" and
	* find "BaseBoard Product".
If "BaseBoard Product" seems like human-readable text and not just a string of number, I would try those search terms above replacing "motherboard" with "BaseBoard Product" first. Otherwise, or if the results are unhelpful, I'd switch to "BaseBoard Manufacturer". Entering bios is usually manufacturer-specific, but enabling virtualization is often product-specific, so you may need to find virtualization instructions for specifically your "BaseBoard Product" if manufacturer instructions look different from your machine.

If you're stuck and are asking tech support or a tech-savvy friend for help, you're specifically asking for advice on how to "enable hardware virtualization in your machine's BIOS". 

After you've enabled virtualization in your bios, try opening Docker Desktop again. If you still get the same error, check one more time in the BIOS to see if your changes saved, but if the problem persists, you may need to adjust Windows Features. In order to do that, search the start menu for "Turn Windows Features on or off", press enter, and ensure that both "Virtual Machine Platform" and "Windows Subsystem for Linux" are enabled. If they are not, enable them and restart, then try opening Docker Desktop again. If it still doesn't work, try reading through the troubleshooting steps on the Docker website here, using steps for WSL2 (and not Hyper-V): https://docs.docker.com/desktop/troubleshoot/topics/#virtualization

Once Docker Desktop opens on your machine without any virtualization-related errors, you can proceed to step 2 in the first-time setup and never think about any of this nonsense ever again. 


## Warnings
* Don't try to run multiple pipelines at the same time in different windows. This _is_ possible, but would require mapping new folders and running multiple containers simultaneously. The setup time is almost certainly not worth any time saved from parallelization. 

## Contact
If you run into trouble with using or modifying this Docker image, email shawn@rast.dev. 


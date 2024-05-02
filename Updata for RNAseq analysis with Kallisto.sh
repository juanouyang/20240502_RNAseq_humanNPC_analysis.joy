https://pachterlab.github.io/kallisto/starting
https://cyverse-kallisto-tutorial.readthedocs-hosted.com/en/latest/step1.html
https://pachterlab.github.io/kallisto/starting
Updata for RNAseq analysis with Kallisto

# Start with creat a screen file for my scripts, under juo5 directory
mkdir screenlogs
cd screenlogs/
mkdir 20240424
*creat a screen.txt file, which will record the screen scripts and save it as .txt file
screen -L
*double check it saved in this list
ls

#ask for a node
srun --job-name "juo5" --cpus-per-task 24 --mem-per-cpu 3900 --time 1-00:00:00 --pty bash

#download file from GEOdataset
*load module
ml avail SRA-toolkit
ml SRA-toolkit
*configue  <sra-toolkit></sra-toolkit>
vdb-config --interactive
*after type this code, you will see a window showing SRA configuration (perhaps you can use it for something). I just enter 'E' then exit by typing 'X'
e
x
*download sra.file for multiple files following: https://www.reneshbedre.com/blog/ncbi_sra_toolkit.html
prefetch SRR17873842	SRR17873843	SRR17873844	SRR17873845	SRR17873846	SRR17873847	SRR17873848	SRR17873849	SRR17873850	SRR17873851	SRR17873852	SRR17873853	SRR17873854	SRR17873855	SRR17873856	SRR17873857	SRR17873858	SRR17873859

#usually the size of SRR17873842 is around 4k, the real size of this file should be checked by navigate into this file then check the size of .sra. 
ls -ltrh
*next extract fastq file from .sra (should go to the driectory of .sra file or put the entire directory to the end, get two folds out of it pass1: forward strand and pass2: Reverse strand for paired reads, )
fastq-dump --outdir /hpcdata/Mimir/juo5/20240409/fastq --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip /hpcdata/Mimir/juo5/20240409/SRR17873842/SRR17873842.sra
#--outdir /hpcdata/Mimir/juo5/20240409/fastq: Specifies the output directory where the FASTQ files will be saved.
#--gzip: Compresses the output FASTQ files using gzip compression.
#--skip-technical: Skips technical reads if present in the SRA file.
#--readids: Includes read IDs in the output FASTQ files.
#--read-filter pass: Filters reads based on their status (in this case, only passes reads will be included).
#--dumpbase: Dumps the read sequences in base-space (as opposed to color-space for SOLiD data).
#--split-3: Splits paired-end reads into separate files (R1 and R2).
#--clip: Clipping the sequence at the beginning and end, which may remove low-quality bases or adapters. The specific clipping parameters are not provided in your command.
#Finally, specify the input SRA file: /hpcdata/Mimir/juo5/20240409/SRR17873842/SRR17873842.sra.

#move all fastq file in individual file named SRRNNNNNNNN
*creat a move_folders.sh 

#!/bin/sh

#Script to make folders based on file names and move files into the folders, here it the file is .fastq.gz then modify .fastq to .fastq.gz


for f in *.fastq
do
  subdir=${f%%_*}
  [ ! -d "$subdir" ] && mkdir -- "$subdir"
  mv -- "$f" "$subdir"
done

#for f in *.fastq: This loop iterates over all files ending with .fastq in the current directory.
#subdir=${f%%_*}: This line extracts the prefix of the file name before the first underscore _ and assigns it to the variable subdir.
#[ ! -d "$subdir" ] && mkdir -- "$subdir": This line checks if the subdirectory does not exist ([ ! -d "$subdir" ]) and creates it if it doesn't (mkdir -- "$subdir"). The -- is used to signify the end of options and is a good practice to handle filenames that start with dashes (-).
#mv -- "$f" "$subdir": This line moves the file ($f) into the subdirectory ($subdir) using mv. Again, -- is used to signify the end of options.

*move move_folders.sh to the directory where the folds you want to move through Elja
*make it executable on elja
chmod u+x move_folders.sh
#chmod: Stands for "change mode", a command in Unix-like operating systems to change the permissions of files or directories.
#u+s: Sets the setuid (Set User ID) permission. When this permission is set on an executable file, the program will be executed with the privileges of the file's owner (user) rather than the privileges of the person executing the file.
#move_folders.sh: The name of the script file to which you want to apply the permission changes.
(after this you can see the color of .sh scripts turn to green instead of gray)

*run move_folders.sh scripts
./move_folders.sh 

*make another .sh script to run kallisto to all files
#!/bin/sh

#download reference genome from ensemble
*https://www.ensembl.org/Homo_sapiens/Info/Index  Homo_sapiens.GRCh38.cdna.all.fa.gz, down load then index with Kallisto
kallisto index -i HumanReftranscripts.idx Homo_sapiens.GRCh38.cdna.all.fa.gz

#Script to run kallisto on everything

find . -maxdepth 1 -mindepth 1 -type d -exec sh -c "cd '{}' && pwd && kallisto quant -i /hpcdata/Mimir/juo5/20240409/fastq/human_Ref/HumanReftranscripts.idx -o '{$1}'_20240424_Kallisto_output -b 100 -t 48 *.fastq " \;
#find .: Starts the search from the current directory.
#-maxdepth 1: Restricts the search to the current directory only (does not search in subdirectories).
#-mindepth 1: Specifies that the search should not include the starting directory itself.
#-type d: Specifies that the search should only consider directories.
#-exec sh -c "..." \;: Executes the specified shell command for each directory found.
#"cd '{}' && pwd && kallisto: it changes to the directory (cd '{}'), prints the current directory (pwd), and then runs the kallisto quant command with the specified options. 
#-i /hpcdata/Mimir/juo5/20240409/fastq/human_Ref/HumanReftranscripts.idx: where is the index reference file
#-o '{$1}'_20240424_Kallisto_output, where is the output file

*save it as 20240402_Kallisto_Novogene.sh file formate and move it to the diretory where the samples foldes are on Elja
*make it executable on Elja
chmod u+x 20240402_Kallisto_Novogene.sh

*load kallisto on Elja
ml kallisto

*run script
./20240402_Kallisto_Novogene.sh

*it is important to keep the orginal aboundance file without rename it, otherwise it will lead to errors

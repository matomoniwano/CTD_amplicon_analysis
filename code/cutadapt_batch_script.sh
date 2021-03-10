#!/bin/bash

# $1 = path to fastq directory
# $2 = forward primers
# $3 = reverse primers

# Changing input field separators to new line (\n)
IFS=$'\n'

# Create a variable for the current path
current=$PWD

# Error message for missing positional arguments when running this script
if [ $# -ne 3 ] ; then
    echo "Usage:"
    echo "$0 takes three parameters, 
    echo '$1' = path to fastq directory
    echo '$2' = forward primers
    echo '$3' = reverse primers
    exit 1
else
    echo 'Running cutadapt in batches'
fi

# Adding a path to fastq directory from the positional argument $1 
fastqpath=$1
# Adding a fwd primers sequence from the positional argument $2
fwdprm=$2
# Adding a rvs primers sequence from the positional argument $3
rvsprm=$3

# Extracting fwd fastq file names
fwd=($(ls -1v $1 | grep 'R1'))

# Creating a new directory for clipped fastq files
mkdir $1/processed_files 

# Move to fastq directory
cd $1

# Running cutadapt using forloop for each pair-end fastq files. 
for rvsfastq in "${fwd[@]}"
do
	rvsname=$(echo "$rvsfastq" | sed -e "s/R1/R2/")
	echo "$rvsfastq" >> ~/CTD_analysis/code/cutadapt_summary.txt
	cutadapt -g "$fwdprm" -G "$rvsprm" --discard-untrimmed -o ./processed_files/"$rvsfastq" -p ./processed_files/"$rvsname" "$rvsfastq" "$rvsname" >> ~/CTD_analysis/code/cutadapt_summary.txt
	echo "$rvsfastq" >> ~/CTD_analysis/code/seqnames.txt
done

# Counting sequence reads from raw fastq files
while read line
do
ls -1v "${line}" | xargs wc -l | grep -v "total" | awk '{print $1/4}' >> ~/CTD_analysis/code/seqreads_raw.txt
done < ~/CTD_analysis/code/seqnames.txt

# Move to processed fastq directory
cd $1/processed_files

# Counting sequence reads from clipped fastq files
while read line
do
ls -1v "${line}" | xargs wc -l | grep -v "total" | awk '{print $1/4}' >> ~/CTD_analysis/code/seqreads_clipped.txt
done < ~/CTD_analysis/code/seqnames.txt

# Back to the working directory
cd $current

# Create a table with all the stats
paste seqnames.txt seqreads_raw.txt seqreads_clipped.txt > seqtable.txt

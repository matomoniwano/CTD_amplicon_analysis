#!/bin/bash

# $1 = path to fastq directory
# $2 = forward primers
# $3 = reverse primers

IFS=$'\n'

current=$PWD

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

fastqpath=$1
fwdprm=$2
rvsprm=$3

fwd=($(ls -1v $1 | grep 'R1'))

mkdir $1/processed_files 

cd $1

for rvsfastq in "${fwd[@]}"
do
	rvsname=$(echo "$rvsfastq" | sed -e "s/R1/R2/")
	cutadapt -g "$fwdprm" -G "$rvsprm" --discard-untrimmed -o ./processed_files/"$rvsfastq" -p ./processed_files/"$rvsname" "$rvsfastq" "$rvsname" 
	echo "$rvsfastq" >> ~/CTD_analysis/code/seqnames.txt
done

while read line
do
ls -1v "${line}" | xargs wc -l | grep -v "total" | awk '{print $1/4}' >> ~/CTD_analysis/code/seqreads_raw.txt
done < ~/CTD_analysis/code/seqnames.txt

cd $1/processed_files

while read line
do
ls -1v "${line}" | xargs wc -l | grep -v "total" | awk '{print $1/4}' >> ~/CTD_analysis/code/seqreads_clipped.txt
done < ~/CTD_analysis/code/seqnames.txt

cd $current

paste seqnames.txt seqreads_raw.txt seqreads_clipped.txt > seqtable.txt

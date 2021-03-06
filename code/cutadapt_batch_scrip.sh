#!/bin/bash

# $1 = path to fastq directory
# $2 = forward primers
# $3 = reverse primers

IFS=$'\n'

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
	echo "$rvsfastq"
done


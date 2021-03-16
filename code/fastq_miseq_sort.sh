#!/bin/bash

# $1 = path to fastq directory
# $2 = Miseq Run ID

# Changing input field separators to new line (\n)
IFS=$'\n'

# Error message for missing positional arguments when running this script
if [ $# -ne 2 ] ; then
	echo "Usage:"
	echo "$0 takes two parameters"
	echo '$1 = path to processed fastq directory'
	echo '$2 = Miseq Run ID'
	exit 1
else
	echo 'Sorting fastq files based on Miseq Run IDs'
fi

# Adding a path to processed fastq directory from the positional argument $1 
fastqpath=$1
# Adding Miseq ID from the positional argument $2
miseqid=$2

# Move to process fastq directory
cd $fastqpath

# Make a new folder named MISEQ ID
mkdir $miseqid

# Sort and Copy fastq files based on Miseq Run IDs
for file in $(cat ../"$miseqid"_list.txt) 
do
	fwname=$(echo "$file" | sed 's/^.*\(FRAM.*gz\).*$/\1/')
	rvname=$(echo "$fwname" | sed -e "s/R1/R2/")
	cp $fwname ./$miseqid
	cp $rvname ./$miseqid
done



AMAS=/datacommons/yoderlab/programs/AMAS/amas/AMAS.py

DIR_FASTA=/work/jwp37/radseq/seqdata/fasta_full/map2msp3.paired.gatk4/byLocus.final.msp3proj.snapp12.mac3.FS7.callableDP3.ov0.9.ovt0.8.ls100/
DIR_STATS=/datacommons/yoderlab/users/jelmer/msp3/analyses/vcf2fullFasta/locusStats.msp3proj.snapp12.amas/
FILE_ID=snapp12

mkdir -p $DIR_STATS
FILE_STATS_ALL=$DIR_STATS/$FILE_ID.AmasStats.txt

for FASTA in $DIR_FASTA/*
do
	#FASTA=$DIR_FASTA/Super_Scaffold14:1576795-1577032.fa
	echo "#### Fasta file: $FASTA"
	
	FASTA_ID=$(basename $FASTA)
	FILE_STATS=$DIR_STATS/tmp.$FASTA_ID.stats.txt
	
	$AMAS summary -f fasta -d dna -i $FASTA -o $FILE_STATS
	
	cat $FILE_STATS | grep -v "Alignment_name" >> $FILE_STATS_ALL
	
	printf "\n"
done

head -n 1 $FILE_STATS > $FILE_STATS_ALL



################################################################################################################
#rsync -avr jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/msp3/analyses/vcf2fullFasta/locusStats.msp3proj.snapp12.amas/*AmasStats.txt /home/jelmer/Dropbox/sc_lemurs/msp3/analyses/vcf2fullFasta/
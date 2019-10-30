#mkdir -p analyses/dfoil/input analyses/dfoil/output analyses/dfoil/summaries

#####################################################################################################
##### SET-UP #####
#####################################################################################################
FILE_ID=msp3proj.mac3.FS6
GATK_VERSION=gatk4
MAP2=map2msp3
VCF_DIR=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final
FASTA_DIR=/work/jwp37/radseq/seqdata/fasta
FASTA=$FASTA_DIR/$FILE_ID.fasta
DFOIL_INDIR=analyses/dfoil/input
DFOIL_OUTDIR=analyses/dfoil/output
OUTGROUP=mmur


#####################################################################################################
##### STEP 1 - CONVERT VCF TO FASTA #####
#####################################################################################################
SCAFFOLD=ALL
sbatch --mem 8G -p yoderlab,common,scavenger -o slurm.vcf2fasta.$FILE_ID.txt \
	scripts/conversion/vcf2fasta.sh $FILE_ID $VCF_DIR $FASTA_DIR $SCAFFOLD

	
#####################################################################################################
##### STEP 2 - PREP FASTA FOR DFOIL #####
#####################################################################################################
## All sequences belonging to same focal unit (species, pop, whatever level the test is run on)
## should have the exact same name in the fasta file as specified for the fasta2dfoil script.
## Also, only the 5 pops/species that are being actively tested can be present in the fasta.

SEQKIT=/datacommons/yoderlab/programs/seqkit # https://github.com/shenwei356/seqkit

mv $FASTA $FASTA.tmp


## Tests with msp3-mmac-mleh/mmit-msim-mmur:
cat $FASTA.tmp | \
	sed -E 's/mmit(01[3-8]).*/mleh\1/' | \
	sed -E 's/mspp(019).*/mleh\1/' | \
	sed -E 's/mspp(02[0-3]).*/mmac\1/' | \
	$SEQKIT sort > $FASTA.tmp2

cat $FASTA.tmp2 | \
	sed 's/mleh.*/mleh/' | \
	sed 's/mmac.*/mmac/' | \
	sed 's/mmit.*/mmit/' | \
	sed 's/mmur.*/mmur/' | \
	sed 's/msim.*/msim/' | \
	sed 's/mspp.*/msp3/' > $FASTA
	
cat $FASTA | awk '/^>/ {P=index($0,"mleh")==0} {if(P) print} ' > $FASTA.noMleh
cat $FASTA | awk '/^>/ {P=index($0,"mmit")==0} {if(P) print} ' > $FASTA.noMmit

## Tests with msp3east-msp3west-mleh-mmit-mmur:
cat $FASTA.tmp2 | \
	sed 's/mleh.*/mleh/' | \
	sed 's/mmac.*/mmac/' | \
	sed 's/mmit.*/mmit/' | \
	sed 's/mmur.*/mmur/' | \
	sed 's/msim.*/msim/' | \
	sed 's/mspp00[0-9].*/mspe/' | \
	sed 's/mspp010.*/mspe/' | \
	sed 's/mspp02[4-9].*/mspe/' | \
	sed 's/mspp01[7-8].*/mspw/' | \
	sed 's/mspp03[0-2].*/mspw/' | \
	awk '/^>/ {P=index($0,"mmac")==0} {if(P) print} ' | \
	awk '/^>/ {P=index($0,"msim")==0} {if(P) print} ' | \
	$SEQKIT sort > $FASTA.pop 

# grep ">" $FASTA.pop


#####################################################################################################
##### STEP 3 - PREP DFOIL INPUT FROM FASTA #####
#####################################################################################################
#module load python/2.7.11
FASTA2DFOIL=/datacommons/yoderlab/programs/dfoil/fasta2dfoil.py

POPCOMB_NO_MMIT="msp3,mmac,mleh,msim,$OUTGROUP"
INFILE_NO_MMIT=$DFOIL_INDIR/$FILE_ID.noMmit.dfoil.in
$FASTA2DFOIL $FASTA.noMmit --out $INFILE_NO_MMIT --names $POPCOMB_NO_MMIT

POPCOMB_NO_MLEH="msp3,mmac,mmit,msim,$OUTGROUP"
INFILE_NO_MLEH=$DFOIL_INDIR/$FILE_ID.noMleh.dfoil.in
$FASTA2DFOIL $FASTA.noMleh --out $INFILE_NO_MLEH --names $POPCOMB_NO_MLEH

POPCOMB_POP="mspe,mspw,mleh,mmit,$OUTGROUP"
INFILE_POP=$DFOIL_INDIR/$FILE_ID.pop.dfoil.in
$FASTA2DFOIL $FASTA.pop --out $INFILE_POP --names $POPCOMB_POP


#####################################################################################################
##### STEP 4 - RUN DFOIL #####
#####################################################################################################
module load Python/3.6.4
DFOIL=/datacommons/yoderlab/programs/dfoil/dfoil.py

## Normal mode:
OUTFILE_NO_MMIT=$DFOIL_OUTDIR/$FILE_ID.noMmit.dfoil.out
$DFOIL --infile $INFILE_NO_MMIT --out $OUTFILE_NO_MMIT --mode dfoil

OUTFILE_NO_MLEH=$DFOIL_OUTDIR/$FILE_ID.noMleh.dfoil.out
$DFOIL --infile $INFILE_NO_MLEH --out $OUTFILE_NO_MLEH --mode dfoil

OUTFILE_POP=$DFOIL_OUTDIR/$FILE_ID.pop.dfoil.out
$DFOIL --infile $INFILE_POP --out $OUTFILE_POP --mode dfoil

## Alt mode:
OUTFILE_NO_MMIT=$DFOIL_OUTDIR/$FILE_ID.noMmit.altMode.dfoil.out
$DFOIL --infile $INFILE_NO_MMIT --out $OUTFILE_NO_MMIT --mode dfoilalt

OUTFILE_NO_MLEH=$DFOIL_OUTDIR/$FILE_ID.noMleh.altMode.dfoil.out
$DFOIL --infile $INFILE_NO_MLEH --out $OUTFILE_NO_MLEH --mode dfoilalt

OUTFILE_POP=$DFOIL_OUTDIR/$FILE_ID.pop.altMode.dfoil.out
$DFOIL --infile $INFILE_POP --out $OUTFILE_POP --mode dfoilalt



########################################################################################################################################
########################################################################################################################################
# rsync --verbose -r /home/jelmer/Dropbox/sc_lemurs/radseq/scripts/* jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/scripts/
# rsync --verbose -r jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/analyses/dfoil/* /home/jelmer/Dropbox/sc_lemurs/radseq/analyses/dfoil/


########################################################################################################################################
## Get regular dstats:
#$DFOIL --infile $DFOIL_INFILE.noCfus --out $DFOIL_OUTFILE.noCfus.dstats --mode dstat

## Edit fasta:
#cat $FASTA | awk '/^>/ {P=index($0,"mrav01")==0} {if(P) print} ' | awk '/^>/ {P=index($0,"msam01")==0} {if(P) print} ' | \
#	awk '/^>/ {P=index($0,"mmac01")==0} {if(P) print} ' | awk '/^>/ {P=index($0,"mtav01")==0} {if(P) print} ' | \
#	awk '/^>/ {P=index($0,"mzaz01")==0} {if(P) print} ' > $FASTA.dfoil

#TAXA=mleh01,mmit01,mmyo01,mber01,$OUTGROUP
#scripts/dfoil/dfoil_run.sh $FILE_ID $FASTA $DFOIL_INFILE $DFOIL_OUTFILE "$TAXA"

## Dfoil-alt mode:
#$DFOIL --infile $DFOIL_INFILE --out $OUTFILE_NO_MMIT.alt --mode dfoilalt
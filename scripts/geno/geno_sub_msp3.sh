################################################################################
#### INDIVIDUALS ####
################################################################################
#INDS=( $(tail -n +2 metadata/sp3/sp3_r99_fastqRenamingTable.txt | cut -f 6,7 | grep "^0" | cut -f 2) ) # Only take single-end read inds
#INDS_R01=( $(cat metadata/r01/samples/sampleIDs_sp3_yoderlab.txt) )
#INDS_R99=( $(cat metadata/msp3/msp3_r99_IDs.txt) )
#cat metadata/r01/samples/sampleIDs_sp3_yoderlab.txt metadata/msp3/msp3_r99_IDs.txt | sort > metadata/msp3/msp3_IDs.txt
INDS=( $(cat metadata/msp3/msp3_IDs.txt) )


################################################################################
#### GENERAL SETTINGS ####
################################################################################
GATK_VERSION=gatk4
MAP2=map2msp3
REF_DIR=/datacommons/yoderlab/users/jelmer/seqdata/reference/mnor/
REF_ID=mnor.stitched100M
REF=$REF_DIR/$REF_ID.fasta
GVCF_DIR=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.ind/gvcf


################################################################################
#### MAPPING SEQUENCES AND GENERATING GVCFS ####
################################################################################
BASEDIR=/datacommons/yoderlab/users/jelmer/radseq
REGIONS_FILE=$REF_DIR/$REF_ID.nonAutosomalCoords.bed
EXCLUDE_OR_INCLUDE_REGIONS="EXCLUDE"
USE_R2=TRUE
BAM_PREFIX=sort.MQ30.auto #sort.MQ30.dedup.auto
INTERVAL_FILE=notany
INTERVAL_ID=notany
MINMAPQUAL=30
MEM=12
NCORES=4
#SKIP_FLAGS=""
SKIP_FLAGS="-MVGFq" # M: map / P: Process bam general / A: exclude (non-autosomal) regions / V: vardisc / G: genotype / F: filter VCF / q: QC VCF

BAM_DIR=/work/jwp37/radseq/seqdata/bam/map2msp3/
QC_DIR_BAM=analyses/qc/bam/map2msp3.paired/
VCF_DIR_MAIN=/work/jwp37/radseq/seqdata/vcf/map2msp3.gatk4.paired.ind/intermed
VCF_DIR_FINAL=/work/jwp37/radseq/seqdata/vcf/map2msp3.gatk4.paired.ind/final
QC_DIR=analyses/qc/vcf/map2msp3.gatk4.paired.ind/
	
for IND in ${INDS[@]}
do
	#IND=mspp002_r01_p3c01
	echo "Indiv ID: $IND"
	
	[[ $(grep -c "r01" <<< $IND) == 1 ]] && echo "Ind from r01 run..." && FASTQ_DIR=/work/jwp37/radseq/seqdata/fastq/demult_dedup_trim2
	[[ $(grep -c "r99" <<< $IND) == 1 ]] && echo "Ind from r99 run..." && FASTQ_DIR=/work/jwp37/radseq/seqdata/fastq/r99_renamed
	
	sbatch -p yoderlab,common,scavenger -N 1-1 --ntasks 4 --mem-per-cpu 4G -o slurm.genoInd.map2msp3.$GATK_VERSION.$IND \
	scripts/genotyping/gatk/geno_pip_inds.sh $IND $USE_R2 $REF $BASEDIR $FASTQ_DIR $BAM_DIR $GVCF_DIR $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR \
	$MINMAPQUAL $QC_DIR_BAM $GATK_VERSION $BAM_PREFIX $INTERVAL_FILE $INTERVAL_ID $REGIONS_FILE $EXCLUDE_OR_INCLUDE_REGIONS $MEM $NCORES $SKIP_FLAGS
done


################################################################################
#### JOINT GENOTYPING ####
################################################################################
SCAFFOLD_FILE=$REF_DIR/$REF_ID.scaffoldList.txt
INCREMENT=1
START_AT=1
STOP_AT="none"
VCF_DIR_SCAFFOLD=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/intermed.byScaffold
VCF_DIR_MAIN=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/intermed
VCF_DIR_FINAL=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final
QC_DIR=analyses/qc/vcf/$MAP2.$GATK_VERSION.paired.joint/
ADD_COMMANDS="none"
MEM_JOB=36
MEM_GATK=24
NCORES=1

FILE_ID=msp3proj
scripts/genotyping/gatk/geno_pip_joint_gatk4.sh $FILE_ID $SCAFFOLD_FILE $INCREMENT $START_AT $STOP_AT \
	$GVCF_DIR $VCF_DIR_SCAFFOLD $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR \
	$REF "$ADD_COMMANDS" $MEM_JOB $MEM_GATK $NCORES ${INDS[@]}


################################################################################
################################################################################
# rsync -r --verbose /home/jelmer/Dropbox/sc_lemurs/radseq/scripts/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/scripts/ 
# rsync -r --verbose /home/jelmer/Dropbox/sc_lemurs/radseq/metadata/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/metadata/
# rsync -r --verbose jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/log_sp3/bamcomp.txt /home/jelmer/Dropbox/sc_lemurs/radseq/analyses/man_sp3
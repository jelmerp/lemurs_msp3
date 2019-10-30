#rsync --verbose -r jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/analyses/qc/vcf/mapped2msp3/gatk4/filtering/*filterstats /home/jelmer/Dropbox/sc_lemurs/radseq/analyses/qc/vcf/gatk/mapped2msp3/filtering/

################################################################################################################
#### GENERAL SETTINGS ####
FILE_ID=msp3proj
GATK_VERSION=gatk4
MAP2=map2msp3
VCF_DIR_MAIN=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/intermed
VCF_DIR_FINAL=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final
QC_DIR=analyses/qc/vcf/$MAP2.$GATK_VERSION.paired.joint/
REF_DIR=/datacommons/yoderlab/users/jelmer/seqdata/reference/mnor/
REF_ID=mnor.stitched100M
REF=$REF_DIR/$REF_ID.fasta


################################################################################################################
#### GPHOCS DATASET ####
SUBSET_ID=eastwest
INPUT_NAME=$FILE_ID.rawSNPs
OUTPUT_NAME=$FILE_ID.$SUBSET_ID
SAMPLE_ID_FILE=analyses/gphocs/indSel/$FILE_ID.$SUBSET_ID.inds.txt
DP_MEAN=15
MAC=3
SELECT_INDS_BY_FILE=TRUE
FILTER_INDS_BY_MISSING=FALSE
MEM=4
JOBNAME=filterVCF.$FILE_ID.$SUBSET_ID
SKIP_COMMON_STEPS="-1456789tew"
SKIP_FINAL_STEPS="-123"
SKIP_IN_PIP="" #"-C"
scripts/filtering/filterVCF_FS6_pip.sh $INPUT_NAME $OUTPUT_NAME $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR $REF \
	$DP_MEAN $MAC $FILTER_INDS_BY_MISSING $SELECT_INDS_BY_FILE $SAMPLE_ID_FILE $MEM $JOBNAME \
	$SKIP_COMMON_STEPS $SKIP_FINAL_STEPS $SKIP_IN_PIP

	
################################################################################################################
#### SNAPP12 DATASET ####
INPUT_NAME=$FILE_ID.rawSNPs.ABHet
OUTPUT_NAME=$FILE_ID.snapp12
SAMPLE_ID_FILE=analyses/SNAPP/snapp12.inds.txt
DP_MEAN=15
MAC=3
SELECT_INDS_BY_FILE=TRUE
FILTER_INDS_BY_MISSING=FALSE
MEM=4
SKIP_COMMON_STEPS="-12456789tew"
SKIP_FINAL_STEPS="-12"
sbatch -p yoderlab,common,scavenger -o slurm.filterVCFpip.$FILE_ID.$OUTPUT_NAME \
scripts/filtering/filterVCF_FS6_pip.sh $INPUT_NAME $OUTPUT_NAME $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR $REF \
	$DP_MEAN $MAC $FILTER_INDS_BY_MISSING $SELECT_INDS_BY_FILE $SAMPLE_ID_FILE $MEM $JOBNAME \
	$SKIP_COMMON_STEPS $SKIP_FINAL_STEPS $SKIP_IN_PIP


################################################################################################################
#### SNAPP22 DATASET ####
INPUT_NAME=$FILE_ID.rawSNPs.ABHet
OUTPUT_NAME=$FILE_ID.snapp22
SAMPLE_ID_FILE=analyses/SNAPP/snapp22.inds.txt
DP_MEAN=15
MAC=3
SELECT_INDS_BY_FILE=TRUE
FILTER_INDS_BY_MISSING=FALSE
MEM=4
SKIP_COMMON_STEPS="-12456789tew"
SKIP_FINAL_STEPS="-12"
sbatch -p yoderlab,common,scavenger -o slurm.filterVCFpip.$FILE_ID.$OUTPUT_NAME \
scripts/filtering/filterVCF_FS6_pip.sh $INPUT_NAME $OUTPUT_NAME $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR $REF \
	$DP_MEAN $MAC $FILTER_INDS_BY_MISSING $SELECT_INDS_BY_FILE $SAMPLE_ID_FILE $MEM $JOBNAME \
	$SKIP_COMMON_STEPS $SKIP_FINAL_STEPS $SKIP_IN_PIP
	
	                                                          
################################################################################################################
#### ALL INDS ####
INPUT_NAME=$FILE_ID.rawSNPs.ABHet
OUTPUT_NAME=$FILE_ID
DP_MEAN=15
MAC=3
SELECT_INDS_BY_FILE=FALSE
SAMPLE_ID_FILE=aap
FILTER_INDS_BY_MISSING=TRUE
MEM=4
SKIP_COMMON_STEPS="-12456789tew"
SKIP_FINAL_STEPS="-123"
sbatch -p yoderlab,common,scavenger -o slurm.filterVCFpip.$FILE_ID.$OUTPUT_NAME \
scripts/filtering/filterVCF_FS6_pip.sh $INPUT_NAME $OUTPUT_NAME $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR $REF \
	$DP_MEAN $MAC $FILTER_INDS_BY_MISSING $SELECT_INDS_BY_FILE $SAMPLE_ID_FILE $MEM $JOBNAME \
	$SKIP_COMMON_STEPS $SKIP_FINAL_STEPS $SKIP_IN_PIP

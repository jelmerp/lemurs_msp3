GATK_VERSION=gatk4
MAP2=map2msp3
VCF_DIR=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final
QC_DIR=analyses/qc/vcf/$MAP2.$GATK_VERSION.paired.joint/
RUN_BCF=TRUE
RUN_BCF_BY_IND=FALSE

FILE_ID=msp3proj.mac1.FS6
#sbatch --mem ${MEM}G -p common,yoderlab,scavenger -o slurm.qcVCF.$FILE_ID \
scripts/qc/qc_vcf.sh $FILE_ID $VCF_DIR $QC_DIR $RUN_BCF $RUN_BCF_BY_IND



################################################################################
################################################################################
# rsync -r --verbose jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/analyses/qc/vcf/map2msp3.gatk4.paired.joint/ /home/jelmer/Dropbox/sc_lemurs/radseq/analyses/qc/vcf/

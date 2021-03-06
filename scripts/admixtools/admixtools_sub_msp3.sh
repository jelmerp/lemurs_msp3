## General settings:
GATK_VERSION=gatk4
MAP2=map2msp3
VCF_DIR=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final
PLINK_DIR=/work/jwp37/radseq/seqdata/plink
ATOOLS_DIR=analyses/admixtools
VCF2PLINK=FALSE
CREATE_INDFILE=FALSE
SUBSET_INDFILE=TRUE
FILE_ID=msp3proj.mac3.FS6
INDS_METADATA=metadata/ID.lookupTable.txt

## D-mode, each species as a pop:
INDFILE_ID=msp3
POPFILE_ID=dstat_$INDFILE_ID
CREATE_INDFILE=TRUE
ATOOLS_MODE=D
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

## D-mode, separate pops for msp3 and mmac (introg mtDNA vs not):
INDFILE_ID=msp3.msp3pops
POPFILE_ID=dstat_$INDFILE_ID
CREATE_INDFILE=FALSE
ATOOLS_MODE=D
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

## D-mode, separate pops for msp3:
INDFILE_ID=msp3.msp3pops2
POPFILE_ID=dstat_$INDFILE_ID
CREATE_INDFILE=FALSE
ATOOLS_MODE=D
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

## F3-mode, separate pops for msp3:
INDFILE_ID=msp3.msp3pops2
POPFILE_ID=f3stat_$INDFILE_ID
ATOOLS_MODE=F3
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

## F3-mode, each species as a pop:
INDFILE_ID=msp3
POPFILE_ID=f3stat_$INDFILE_ID
ATOOLS_MODE=F3
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

## F4-ratio-mode, each species as a pop:
INDFILE_ID=msp3
POPFILE_ID=f4ratio_$INDFILE_ID
ATOOLS_MODE=F4RATIO
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

## F4-ratio-mode, each sp:
INDFILE_ID=msp3.msp3pops2
POPFILE_ID=f4ratio_$INDFILE_ID
ATOOLS_MODE=F4RATIO
scripts/admixtools/admixtools_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $ATOOLS_DIR $INDFILE_ID $POPFILE_ID $VCF2PLINK $CREATE_INDFILE $SUBSET_INDFILE $ATOOLS_MODE $INDS_METADATA

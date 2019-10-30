#mkdir -p analyses/trees/treemix/output analyses/trees/treemix/input analyses/trees/treemix/popfiles

#####################################################################################################
##### RUN TREEMIX #####
#####################################################################################################

## General settings:
MAP2=map2msp3
GATK_VERSION=gatk4
VCF_DIR=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final 
PREP_INPUT=TRUE
MINMIG=0
MAXMIG=10
TREEMIX_DIR=analyses/trees/treemix/
ROOT=mmur
INDS_METADATA=metadata/ID.lookupTable2.txt

## CHOOSE FILE:
FILE_ID=msp3proj.mac1.FS6
FILE_ID=msp3proj.mac3.FS6
#FILE_ID=msp3proj.mac1.FS7
#FILE_ID=msp3proj.snapp12.mac1.FS6
#FILE_ID=msp3proj.snapp12.mac1.FS8

## Run:
#sbatch -p yoderlab,common,scavenger -o slurm.treemix.pip.$FILE_ID \
scripts/trees/treemix_pip.sh $FILE_ID $VCF_DIR $PREP_INPUT $MINMIG $MAXMIG $ROOT $TREEMIX_DIR $INDS_METADATA


	
	
#########################################################################################################################
### Copy files:
# rsync -r --verbose /home/jelmer/Dropbox/sc_lemurs/radseq/metadata/* jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/metadata/
# rsync -r --verbose /home/jelmer/Dropbox/sc_lemurs/radseq/analyses/trees/treemix/popfiles/* jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/analyses/trees/treemix/popfiles/
# rsync -r --verbose jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/analyses/trees/treemix/output/* /home/jelmer/Dropbox/sc_lemurs/radseq/analyses/trees/treemix/output

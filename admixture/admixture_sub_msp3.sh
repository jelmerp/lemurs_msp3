################################################################################
##### STEP 1 - CONVERT VCF TO PLINK #####
################################################################################
## Msp3 - no mmur:
FILE_ID=msp3proj.mac1.FS6
VCF_DIR=/work/jwp37/msp3/seqdata/vcf/map2msp3.gatk4.paired.joint/final/
PLINK_DIR=/work/jwp37/msp3/seqdata/plink
OUTDIR=analyses/admixture/output/
MAF=0; LD_MAX=1; NCORES=1
INDFILE=metadata/indsel/msp3_noMur.txt
bcftools query -l $VCF_DIR/$FILE_ID.vcf.gz | grep -v "mmur" > $INDFILE
sbatch -p common,yoderlab,scavenger --mem 8G -o slurm.admixturePip.$FILE_ID \
	/datacommons/yoderlab/users/jelmer/scripts/admixture/admixture_pip.sh $FILE_ID $VCF_DIR $PLINK_DIR $OUTDIR $MAF $LD_MAX $NCORES $INDFILE

## Msp3 - mac3:
FILE_ID=msp3proj.mac3.FS6
MAP2=map2msp3
GATK_VERSION=gatk4
VCF_DIR=/work/jwp37/msp3/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final 
PLINK_DIR=/work/jwp37/msp3/seqdata/plink
MAF=0.1
LD_MAX=1
scripts/conversion/vcf2plink.sh $FILE_ID $VCF_DIR $PLINK_DIR $MAF $LD_MAX $INDFILE

## Msp3 - mac1:
FILE_ID=msp3proj.mac1.FS6
MAP2=map2msp3
GATK_VERSION=gatk4
VCF_DIR=/work/jwp37/msp3/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final 
PLINK_DIR=/work/jwp37/msp3/seqdata/plink
MAF=0
LD_MAX=1
scripts/conversion/vcf2plink.sh $FILE_ID $VCF_DIR $PLINK_DIR $MAF $LD_MAX $INDFILE

## Only mmac & msp3 - mac 3:
FILE_ID=msp3proj.mac3.FS6
MAP2=map2msp3
GATK_VERSION=gatk4
VCF_DIR=/work/jwp37/msp3/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final 
PLINK_DIR=/work/jwp37/msp3/seqdata/plink
MAF=0
LD_MAX=1
INDFILE=metadata/msp3/msp3_msp3mmac.IDs.txt
ID_OUT=$FILE_ID.msp3mmac
scripts/conversion/vcf2plink.sh $FILE_ID $VCF_DIR $PLINK_DIR $MAF $LD_MAX $INDFILE $ID_OUT

## Only mmac & msp3 - mac 1:
FILE_ID=msp3proj.mac1.FS6
MAP2=map2msp3
GATK_VERSION=gatk4
VCF_DIR=/work/jwp37/msp3/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final 
PLINK_DIR=/work/jwp37/msp3/seqdata/plink
MAF=0
LD_MAX=1
INDFILE=metadata/msp3/msp3_msp3mmac.IDs.txt
ID_OUT=$FILE_ID.msp3mmac
scripts/conversion/vcf2plink.sh $FILE_ID $VCF_DIR $PLINK_DIR $MAF $LD_MAX $INDFILE $ID_OUT


################################################################################
##### STEP 2 #####
################################################################################
for FILE_ID in msp3proj.mac3.FS6.msp3mmac msp3proj.mac1.FS6.msp3mmac
do
	#FILE_ID=msp3proj.mac1.FS6
	echo $FILE_ID
	INDIR=/work/jwp37/msp3/seqdata/plink
	OUTDIR=analyses/admixture/output/
	NCORES=1
	for K in 1 2 3 4 5 6 7 8 9
	do
	echo "K: $K"
	sbatch -p common,yoderlab,scavenger --mem 8G --ntasks $NCORES -o slurm.runAdmixture.$FILE_ID.K$K scripts/admixture/admixture_run.sh $FILE_ID $INDIR $OUTDIR $K $NCORES
	done
	printf "\n"
done



################################################################################
# rsync -avr jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/msp3/analyses/admixture/output/* /home/jelmer/Dropbox/sc_lemurs/msp3/analyses/admixture/output/

# scp jwp37@dcc-slogin-02.oit.duke.edu:/work/jwp37/msp3/seqdata/plink/* /home/jelmer/Dropbox/sc_lemurs/msp3/seqdata/plink/
SCR_ADMIX=scripts/genomics/admixture/admixture_pip.sh
PLINK_DIR=seqdata/plink # dir for PLINK files (to be produced)
OUTDIR=analyses/admixture/output/ # dir for Admixture files (to be produced)
VCF_DIR=seqdata/vcf/ # Dir with existing VCF file(s)
SET_ID=msp3proj.all
LOOKUP=metadata/msp3_lookup.txt
FILE_IDS=( $SET_ID.mac1.FS6 $SET_ID.mac3.FS6 $SET_ID.mac3.FS7 $SET_ID.mac3.FS7 ) # File IDs for VCF files, VCF files should be: $VCF_DIR/$FILE_ID.vcf.gz

INDSEL_DIR=analyses/admixture/indsel/
mkdir -p $INDSEL_DIR
grep -P "\tmmac\t|\tmsp3\t|\tmleh\t|\tmmit\t|\tmsim\t" $LOOKUP | cut -f 3 | sort > $INDSEL_DIR/all_allinds.txt
grep -P "\tmmac\t|\tmsp3\t|\tmleh\t|\tmmit\t" $LOOKUP | cut -f 3 | sort > $INDSEL_DIR/bothclades_allinds.txt
grep -P "\tmmac\t|\tmsp3\t" $LOOKUP | cut -f 3 | sort > $INDSEL_DIR/macsp3_allinds.txt
grep -P "\tmleh\t|\tmmit\t" $LOOKUP | cut -f 3 | sort > $INDSEL_DIR/lehmit_allinds.txt

SUBSETS=(all bothclades macsp3 lehmit)
SUBSETS=(all)
for FILE_ID in ${FILE_IDS[@]}
do
	echo -e "\n\n## File ID: $FILE_ID"
	for SUBSET in ${SUBSETS[@]}
	do
		INDFILE=$INDSEL_DIR/${FILE_ID}_${SUBSET}_inds.txt
		comm -12 <(bcftools query -l $VCF_DIR/$FILE_ID.vcf.gz) $INDSEL_DIR/${SUBSET}_allinds.txt > $INDFILE
		echo -e "## Indfile: $INDFILE"
		cat $INDFILE

		sbatch -p yoderlab,common,scavenger --mem 8G -o slurm.admixture.pip.$FILE_ID.$SUBSET \
		$SCR_ADMIX $FILE_ID $VCF_DIR $PLINK_DIR $OUTDIR -i $INDFILE -o $FILE_ID.$SUBSET
	done
done


################################################################################
# rsync -avr --no-perms ~/Dropbox/scripts/genomics dcc:/datacommons/yoderlab/users/jelmer/scripts/genomics
# rsync -avr --no-perms ~/Dropbox/scripts/genomics dcc:/datacommons/yoderlab/users/jelmer/proj/msp3/scripts/
# rsync -avr --no-perms ~/Dropbox/sc_lemurs/proj/msp3/scripts/ dcc:/datacommons/yoderlab/users/jelmer/proj/msp3/scripts/
# rsync -avr --no-perms ~/Dropbox/sc_lemurs/proj/msp3/metadata/ dcc:/datacommons/yoderlab/users/jelmer/proj/msp3/metadata/
# rsync -avr dcc:/datacommons/yoderlab/users/jelmer/proj/msp3/analyses/admixture/output/*[Qt] ~/Dropbox/sc_lemurs/proj/msp3/analyses/admixture/output

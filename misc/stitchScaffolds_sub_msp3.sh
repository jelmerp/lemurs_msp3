################################################################################################################
#### STITCH SCAFFOLDS ####
ID_IN=mnor.scaffolds
ID_OUT=mnor.stitched100M
NR_N=1000
MAXLENGTH=100000000
IDENTIFIER=scaffold
REF_DIR=/datacommons/yoderlab/users/jelmer/singlegenomes/seqdata/reference/mnor/
SCAF_EXCLUDE_INFILE=$REF_DIR/scaffolds.nonAutosomal.txt # CORRECT!
SCAF_SIZES_INFILE=$REF_DIR/scaffolds_withLength.txt # MISSING!

sbatch -p yoderlab,common,scavenger -o slurm.stitchScaffolds.$ID_IN \
scripts/conversion/stitchScaffolds.sh $REF_ID_IN $REF_ID_OUT $NR_N $MAXLENGTH $REF_DIR

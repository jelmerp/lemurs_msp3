cd /datacommons/yoderlab/users/jelmer/proj/msp3

################################################################################
#### PREP INPUT ####
################################################################################
#FILE_ID=msp3proj.snapp12
#FILE_ID=msp3proj.eastwest
FILE_ID=msp3proj.eastwest2
FASTA_DIR=/work/jwp37/radseq/seqdata/fasta_full/map2msp3.paired.gatk4/byLocus.final.$FILE_ID.mac3.FS7.callableDP3.ov0.9.ovt0.8.ls100

GPHOCS_LOCUS_DIR=analyses/gphocs/input_prep.$FILE_ID
GPHOCS_INPUT_DIR=analyses/gphocs/input/
sbatch -p yoderlab,common,scavenger -o slurm.gphocs1.$FILE_ID.txt \
	scripts/gphocs/gphocs_1_createLoci.sh $FILE_ID $FASTA_DIR $GPHOCS_LOCUS_DIR $GPHOCS_INPUT_DIR


################################################################################
#### RUN ####
################################################################################
FILE_ID=msp3proj.eastwest2
#FILE_ID=msp3proj.snapp12
DIR_FOCAL=analyses/gphocs/controlfiles/reps/$FILE_ID/
NCORES=12
GPHOCS_COPY=2

for CFILE in $(ls $DIR_FOCAL/*ctrl)
do
	echo -e "\n#### Controlfile: $CFILE"
	sbatch -p yoderlab,common,scavenger -N 1 -n $NCORES -o gphocs_logfiles/slurm.gphocs_run.$(basename $CFILE).$(date +%Y%m%d-%H%M) \
		scripts/gphocs/gphocs_4_run.sh $CFILE $NCORES $GPHOCS_COPY
done




################################################################################
################################################################################
# rsync -avr jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/msp3/analyses/gphocs/output/* /home/jelmer/Dropbox/sc_lemurs/proj/msp3/analyses/gphocs/output/
# rsync -avr jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/msp3/analyses/gphocs/input/*gphocsInput.txt /home/jelmer/Dropbox/sc_lemurs/proj/msp3/analyses/gphocs/input/

# rsync -avr /home/jelmer/Dropbox/sc_lemurs/proj/msp3/analyses/gphocs/controlfiles/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/msp3/analyses/gphocs/controlfiles/
# rsync -avr /home/jelmer/Dropbox/sc_lemurs/proj/msp3/analyses/gphocs/indsel/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/msp3/analyses/gphocs/indsel/

# rsync -avr /home/jelmer/Dropbox/sc_lemurs/scripts/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/scripts/

# find analyses/gphocs/output/*log* -maxdepth 1 -mmin +$((5)) -exec rm -f {} \;
# find gphocs_logfiles/* -maxdepth 1 -mmin +$((5)) -exec rm -f {} \;


################################################################################
## To change max nr of migration bands: Changed "#define MAX_MIGS 10" in src/path.h to max 20.

## If nr of loci given in first line of file is 0, because ls didn't work (too many files), then:
# SEQFILE=analyses/gphocs/input/msp3proj.eastwest2.gphocsInput.txt
# NLOCI=$(grep "fa" $SEQFILE | wc -l)
# cat $SEQFILE | sed "s/^0$/$NLOCI/" > $SEQFILE.tmp
# cp $SEQFILE $SEQFILE.backup
# mv $SEQFILE.tmp $SEQFILE
################################################################################
##### SCAFFOLDS #####
################################################################################
grep ">" /datacommons/yoderlab/users/jelmer/singlegenomes/seqdata/reference/mnor/mnor.scaffolds.fasta > tmp.txt
cat tmp.txt | sed 's/>//g' > /datacommons/yoderlab/users/jelmer/singlegenomes/metadata/refgenome/mnor/mnor.scaffolds.txt
rm tmp.txt
cat $SCAFFOLDS | sed 's/scaffold.*size//g' > /datacommons/yoderlab/users/jelmer/singlegenomes/metadata/refgenome/mnor/mnor.scaffoldSizes.txt


################################################################################
##### JUST GET BAMSTATS #####
################################################################################
IDs=( mspp002_r01_p3c01 mspp003_r01_p3d09 mspp004_r01_p1c06 mspp005_r01_p3d05 mspp006_r01_p2g01 mspp007_r01_p3f01 mspp008_r01_p3f05 mspp009_r01_p2g09 mspp010_r01_p3c02 )
REF=/datacommons/yoderlab/users/jelmer/singlegenomes/seqdata/reference/mnor.scaffolds.fasta
BAM_DIR=/work/jwp37/radseq/seqdata/bam/mapped2msp3/paired
BAMSTATS_DIR=analyses/qc/bam/paired/map2msp3
MEM=7
PREFIX_OUT=sort.MQ30
for ID in ${IDs[@]}
do
	INPUT=$BAM_DIR/$ID.$PREFIX_OUT.bam
	sbatch -p yoderlab,common,scavenger --exclude=dcc-yoderlab-01 --mem 8G -o slurm.bamstats.$ID \
	scripts/qc/qc_bam.sh $ID $INPUT $BAMSTATS_DIR $REF $MEM
done

IDs=( mspp002_r01_p3c01 mspp003_r01_p3d09 mspp004_r01_p1c06 mspp005_r01_p3d05 mspp006_r01_p2g01 mspp007_r01_p3f01 mspp008_r01_p3f05 mspp009_r01_p2g09 mspp010_r01_p3c02 )
REF=/work/jwp37/singlegenomes/seqdata/reference/GCF_000165445.2_Mmur_3.0_genomic.fna
BAM_DIR=/work/jwp37/radseq/seqdata/bam/mapped2mmur/paired
BAMSTATS_DIR=analyses/qc/bam/paired/
MEM=7
PREFIX_OUT=sort.MQ30
for ID in ${IDs[@]}
do
	INPUT=$BAM_DIR/$ID.$PREFIX_OUT.bam
	sbatch -p yoderlab,common,scavenger --exclude=dcc-yoderlab-01 --mem 8G -o slurm.bamstats.refMur.$ID \
	scripts/qc/qc_bam.sh $ID $INPUT $BAMSTATS_DIR $REF $MEM
done


################################################################################
#### CORRECT BAM HEADER OF R99 FILES ####
################################################################################
SAMTOOLS=/datacommons/yoderlab/programs/samtools-1.6/samtools
BAM_DIR=/work/jwp37/radseq/seqdata/bam/mapped2msp3/paired
INDS_R99=( $(cat metadata/jordi.runs/20181008_sp3_IDs.txt) )
for IND in ${INDS_R99[@]}
do
	#IND=mspp016_r99_00000
	echo "Indiv ID: $IND"
	BAM=$BAM_DIR/$IND.sort.MQ30.dedup.bam
	$SAMTOOLS view -H $BAM | sed "s/SM:rad/SM:$IND/" | $SAMTOOLS reheader - $BAM > $BAM_DIR/$IND.sort.MQ30.dedup.reheader.bam
	$SAMTOOLS view -H $BAM_DIR/$IND.sort.MQ30.dedup.reheader.bam | tail -n 2
done


################################################################################
#### MAPPING MTDNA ONLY ####
################################################################################
REF=/datacommons/yoderlab/users/jelmer/seqdata/mmur_mtdna/mtdna_genome.fa
INDS_R01=( $(cat metadata/r01/samples/sampleIDs_sp3_yoderlab.txt) )
INDS=( "${INDS_R01[@]}" "${INDS_R99[@]}" )
BASEDIR=/datacommons/yoderlab/users/jelmer/radseq
FASTQ_DIR=/work/jwp37/radseq/seqdata/fastq/demult_dedup_trim2
USE_R2=TRUE
BAM_DIR=/work/jwp37/radseq/seqdata/bam/mapped2mmurMtdna/paired
GVCF_DIR=/work/jwp37/radseq/seqdata/vcf/gatk/mapped2mmurMtdna/paired/ind/gvcf
VCF_DIR_MAIN=/work/jwp37/radseq/seqdata/vcf/gatk/mapped2mmurMtdna/paired/ind/intermed
VCF_DIR_FINAL=/work/jwp37/radseq/seqdata/vcf/gatk/mapped2mmurMtdna/paired/ind/final
QC_DIR=analyses/qc/vcf/mapped2mmurMtdna/paired/ind/bcftoolsStats/output
BAMSTATS_DIR=analyses/qc/bam/paired/mmurMtdna
MINMAPQUAL=30
MEM=4
NCORES=4
GATK_VERSION=4
INTERVAL_ID=mtDNA
INTERVAL_FILE=analyses/genotyping/scaffoldLists/mtDNA.jordi.list
echo "KR911908.1" > $INTERVAL_FILE
SKIP_FILTER="-9"
SKIP_FLAGS="-MPV"
#SKIP_FLAGS="-RGFq"

for IND in ${INDS[@]}
do
	#IND=mspp002_r01_p3c01 #IND=mleh019_r01_p1h12
	echo "Indiv ID: $IND"
	sbatch -p yoderlab,common,scavenger -N 1-1 --ntasks 4 --mem-per-cpu 4G -o slurm.genoInd.map2mmurMtdna.paired.$IND \
	scripts/genotyping/gatk/run_genoInds.sh $IND $USE_R2 $REF $BASEDIR $FASTQ_DIR $BAM_DIR $GVCF_DIR $VCF_DIR_MAIN $VCF_DIR_FINAL $QC_DIR \
	$MINMAPQUAL $BAMSTATS_DIR $GATK_VERSION $INTERVAL_FILE $INTERVAL_ID $MEM $NCORES $SKIP_FILTER $SKIP_FLAGS
done

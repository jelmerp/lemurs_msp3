## Variables that wont be passed on to script:
GATK_VERSION=gatk4
MAP2=map2msp3
READ_TYPE=paired
GENOTYPING_PIPELINE_ID=$MAP2.$READ_TYPE.$GATK_VERSION

## Individuals & IDs:
FILE_ID=msp3proj # Basic file ID of VCF / dataset
SUBSET_ID=eastwest2 # ID of subset of samples
INDFILE=analyses/gphocs/indsel/$FILE_ID.$SUBSET_ID.inds.txt # List with IDs of individuals to use. Should be the same IDs in VCF files and names of bamfiles.

## Reference genome:
REF=/datacommons/yoderlab/users/jelmer/seqdata/reference/mnor/mnor.stitched100M.fasta # Reference genome fasta

## Directories:
VCF_DIR_MAIN=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/intermed # Dir with raw and intermediate VCF files
VCF_DIR_FINAL=/work/jwp37/radseq/seqdata/vcf/$MAP2.$GATK_VERSION.paired.joint/final # Dir with final filtered VCF file
VCF_QC_DIR=analyses/qc/vcf/$MAP2.$GATK_VERSION.paired.joint # Dir for VCF QC output
BAM_DIR=/work/jwp37/radseq/seqdata/bam/$MAP2/final/ # Dir with pre-existing bamfiles
FASTA_DIR=/work/jwp37/radseq/seqdata/fasta_full/$GENOTYPING_PIPELINE_ID/ # Dir with fasta files to produce
CREATELOCI_DIR=analyses/genotyping/createLoci/$GENOTYPING_PIPELINE_ID/ # Dir with e.g. bed files to produce

## Settings for defining and filtering loci:
MIN_ELEMENT_OVERLAP=0.9 # Number of bedfile elements that should overlap to create a locus, given as % of nr of samples.
MIN_ELEMENT_OVERLAP_TRIM=0.8 # Number of bedfile elements that should overlap *at each basepair-level position* at the edges of each locus, given as % of nr of samples: lower coverage ends are trimmed.
MIN_LOCUS_SIZE=100 # Minimum locus size in bp, smaller loci are not retained.
VCF2FULLFASTA_ID=ov$MIN_ELEMENT_OVERLAP.ovt$MIN_ELEMENT_OVERLAP_TRIM.ls$MIN_LOCUS_SIZE # File suffix to indicate locus production parameters
TRESHOLD_MISSING=10 # Missing data treshold for final locus selection (percentage)

## Settings for VCF filtering:
VCF_RAWFILE_SUFFIX=rawSNPs # Suffix for input VCF file, vcf file should be $VCF_DIR_MAIN/$FILE_ID.$VCF_RAWFILE_SUFFIX.vcf(.gz)
VCF_DP_MEAN=15 # Minimum mean-depth (across samples) per site -- lower will be filtered
VCF_MAC=3 # Minimum Minor Allele Count (MAC). A file without and with MAC filtering will be produced.
SELECT_INDS_BY_FILE=TRUE # Whether or not to (pre)select individuals/samples using a file with IDs (TRUE/FALSE)
FILTER_INDS_BY_MISSING=FALSE # Whether or not to remove individuals/samples with high amounts of missing data

## Settings for CallableLoci:
BAMFILE_SUFFIX=sort.MQ30* # Some samples are R1 only and not dedupped
CALLABLE_COMMAND="--minDepth 3" # (Added) Command for GATK CallableLoci: use to indicate minimum depth (and can also be used for max depth, etc)
CALLABLE_ID=DP3 # File suffix to indicate CallableLoci settings
CALLABLE_BEDFILE_SUFFIX=callable # Suffix for bedfile produced by CallableLoci

## Steps to skip in each script:
SKIP_COMMON_STEPS_VCF_FILTER="-1456789tew"
SKIP_IN_PIP_VCF_FILTER=""
SKIP_IN_VCF2FULLFASTA1="-C" #"-C" # What to skip in vcf2fullFasta1: -C: skip CallableLoci step / -A: skip Altref step / -M: skip mask step
SKIP_IN_VCF2FULLFASTA2="" #"-CIXK" # What to skip in vcf2fullFasta2: -C: skip create-loci step / -I: skip intersect-with-VCF step / -X: skip extract-loci step / -K: skip check-loci step / -S: skip select-loci step
SKIP_IN_PIP="-F" #"-FB1" #"-B1" # What to skip in pipeline script: -F: VCF file filtering / -B: skip bedfile creation / -1: skip vcf2fullFasta1.sh / -2: skip vcf2fullFasta1.sh

## Memory:
MEM_ALL=16 # Memory (GB) to request from cluster
MEM=14 # Memory (GB) to use for GATK

sbatch -p yoderlab,common,scavenger -o slurm.vcf2loci_pip.$FILE_ID.txt \
	scripts/vcf2loci/vcf2loci_pip.sh $INDFILE $FILE_ID "$SUBSET_ID" $VCF2FULLFASTA_ID $REF \
	$VCF_RAWFILE_SUFFIX $VCF_DP_MEAN $VCF_MAC $SELECT_INDS_BY_FILE $FILTER_INDS_BY_MISSING \
	$MIN_ELEMENT_OVERLAP $MIN_ELEMENT_OVERLAP_TRIM $MIN_LOCUS_SIZE $TRESHOLD_MISSING \
	"$CALLABLE_COMMAND" $CALLABLE_ID $CALLABLE_BEDFILE_SUFFIX $BAMFILE_SUFFIX \
	$VCF_DIR_MAIN $VCF_DIR_FINAL $VCF_QC_DIR $BAM_DIR $FASTA_DIR $CREATELOCI_DIR $MEM \
	"$SKIP_COMMON_STEPS_VCF_FILTER" "$SKIP_IN_PIP_VCF_FILTER" "$SKIP_IN_VCF2FULLFASTA1" "$SKIP_IN_VCF2FULLFASTA2" "$SKIP_IN_PIP"


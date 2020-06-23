IN=/home/jelmer/Dropbox/sc_lemurs/proj/msp3/seqdata/vcf/msp3proj.all.mac1.FS6.vcf.gz
OUT=/home/jelmer/Dropbox/sc_lemurs/proj/msp3/seqdata/vcf/msp3proj.all.mac1.FS6.5kb.vcf.gz
vcftools --gzvcf "$IN" --thin 5000 --recode --recode-INFO-all --stdout | gzip -c > $OUT # Thin sites, ensure min distance between SNPs

IN=/home/jelmer/Dropbox/sc_lemurs/proj/msp3/seqdata/vcf/msp3proj.all.mac3.FS6.vcf.gz
OUT=/home/jelmer/Dropbox/sc_lemurs/proj/msp3/seqdata/vcf/msp3proj.all.mac3.FS6.5kb.vcf.gz
vcftools --gzvcf "$IN" --thin 5000 --recode --recode-INFO-all --stdout | gzip -c > $OUT
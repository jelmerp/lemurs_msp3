#################################################################################################
##### SET-UP #####
#################################################################################################
rm(list = ls()); gc()
setwd('/home/jelmer/Dropbox/sc_lemurs/msp3/')
source('../scripts/PCA/PCA_adegenet_fun.R')

library(vcfR)
library(adegenet)
library(tidyverse)
library(ggpubr)
library(cowplot)
library(gdsfmt)
library(SNPRelate)

#file.ID <- 'msp3proj.all.mac1.FS6'
file.ID <- 'msp3proj.all.mac3.FS6'

## Files:
infile_inds <- '../radseq/metadata/lookup_IDshort.txt'
#infile_inds_longID <- '../radseq/metadata/r99_msp3/'
infile_IDs <- '../radseq/metadata/r99_msp3/msp3_IDs.txt'
infile_cols <- '../metadata/colors/colors.species.txt'

## Read metadata:
cols.sp.df <- read.delim(infile_cols, header = TRUE)
inds.IDs <- readLines(infile_IDs)
inds.df <- read.delim(infile_inds)
inds.df$ID.long <- inds.IDs[match(inds.df$ID.short, substr(inds.IDs, 1, 7))]
inds.df <- inds.df %>% filter(!is.na(ID.long))


#################################################################################################
##### IMPORT SNPS #####
#################################################################################################
cat("#######################################################\n")
cat("##### Reading vcf file and converting to genlight object...\n")
vcf.file <- paste0('seqdata/vcf/', file.ID, '.vcf.gz')
vcf <- read.vcfR(vcf.file)
snps <- vcfR2genlight(vcf)

inds.sel <- inds.df$ID.long
keep.rows <- rownames(as.matrix(snps)) %in% inds.sel
snps <- new('genlight', as.matrix(snps)[keep.rows, ])


#################################################################################################
##### RUN PCA #####
#################################################################################################
cat("#######################################################\n")
cat("##### Running PCA...\n")

## Run for all:
pca.res <- glPca(snps, center = TRUE, scale = TRUE, nf = 4)
pca.df <- pca.process(pca.res, inds.df, subset.ID = 'all')

## Only mmac and msp3:
inds.mmac <- inds.df %>% filter(species.short %in% c('msp3', 'mmac')) %>% pull(ID.long)
keep.rows <- rownames(as.matrix(snps)) %in% inds.mmac
snps.mmac <- new('genlight', as.matrix(snps)[keep.rows, ])
pca.res <- glPca(snps.mmac, center = TRUE, scale = TRUE, nf = 4)
pca.df.mmac <- pca.process(pca.res, inds.df, subset.ID = 'mmacmsp3',
                           ID.type = 'ID.long', pca.df.ID = paste0(file.ID, '_mmacmsp3'))

## Without mmur:
inds.mur <- c('mmur001', 'mmur002', 'mmur006')
inds.noMur <- inds.df %>% filter(! ID.short %in% inds.mur) %>% pull(ID.long)
keep.rows <- rownames(as.matrix(snps)) %in% inds.noMur
snps.noMur <- new('genlight', as.matrix(snps)[keep.rows, ])

pca.res <- glPca(snps.noMur, center = TRUE, scale = TRUE, nf = 4)
pca.df.noMur <- pca.process(pca.res, inds.df, subset.ID = 'noMur',
                            ID.type = 'ID.long', pca.df.ID = paste0(file.ID, '_noMur'))

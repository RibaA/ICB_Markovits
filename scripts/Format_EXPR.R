## load libraries

library(data.table)
library(R.utils)
library(readr)

args <- commandArgs(trailingOnly = TRUE)
#input_dir <- args[1]
#output_dir <- args[2]

input_dir <- "data/input"
output_dir <- "data/output"

tpm = as.matrix( read.csv( file.path(input_dir, "EXP_TPM.tsv"), stringsAsFactors=FALSE , sep="\t" , header=TRUE ) )

#############################################################################
#############################################################################

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
tpm = log2( tpm[ , colnames(tpm) %in% case[ case$expr %in% 1 , ]$patient ] + 0.001 )

## Fix annotation --> convert ENTREZ ID to gene symbol ID
annot <- read_tsv( file = file.path(input_dir, "Human.GRCh38.p13.annot.tsv") ) 
annot <- as.data.frame(annot)
annot <- annot[!duplicated(annot$Symbol), ]
annot <- annot[order(annot$GeneID), ]
tpm <- tpm[rownames(tpm) %in% annot$GeneID, ]
rownames(tpm) <- annot$Symbol

write.table( tpm , file= file.path(output_dir, "EXPR.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )

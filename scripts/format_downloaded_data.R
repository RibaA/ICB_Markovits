## load libraries

library(GEOquery)
library(data.table)
library(readxl)
library(readr)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
#work_dir <- args[1]
work_dir <- "data"

# CLIN.txt
dat <- getGEO(filename = file.path(work_dir, 'GSE160638_series_matrix.txt'), getGPL = FALSE)

# Extract clinical/phenotype (metadata / sample info)
clin0 <- pData(dat)
clin0 <- as.data.frame(clin0)
clin0 <- clin[order(rownames(clin0)), ]


# Extract clinical/phenotype (metadata / sample info)
clin1 <- read_excel(file.path(work_dir, 'cir-22-0184_table_s2_suppst2.xlsx'), sheet = 1, skip = 2)
clin1 <- as.data.frame(clin1)

# merge two clinical data
clin0$patient_id <- sub(".*\\((PD1_[0-9]+|TIL_[0-9]+)\\).*", "\\1", clin0$title)
clin0$gsm_id <- rownames(clin0)

clin1$patient_id <- clin1$'...1'

clin <- merge(
  clin1,
  clin0[, c("patient_id", "gsm_id")],
  by = "patient_id",
  all.x = TRUE
)

write.table(clin, file=file.path(work_dir, 'CLIN.txt'), sep = "\t" ,  row.names = FALSE)

# EXP_TPM.tsv 
expr <- read_tsv( file = file.path(work_dir, "GSE160638_norm_counts_TPM_GRCh38.p13_NCBI.tsv") ) 
expr <- as.data.frame(expr)
expr <- expr[order(expr$GeneID), ]
rownames(expr) <- expr$GeneID
expr <- expr[, -1]
expr <- expr[, order(colnames(expr))]

write.table(expr, file=file.path(work_dir, 'EXP_TPM.tsv'), sep = "\t" , quote = FALSE , row.names = TRUE, col.names=TRUE)

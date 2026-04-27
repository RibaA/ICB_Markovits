## load libraries
library(stringr)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)
#input_dir <- args[1]
#output_dir <- args[2]
#annot_dir <- args[3]

input_dir <- "data/input"
output_dir <- "data/output"
annot_dir <- "data/annot"

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin <- read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , header=TRUE )
rownames(clin) <- clin$gsm_id
cols <- c('gsm_id', 'Gender', 'Age.at.treatment',  'Response', 'Cohort', 'PFS.T', 'PFS.E', 'OS.T', 'OS.E')

clin <- clin[, c(cols, colnames(clin)[!colnames(clin) %in% cols])]
colnames(clin)[colnames(clin) %in% cols] <- c('patient',  'sex', 'age', "recist" , "drug_type" ,
                                               "t.pfs", "pfs", 't.os', 'os')

new_cols <- c( "primary" , 'histo', "stage" ,  "response" ,  "dna" , 
               "rna", "rna.info", "response.other.info")
clin[new_cols] <- NA

clin$drug_type <- ifelse(clin$drug_type == 'PD1', 'PD-1/PD-L1', 'ACT') 
clin$rna <- 'rnaseq'
clin$rna.info <- 'tpm'
clin$primary <- 'Melanoma'

clin$response = Get_Response( data=clin )

# Tissue and drug annotation
annotation_tissue <- read.csv(file=file.path(annot_dir, 'curation_tissue.csv'))
clin <- annotate_tissue(clin=clin, study='Markovits', annotation_tissue=annotation_tissue, check_histo=FALSE)

annotation_drug <- read.csv(file=file.path(annot_dir, 'curation_drug.csv'))
clin <- add_column(clin, treatmentid=clin$drug_type, .after='tissueid')

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )


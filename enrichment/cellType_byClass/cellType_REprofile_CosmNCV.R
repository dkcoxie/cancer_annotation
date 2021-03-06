######################################################################
######################################################################
##
## Rebecca Lowdon | 2,28 Oct 2015
## 
## This code reads in the COSMIC SNP annotations calculated from 
## the counts.sh script [INPUT] and assembles them into a matrix 
## with 5 columns: EID (#), COSMIC unique ID, regulatory, transcribed, and silent.
## The last 3 columns have a value of 0 or 1 depending on which class 
## the SNP falls in the given EID annotation file.
##
## Usage: 
## * interactive: edit line 22 & 27 to include file with list of input files
## * command line: /apps/bin/Rscript cellType_REprofile_CosmNCV.R <file list>
##
######################################################################
######################################################################

library(dplyr)
library(ggplot2)
library(reshape2)
# args<-commandArgs(TRUE)

#####
## Read in an assemble data into matrix m

files <- paste("test_in")  #args[1]
fl <- read.table(files,header=FALSE)

d <- matrix( ncol = 5)
colnames(d)<-c("EID","CosmID","regulatory","transcribed","silent")
colVect <- c("NULL","NULL","NULL","factor","NULL","factor","factor","factor")

#for( i in 1:length(fl$V1) ){
for( i in 1:3 ){
  try(dat <- read.delim2(paste(fl$V1[i]),skip=1,header=FALSE,colClasses = colVect),TRUE)
  try(dat$V9 <- c(i))
  try(dat <- cbind(dat[,5],dat[,1],dat[,2:4]))
  try(colnames(dat)<-c("EID","CosmID","regulatory","transcribed","silent"))
  try(d <- rbind(d, dat),TRUE)
}  

d <- filter(d, !is.na(d[,1]))  ## to remove the row of "NA" created when matrix initialized
m <- melt(d,measure.vars = c(3,4,5))

#####
## Plot SNPs x element class, split by EID

g <- ggplot(m, aes(variable, CosmID)) + geom_tile(aes(fill=value)) + facet_wrap(~EID)
g <- g + theme(axis.text.y = element_blank(), axis.text.x=element_text(angle=30,vjust=0.5)) + 
  scale_x_discrete(name="Regulatory element class") 

png("top3EID_Cosm_REprofiles.png")
g
dev.off();

#####
## Plot EID x unique ID, split by class

g <- ggplot(m, aes(EID, CosmID)) + geom_tile(aes(fill=value)) + facet_wrap(~variable)
g <- g + theme(axis.text.y = element_blank())

png("top3EID_by_Cosm_profiles.png")
g
dev.off();

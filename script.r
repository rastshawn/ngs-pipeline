# make sure the virus name is passed in as a command line argument
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (virus name: ex: 'TYF5521' without quotes)", call.=FALSE)
}
name <- args[1]

# import the files
coverage <- read.delim(paste(name, "_coverage.txt", sep=""), header=FALSE)
precoverage <- read.delim(paste(name, "_precoverage.txt", sep=""), header=FALSE)

# calculate relevant numbers
length <- length(coverage$V1)
coverage_mean <-mean(coverage$V3)
precoverage_mean <-mean(precoverage$V3)

# write the summaries to a file
outputFilename <- paste(name, "_r-output.txt", sep="")
sink(outputFilename)
print("Coverage summary:")
summary(coverage)

print("")

print("Precoverage summary:")
summary(precoverage)
sink()

# create the charts
png(paste(name, "_coverage-hist.png", sep=""))
hist(coverage$V3, xlab="Coverage", main=paste("Coverage Histogram:", name), na.rm=TRUE, col=blues9)
dev.off()

png(paste(name, "_precoverage-hist.png", sep=""))
hist(precoverage$V3, xlab="Coverage", main=paste("Pre-Coverage Histogram:", name), na.rm=TRUE, col=blues9)
dev.off()

png(paste(name, "_coverage-position.png", sep=""))
plot(coverage$V2, coverage$V3, xlab="Nucleotide Position", ylab="Coverage", main = paste(name, "Coverage"), type="l", NA.rm=TRUE, xlim = c(0,length), ylim=c(0,1500))
dev.off()

png(paste(name, "_precoverage-position.png", sep=""))
plot(precoverage$V2, precoverage$V3, xlab="Nucleotide Position", ylab="Coverage", main = paste(name, "Pre-Coverage"), type="l", NA.rm=TRUE, xlim = c(0,length), ylim=c(0,1500))
dev.off()

print(paste("R script completed. It is probably okay to ignore warnings - make sure the graphs make sense, and check the summaries in", outputFilename))
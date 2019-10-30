
scaf.file <- '/home/jelmer/Dropbox/sc_lemurs/singlegenomes/seqdata/ref/mnor/Mnor.scaffolds.txt'
scafs <- readLines(scaf.file)

first <- rep(1, length(scafs))
last <- gsub('scaffold.*size', '', scafs)

scafs.intervals <- cbind(scafs, first, last)

scafs.intervals.file <- '/home/jelmer/Dropbox/sc_lemurs/singlegenomes/seqdata/ref/mnor/Mnor.scaffolds.intervals.txt'
write.table(scafs.intervals, scafs.intervals.file,
            col.names = FALSE, row.names = FALSE, sep = '\t', quote = FALSE)

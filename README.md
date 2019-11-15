# itbi_ex6_ad
Solutions for exercise 6 of Introduction to Bioinformatics for the DSIT M.Sc.

ItBI Exercise 6
First, installing prerequisite packages since the VM seemed to have some problems.
Linux needed packages
`sudo apt-get -y install build-essential curl git cmake tabix`
This is my own link for the perl5libs
`cpan App::cpanminus`
`sudo chown -R nikolas /home/nikolas/.cpanm`
`cpanm Bio::SeqIO`
`export PERL5LIB=$(pwd)/../vcftools/src/perl/:$PATH`
Installing VCF tools
`git clone https://github.com/vcftools/vcftools`
`cd vcftools`
`./autogen.sh`
`./configure`
`make`
`sudo make install`
`cd ..`
Installing SAMtools
`wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2`
`tar -jxf samtools-1.9.tar.bz2`
`rm -r samtools-1.9.tar.bz2`
`cd samtools-1.9`
`./configure`
`make`
`sudo make install`
`export PATH=$(pwd):$PATH`
`cd ..`
Installing BAMtools
`git clone https://github.com/pezmaster31/bamtools`
`cd bamtools`
`mkdir build`
`cd build`
`cmake ..`
`make`
`sudo make install`
`cd ../..`
Installing BEDtools
`wget https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools-2.28.0.tar.gz`
`tar -zxvf bedtools-2.28.0.tar.gz`
`rm -r bedtools-2.28.0.tar.gz`
`cd bedtools2`
`make`
`sudo make install`
`cd ..`
Moving onto the exercise itself
Downloading and extracting
`wget https://eclass.uoa.gr/modules/document/file.php/DI425/exercises/Intro2Bio6.tar.gz`
`tar -zxvf Intro2Bio6.tar.gz`
`rm -r Intro2Bio6.tar.gz`
Assignment 1. Each sample has 10k reads.
A for loop iterates over all the fastq files in directory, printing their name and then the lines are counted.
Since the fastq format presents a read using 4 lines, the output is divided by 4 and passed to the bash calculator to get a proper arithmetic result.
`for i in *.fastq;`
`do`
`echo $i`
`echo $(cat *.fastq|wc -l)/4 | bc`
`done`
Assignment 2.
The -c flag is for counting reads and not reporting them and the -f 2 flag reports only reads that were mapped correctly, as shown in the documentation.
`samtools view -c -f 2 *.sam`
The above command works only for reads that were properly mapped in a pair though. The following one reports all reads that were not any of the following:
Unmapped
Secondary aligned
Supplementar(ily) aligned
It reports or the rest, because the -F flag is the exclusion flag. The result is 9818 reads
`samtools view -F 0x904 -c *.sam`
If one wants to report only the mapped reads, they could use the following command: The result remains 9818
`samtools view -F 0x4 -c *.sam`
Assignment 3.
First, let's create a variable containing the SAM file name
`sam_file=$(ls | grep "sam$")`
Then convert to BAM. The S flag indicates input is in SAM format and the b flag indicates we want the BAM output. Shamelessly stolen from http://seqanswers.com/forums/showthread.php?t=6050
`samtools view -Sb  $sam_file  >  sample.bam`
Assignment 4.
https://www.biostars.org/p/260419/
`samtools sort sample.bam > sorted.bam`
`stat *.bam`
There indeed is a size difference. Simple google searching reveals that compression is better in .bam when similar reads are grouped together (Sorted).
http://seqanswers.com/forums/showthread.php?t=13652
https://www.biostars.org/p/150457/ An answer by Sean himself
Just to make sure, we also report the number of reads in each file. They remain at 10000
`for i in *.bam;`
`do`
`echo $i`
`samtools view -c $i`
`done`
Assignment 5.
`samtools index sorted.bam`
Indexing is only possible for sorted BAMs. The index is a hash like structure that allows easy access to the BAM file. I assume that creating it would
take much more time without beforehand sorting and is therefore disabled. While I did not find any topics specifically adressing this, here's some more
biostars
https://www.biostars.org/p/15847/
https://www.biostars.org/p/319730/
http://www.htslib.org/doc/samtools.html
Assignment 6.
https://www.biostars.org/p/5165/
`genomeCoverageBed -ibam sorted.bam -g human_g1k_v37_chr20.fasta > coverage.txt`
Assignment 7.
http://quinlanlab.org/tutorials/bedtools/bedtools.html#producing-bedgraph-output
`genomeCoverageBed -ibam sorted.bam -g human_g1k_v37_chr20.fasta -bg > coverage.bg`
Assignment 8.
https://josephcckuo.wordpress.com/2016/11/18/splitting-reads-in-a-bam-file-by-strands/
Flag 16 returns or excludes reverse strand mapped files. If we exclude reverse strand mapped files, we get forward and vice versa.
`samtools view -bh -F 16 sample.bam > samplef.bam`
`samtools view -bh -f 16 sample.bam > sampler.bam`
Assignment 9.
https://bedtools.readthedocs.io/en/latest/content/tools/slop.html
i for input, r for right append, g for genome,l for left
`bedtools slop -i TargetRegion.bed -g human_g1k_v37.genome -r 100 -l 0 > TargetRegion.100bp.bed`
Assignment 10.
We need to sort before merging (error in the beginning)
`bedtools sort -i TargetRegion.100bp.bed > TargetRegion.100bp.sorted.bed`
https://bedtools.readthedocs.io/en/latest/content/tools/merge.html
`bedtools merge -i TargetRegion.100bp.sorted.bed > TargetRegion.100bp.merged.bed`
Assignment 11.
https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html
`bedtools intersect -abam sorted.bam -b TargetRegion.100bp.merged.bed > sorted_intersected.bam`
Only 104 reads remain, as printed by the following command
`samtools view -F 0x4 -c sorted_intersected.bam`
Assignment 12.
Blindly following instructions
`for i in *.vcf`
`do`
`bgzip $i`
`tabix -p vcf $i.gz`
`done`
Common: 723, Unique to A: 551 and unique to B:565
`vcf-compare A.vcf.gz B.vcf.gz > vcf_compare_output.txt`

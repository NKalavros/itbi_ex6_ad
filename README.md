# ItBI Exercise 6.<br><br>
## First, installing prerequisite packages since the VM seemed to have some problems.<br><br>
### Linux needed packages.<br><br>
`sudo apt-get -y install build-essential curl git cmake tabix`<br>
### This is my own link for the perl5libs.<br><br>
`cpan App::cpanminus`<br>
`sudo chown -R nikolas /home/nikolas/.cpanm`<br>
`cpanm Bio::SeqIO`<br>
`export PERL5LIB=$(pwd)/../vcftools/src/perl/:$PATH`<br>
### Installing VCF tools.<br><br>
`git clone https://github.com/vcftools/vcftools`<br>
`cd vcftools`<br>
`./autogen.sh`<br>
`./configure`<br>
`make`<br>
`sudo make install`<br>
`cd ..`<br>
### Installing SAMtools.<br><br>
`wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2`<br>
`tar -jxf samtools-1.9.tar.bz2`<br>
`rm -r samtools-1.9.tar.bz2`<br>
`cd samtools-1.9`<br>
`./configure`<br>
`make`<br>
`sudo make install`<br>
`export PATH=$(pwd):$PATH`<br>
`cd ..`<br>
### Installing BAMtools.<br><br>
`git clone https://github.com/pezmaster31/bamtools`<br>
`cd bamtools`<br>
`mkdir build`<br
`cd build`<br>
`cmake ..`<br>
`make`<br>
`sudo make install`<br>
`cd ../..`<br>
### Installing BEDtools.<br><br>
`wget https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools-2.28.0.tar.gz`<br>
`tar -zxvf bedtools-2.28.0.tar.gz`<br>
`rm -r bedtools-2.28.0.tar.gz`<br>
`cd bedtools2`<br>
`make`<br>
`sudo make install`<br>
`cd ..`<br>
## Moving onto the exercise itself.<br><br>
### Downloading and extracting.<br><br>
`wget https://eclass.uoa.gr/modules/document/file.php/DI425/exercises/Intro2Bio6.tar.gz`<br><br>
`tar -zxvf Intro2Bio6.tar.gz`<br>
`rm -r Intro2Bio6.tar.gz`<br>
### Assignment 1. Each sample has 10k reads.<br><br>
#### A for loop iterates over all the fastq files in directory, printing their name and then the lines are counted. Since the fastq format presents a read using 4 lines, the output is divided by 4 and passed to the bash calculator to get a proper arithmetic result.<br><br>
`for i in *.fastq;`<br>
`do`<br>
`echo $i`<br>
`echo $(cat *.fastq|wc -l)/4 | bc`<br>
`done`<br>
### Assignment 2.<br><br>
#### The -c flag is for counting reads and not reporting them and the -f 2 flag reports only reads that were mapped correctly, as shown in the documentation.The bwlow command works only for reads that were properly mapped in a pair though. The next one reports all reads that were not any of the following:<br><br>
`samtools view -c -f 2 *.sam`<br>
#### 1. Unmapped.
#### 2. Secondary aligned.
#### 3. Supplementar(ily) aligned.
#### It reports or the rest, because the -F flag is the exclusion flag. The result is 9818 reads.<br><br>
`samtools view -F 0x904 -c *.sam`<br>
#### If one wants to report only the mapped reads, they could use the following command: The result remains 9818.<br><br>
`samtools view -F 0x4 -c *.sam`<br>
### Assignment 3.<br><br>
#### First, let's create a variable containing the SAM file name.<br><br>
`sam_file=$(ls | grep "sam$")`<br>
#### Then convert to BAM. The S flag indicates input is in SAM format and the b flag indicates we want the BAM output. Shamelessly stolen from http://seqanswers.com/forums/showthread.php?t=6050.<br><br>
`samtools view -Sb  $sam_file  >  sample.bam`<br>
### Assignment 4.<br><br>
#### https://www.biostars.org/p/260419/.<br><br>
`samtools sort sample.bam > sorted.bam`<br>
`stat *.bam`<br>
#### There indeed is a size difference. Simple google searching reveals that compression is better in .bam when similar reads are grouped together (Sorted).<br><br>
#### 1. http://seqanswers.com/forums/showthread.php?t=13652.
#### 2. https://www.biostars.org/p/150457/ An answer by Sean himself.
#### Just to make sure, we also report the number of reads in each file. They remain at 10000.<br><br>
`for i in *.bam;`<br>
`do`<br>
`echo $i`<br>
`samtools view -c $i`<br>
`done`<br>
### Assignment 5.<br><br>
`samtools index sorted.bam`<br>
#### Indexing is only possible for sorted BAMs. The index is a hash like structure that allows easy access to the BAM file. I assume that creating it would take much more time without beforehand sorting and is therefore disabled. While I did not find any topics specifically adressing this, here's some more biostars.<br><br>
#### 1. https://www.biostars.org/p/15847/.
#### 2. https://www.biostars.org/p/319730/.
#### 3. http://www.htslib.org/doc/samtools.html.
### Assignment 6.<br><br>
#### https://www.biostars.org/p/5165/.<br><br>
`genomeCoverageBed -ibam sorted.bam -g human_g1k_v37_chr20.fasta > coverage.txt`<br>
### Assignment 7.<br><br>
#### http://quinlanlab.org/tutorials/bedtools/bedtools.html#producing-bedgraph-output.<br><br>
`genomeCoverageBed -ibam sorted.bam -g human_g1k_v37_chr20.fasta -bg > coverage.bg`<br>
### Assignment 8.<br><br>
#### https://josephcckuo.wordpress.com/2016/11/18/splitting-reads-in-a-bam-file-by-strands/.<br><br>
#### Flag 16 returns or excludes reverse strand mapped files. If we exclude reverse strand mapped files, we get forward and vice versa.<br><br>
`samtools view -bh -F 16 sample.bam > samplef.bam`<br>
`samtools view -bh -f 16 sample.bam > sampler.bam`<br>
### Assignment 9.<br><br>
#### https://bedtools.readthedocs.io/en/latest/content/tools/slop.html.<br><br>
#### i for input, r for right append, g for genome,l for left.<br><br>
`bedtools slop -i TargetRegion.bed -g human_g1k_v37.genome -r 100 -l 0 > TargetRegion.100bp.bed`<br>
### Assignment 10.<br><br>
#### We need to sort before merging (error in the beginning).<br><br>
`bedtools sort -i TargetRegion.100bp.bed > TargetRegion.100bp.sorted.bed`<br>
#### https://bedtools.readthedocs.io/en/latest/content/tools/merge.html.<br><br>
`bedtools merge -i TargetRegion.100bp.sorted.bed > TargetRegion.100bp.merged.bed`<br>
### Assignment 11.<br><br>
#### https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html.<br><br>
`bedtools intersect -abam sorted.bam -b TargetRegion.100bp.merged.bed > sorted_intersected.bam`<br>
#### Only 104 reads remain, as printed by the following command.<br><br>
`samtools view -F 0x4 -c sorted_intersected.bam`<br>
### Assignment 12.<br><br>
#### Blindly following instructions.<br><br>
`for i in *.vcf`<br>
`do`<br>
`bgzip $i`<br>
`tabix -p vcf $i.gz`<br>
`done`<br>
### Common: 723, Unique to A: 551 and unique to B:565.<br><br>
`vcf-compare A.vcf.gz B.vcf.gz > vcf_compare_output.txt

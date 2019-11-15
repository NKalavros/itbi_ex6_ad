sudo apt-get -y install build-essential curl git cmake tabix
cpan App::cpanminus
sudo chown -R nikolas /home/nikolas/.cpanm
cpanm Bio::SeqIO
export PERL5LIB=$(pwd)/../vcftools/src/perl/:$PATH
git clone https://github.com/vcftools/vcftools
cd vcftools
./autogen.sh
./configure
make
sudo make install
cd ..
wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
tar -jxf samtools-1.9.tar.bz2
rm -r samtools-1.9.tar.bz2
cd samtools-1.9
./configure
make
sudo make install
export PATH=$(pwd):$PATH
cd ..
git clone https://github.com/pezmaster31/bamtools
cd bamtools
mkdir build
cd build
cmake ..
make
sudo make install
cd ../..
wget https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools-2.28.0.tar.gz
tar -zxvf bedtools-2.28.0.tar.gz
rm -r bedtools-2.28.0.tar.gz
cd bedtools2
make
sudo make install
cd ..
wget https://eclass.uoa.gr/modules/document/file.php/DI425/exercises/Intro2Bio6.tar.gz
tar -zxvf Intro2Bio6.tar.gz
rm -r Intro2Bio6.tar.gz
for i in *.fastq;
do
echo $i
echo $(cat *.fastq|wc -l)/4 | bc
done
samtools view -c -f 2 *.sam
samtools view -F 0x904 -c *.sam
samtools view -F 0x4 -c *.sam
sam_file=$(ls | grep "sam$")
samtools view -Sb  $sam_file  >  sample.bam
samtools sort sample.bam > sorted.bam
stat *.bam
for i in *.bam;
do
echo $i
samtools view -c $i
done
samtools index sorted.bam
genomeCoverageBed -ibam sorted.bam -g human_g1k_v37_chr20.fasta > coverage.txt
genomeCoverageBed -ibam sorted.bam -g human_g1k_v37_chr20.fasta -bg > coverage.bg
samtools view -bh -F 16 sample.bam > samplef.bam
samtools view -bh -f 16 sample.bam > sampler.bam
bedtools slop -i TargetRegion.bed -g human_g1k_v37.genome -r 100 -l 0 > TargetRegion.100bp.bed
bedtools sort -i TargetRegion.100bp.bed > TargetRegion.100bp.sorted.bed
bedtools merge -i TargetRegion.100bp.sorted.bed > TargetRegion.100bp.merged.bed
bedtools intersect -abam sorted.bam -b TargetRegion.100bp.merged.bed > sorted_intersected.bam
samtools view -F 0x4 -c sorted_intersected.bam
for i in *.vcf
do
bgzip $i
tabix -p vcf $i.gz
done
vcf-compare A.vcf.gz B.vcf.gz > vcf_compare_output.txt
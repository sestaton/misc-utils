# This is a .bashrc for my work machine 
# (this configuration is for bioinformatics-related tasks)
#
# Author: S. Evan Staton

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#
# command line utils
export PATH=$PATH:/usr/local/bioinfo/filo/latest
alias stats='/usr/local/bioinfo/filo/latest/stats'                # NB: there is a 'stats' program in AMOS for computing assembly stats
                                                                  #     there is also a 'stats' program with the RSA-tools package

#
# library paths to load
export LD_LIBRARY_PATH=/usr/local/bioinfo/sra/sra_sdk-2.3.2-4/linux/gcc/dyn/x86_64/dbg/lib     # for the NCBI sra-toolkit

# perlbrew
source ~/perl5/perlbrew/etc/bashrc

# pythonpath
export PYTHONPATH=/usr/local/bioinfo/screed/screed/build/lib:/usr/local/bioinfo/khmer/khmer/python

#
# locally installed bioinfo apps
#
export PATH=$PATH:/usr/local/bioinfo/genometools/latest           # genometools-1.4.1
export PATH=$PATH:/usr/local/bioinfo/mcl/latest                   # mcl-12-135
export PATH=$PATH:/usr/local/bioinfo/emboss/latest                # emboss-6.5.7
export PATH=$PATH:/usr/local/bioinfo/paml/latest                  # paml-4.6
export PATH=$PATH:/usr/local/bioinfo/muscle/latest                # muscle-3.8.31, link is "muscle"
export PATH=$PATH:/usr/local/bioinfo/raxml/latest                 # raxml-7.3.4, link is "raxml" ==> SSE3, pthreads version compiled
export PATH=$PATH:/usr/local/bioinfo/prank/latest                 # prank-0.120716
export PATH=$PATH:/usr/local/bioinfo/cdbfasta/latest              # cdbfasta-0.99
export PATH=$PATH:/usr/local/bioinfo/fastqc/latest                # fastqc-0.10.1
export PATH=$PATH:/usr/local/bioinfo/clustalw/latest              # we need this in the PATH before seaview, which has its own clustalw
#export PATH=$PATH:/usr/local/bioinfo/seaview/latest               # seaview-4.3.5
export PATH=$PATH:/usr/local/bioinfo/pal2nal/latest               # pal2nal-v14
export PATH=$PATH:/usr/local/bioinfo/phylip/latest                # phylip-3.69
export PATH=$PATH:/usr/local/bioinfo/ncbi-blast/latest            # BLAST-2.2.26
export PATH=$PATH:/usr/local/bioinfo/ncbi-blast+/latest           # BLAST+-2.2.27
#export PATH=$PATH:/usr/local/bioinfo/clustalw/latest              # clustalw-2.1
export PATH=$PATH:/usr/local/bioinfo/kmer/kmer/trunk/meryl
export PATH=$PATH:/usr/local/bioinfo/hyphy/latest                 # HyPhy 
export PATH=$PATH:/usr/local/bioinfo/samtools/latest              # SAMtools-0.1.18-dev
export PATH=$PATH:/usr/local/bioinfo/tabix/latest                 # tabix-0.2.6 ==> location of tabix and bgzip
export PATH=$PATH:/usr/local/bioinfo/paup                         # PAUP-4.0b10, link is "paup"
export PATH=$PATH:/usr/local/bioinfo/vcftools/latest              # Vcftools-0.1.9.1
export PATH=$PATH:/usr/local/bioinfo/exonerate/latest             # Exonerate-2.2.0
export PATH=$PATH:/usr/local/bioinfo/blat/latest                  # BLAT-v35
export PATH=$PATH:/usr/local/bioinfo/hmmer/latest                 # HMMER 3.1b, updated 7-13-13
export PATH=$PATH:/usr/local/bioinfo/bioawk/latest                # bioawk-20110810, link is "bioawk"
export PATH=$PATH:/usr/local/bioinfo/minia/latest
export PATH=$PATH:/usr/local/bioinfo/pagan/latest                 # Pagan-0.47
export PATH=$PATH:/usr/local/bioinfo/mummer/latest                # MUMmer-3.23
export PATH=$PATH:/usr/local/bioinfo/amos/latest                  # AMOS-3.1.0, location of minimus2, hawkeye, etc.
                                                                  # ====> Install boost, boost-devel, boost-graph, and MUMmer first. Then,
                                                                  # ====> add "#include <unistd.h> to the top of amos/src/Align/find-tandem.cc
export PATH=$PATH:/usr/local/bioinfo/seqtk/latest
#export PATH=$PATH:/usr/local/bioinfo/zorro/latest                 # Zorro-2.2
export PATH=$PATH:/usr/local/bioinfo/bowtie/latest                # Bowtie-0.12.8
export PATH=$PATH:/usr/local/bioinfo/bowtie2/latest               # Bowtie2-2.0.0-beta7
export PATH=$PATH:/usr/local/bioinfo/facs/latest                  # FACS-0.1
export PATH=$PATH:/usr/local/bioinfo/cutadapt/latest              # cutadapt-1.2.1
export PATH=$PATH:/usr/local/bioinfo/trim_galore/latest           # trim_galore-0.2.7
export PATH=$PATH:/usr/local/bioinfo/jellyfish/latest             # jellyfish-1.6.1
export PATH=$PATH:/usr/local/bioinfo/khmer/khmer/scripts           # khmer-beta
#export PATH=$PATH:/usr/local/bioinfo/sra/latest                   # sra-sdk 2.3.2-4 # something not right with lib paths
export PATH=$PATH:/usr/local/bioinfo/pagan-msa/latest             # PAGAN v0.47
export PATH=$PATH:/usr/local/bioinfo/gicl/mgblast                 # mgblast-2.2.14; it's not clear this if this is being developed any more

#
# convenience methods for commonly used programs
#
alias run_sate='python /usr/local/bioinfo/sate/latest/run_sate.py'            # sate-2.2.4
alias prinseq='perl /usr/local/bioinfo/prinseq/latest/prinseq-lite.pl'
alias modeltest='java -jar /usr/local/bioinfo/jmodeltest/jmodeltest-2.1.1/jModelTest.jar' # jModelTest 2.1.1 

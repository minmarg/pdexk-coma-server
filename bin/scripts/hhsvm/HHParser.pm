package HHParser;
use warnings;
use strict;
use File::Basename;
use IO::File;
require Exporter;
@Parsers::ISA    = qw(Exporter);

# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-05-09 17:39:58 +0300 (Sat, 09 May 2009) $
# $Revision: 66 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/HHParser.pm $
# ==============================================================================

# ==============================================================================
# Returns a reference to hash
# %main_obj = (
#              query => "PF00002",
#              header => "7 transmembrane receptor (Secretin family)",
#              match_columns => 293,
#              used_no_of_seqs => 117,
#              all_no_of_seqs => 762,
#              neff => 6.6,
#              searched_HMMs => 13774,
#              hits =>   {1 => ####, ...}
#              aligns => {1 => ######, ...}
#              );
# 
#  Hits and aligns point to the structures showed bellow. 
# 
# #### my %obj = (number => 1, 
#             template => "d1u19a_", 
#             prob => 98.8, 
#             evalue => 8.9E-09, 
#             pvalue => 6.5E-13, 
#             score => 63.7, 
#             ss => 6.9, 
#             cols => 244, 
#             query_hmm_begin => 14, 
#             query_hmm_end => 292, 
#             template_hmm_begin => 50, 
#             template_hmm_end => 312, 
#             hierarchy => "f.13.1.2"); #Nan!
# ####### my %obj = 
#         (
#             match => "++.=.+..+-|.++.-..+..........+.+++.+--..=|+++.-.+", 
#             q_cons => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_cons => "~v~W~iYPi~y~l~~~g~~~~~~~~~~~~y~i~D~i~K~~FG~~i~~~a", 
#             q_seq => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_seq => "VILWAIYPFIWLLGPPGVALLTPTVDVALIVYLDLVTKVGFGFIALDAA"
#         );


sub parse_hh_out
{
    my($input) = @_;

    my $handle = new IO::File;

    my $hh_obj;

    if($handle->open("< $input"))
    {
        my @data_header;
        my @data_hits;
        my @data_aligns;
        
        my $stop = 0;
        
        while((!$stop) && defined(my $line = <$handle>))
        {
            if($line !~ /^\n$/)
            {
                chomp($line);
                push(@data_header, $line);
            }
            else
            {
                $stop = 1;
            }
        }   

        my $main_hhout_obj = parse_hh_header(\@data_header);
        
        if(! defined ($main_hhout_obj->{error}))
        {
            $stop = 0;
        
            while((!$stop) && defined(my $line = <$handle>))
            {
                if($line !~ /^\n$/)
                {
                    chomp($line);
                    push(@data_hits, $line);
                }
                else
                {
                    $stop = 1;
                }
            }
            
            $main_hhout_obj->{hits} = parse_hh_hits(\@data_hits);
            
            $stop = 0;
            
            while((!$stop) && defined(my $line = <$handle>))
            {
                if($line !~ /Done!/)
                {
                    chomp($line);
                    push(@data_aligns, $line);
                }
                else
                {
                    $stop = 1;
                }
            }
            
            my $aligns = parse_hh_aligns(\@data_aligns, $input);
            if(!ref($aligns))
            {
                die "ERR: $0: $input: $aligns!\n";
            }
            
            $main_hhout_obj->{aligns} = $aligns;
        }
        else
        {
            die "ERR: $0: $input: $main_hhout_obj->{error}!\n";
        }
        
        $hh_obj = $main_hhout_obj;
        
        $handle->close();
    }
    else
    {
        die "ERR: $0: Cannot open INPUT file: $input!";
    }

    return $hh_obj;
}

# ==============================================================================
# Accepts
# 
# Query         PF00002 7tm_2:  7 transmembrane receptor (Secretin family);  InterPro: IPR000832   G-protein-coupled receptors, GPCRs, constitute a vast protein family that encompasses a wide range of functions (including various autocrine, paracrine and endocrine processes). They show considerable diversity at the sequence level, on the basis of which they can be separated into distinct groups. We use the term clan to describe the GPCRs, as they embrace a group of families for which there are indications of evolutionary relationship, but between which there is no statistically significant similarity in sequence . The currently known clan members include the rhodopsin-like GPCRs, the secretin-like GPCRs, the cAMP receptors, the fungal mating pheromone receptors, and the metabotropic glutamate receptor family. There is a specialised database for GPCRs: http://www.gpcr.org/7tm/.    The secretin-like GPCRs include secretin , calcitonin , parathyroid hormone/parathyroid hormone-related peptides  and vasoactive intestinal peptide , all of which activate adenylyl cyclase and the phosphatidyl-inositol-calcium pathway. The amino acid sequences of the receptors contain high proportions of hydrophobic residues grouped into 7 domains, in a manner reminiscent of the rhodopsins and other receptors believed to interact with G-proteins. However, while a similar 3D framework has been proposed to account for this, there is no significant sequence identity between these families: the secretin-like receptors thus bear their own unique '7TM' signature.    ; GO: 0004930 G-protein coupled receptor activity, 0016020 membrane; PDB: 1bl1 1et3_S 1et2_S 1fjr_B.
# Match_columns 293
# No_of_seqs    117 out of 762
# Neff          6.6 
# Searched_HMMs 13774
# Date          Tue Oct 13 16:32:31 2009
# Command       /mnt/master/home/minlag/hhsearch/./hhsearch -i /mnt/master/home/minlag/pfamA_23.0_hhm_cal_ssm_4/PF00002.hhm -d /mnt/master/home/minlag/scop70_1.75_PFAM_PDEXK_2.db -v 1 -o /mnt/master/home/minlag/PFAM_in_SCOP_and_PFAM_pdexk_2/PF00002.out -ssm 4 -p 10 
# 
# Returns the following structure
# %main_obj = (
#              query => "PF00002",
#              header => "7 transmembrane receptor (Secretin family)",
#              match_columns => 293,
#              used_no_of_seqs => 117,
#              all_no_of_seqs => 762,
#              neff => 6.6,
#              searched_HMMs => 13774,);


sub parse_hh_header
{
    my ($data) = @_;
    
    my %main_obj;
    
    foreach my $line (@$data)
    {
        if($line =~ /^\s*Query\s+/)
        {
            if($line =~ /^\s*Query\s+([\w\_\.\-]+)\s+.*:\s*(.*);\s+InterPro/ || 
               $line =~ /^\s*Query\s+([\w\_\.\-]+)\s*(.*);/ || 
               $line =~ /^\s*Query\s+([\w\_\.\-]+)\s*(.*)/)
            {
                $main_obj{query} = $1;
                $main_obj{header} = $2;
            }
            elsif($line =~ /^\s*Query\s+([\w\_\.\-]+)\s*/)
            {
                $main_obj{query} = $1;
                $main_obj{header} = "Nan";
            }
            else
            {
                $main_obj{error} = "parse_hh_header: Can't parse HHout file! Incorrect header!";
            }
        }
        elsif($line =~ /^\s*Match_columns\s+(\d+)/)
        {
            $main_obj{match_columns} = $1;
        }
        elsif($line =~ /^\s*No_of_seqs\s+(\d+)\s+out\s+of\s+(\d+)/)
        {
            $main_obj{used_no_of_seqs} = $1;
            $main_obj{all_no_of_seqs} = $2;
        }
        elsif($line =~ /^\s*Neff\s+([\d\.]+)/)
        {
            $main_obj{neff} = $1;
        }
        elsif($line =~ /^\s*Searched_HMMs\s+(\d+)/)
        {
            $main_obj{searched_HMMs} = $1;
        }
    }

    return \%main_obj;
}

# ==============================================================================
# Accepts
#  No Hit                             Prob E-value P-value  Score    SS Cols Query HMM  Template HMM
#   1 d1u19a_ f.13.1.2 (A:) Rhodopsi  98.8 8.9E-09 6.5E-13   63.7   6.9  244   14-292    50-312 (348)
#   2 d1h2sa_ f.13.1.1 (A:) Sensory   88.9 1.7E+02   0.012    6.5  18.8   49  238-286   168-216 (225)
#   3 d1xioa_ f.13.1.1 (A:) Sensory   79.4 6.6E+02   0.048    3.2  18.3   45  235-282   170-217 (226)
#   4 d1m0ka_ f.13.1.1 (A:) Bacterio  45.5 2.3E+02   0.017    5.8  10.5   49  238-286   175-223 (227)
#   5 d1uaza_ f.13.1.1 (A:) Archaerh  36.5 3.3E+02   0.024    4.9  10.1   41  240-283   187-230 (236)
#   6 d1e12a_ f.13.1.1 (A:) Halorhod  30.1 5.6E+02    0.04    3.6  10.5   46  238-286   181-230 (239)
#   7 d3cx5c1 f.32.1.1 (C:262-385) M  23.2 2.2E+02   0.016    5.9   7.4   13   44-56     64-76  (124)

# Returns the following structure
# my %obj = (number => 1, 
#             template => "d1u19a_", 
#             prob => 98.8, 
#             evalue => 8.9E-09, 
#             pvalue => 6.5E-13, 
#             score => 63.7, 
#             ss => 6.9, 
#             cols => 244, 
#             query_hmm_begin => 14, 
#             query_hmm_end => 292, 
#             template_hmm_begin => 50, 
#             template_hmm_end => 312, 
#             hierarchy => "f.13.1.2");

sub parse_hh_hits
{
    my ($data) = @_;
    
    my %hits;
    
    foreach my $line (@$data)
    {
        if($line =~ /^\s*(\d+)\s+([\w\.\_\-]+).*\s+([\d\.E\+\-]+)\s+([\d\.E\+\-]+)\s+([\d\.E\+\-]+)\s+([\d\.E\+\-]+)\s+([\d\.E\+\-]+)\s+(\d+)\s+(\d+)-(\d+)\s+(\d+)-(\d+)\s*\((\d+)\)/)
        {
            my %obj = (number => $1, template => $2, prob => $3, evalue => $4, pvalue => $5, score => $6, ss => $7, cols => $8, 
                        query_hmm_begin => $9, query_hmm_end => $10, template_hmm_begin => $11, template_hmm_end => $12, template_length => $13);
                        
            if($line =~ /^\s*(\d+)\s+([\w\.\_\-]+)\s+(\w+\.\w+\.\w+\.\w+)/)
            {
                $obj{hierarchy} = $3;
            }
            else
            {
                $obj{hierarchy} = "Nan";
            }
            
            $hits{$obj{number}} = \%obj;
        }
        elsif($line !~ /^\s+No\s+Hit/)
        {
            print STDERR "ERR: $line";
        }
    }

    return \%hits;
}

# ==============================================================================
# Accepts
# No 2  
# >d1h2sa_ f.13.1.1 (A:) Sensory rhodopsin II {Archaeon Natronobacterium pharaonis [TaxId: 2257]}
# Probab=88.89   E-value=1.7e+02  Score=6.51  Aligned_columns=49  Identities=16%
# 
# Q ss_dssp             -------------------------------------------------
# Q ss_pred             HHHHHHHHHHHHHHHHHCCCCCHHHHHHHHHHHHHHHHHHHHHHHHHHH
# Q ss_conf             9999999999999986247400256999999999998689999999999
# Q PF00002_consen  238 LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY  286 (293)
# Q Consensus       238 l~L~pLlGitW~~~~~~~~~~~~~~~~~~~~ylf~ilnslQG~fIfi~~  286 (293)
#                       ++.=.+..+-|.++.-..+..........+.+++.+--..=|+++.-.+
# T Consensus       168 ~v~W~iYPi~y~l~~~g~~~~~~~~~~~~y~i~D~i~K~~FG~~i~~~a  216 (225)
# T d1h2sa_         168 VILWAIYPFIWLLGPPGVALLTPTVDVALIVYLDLVTKVGFGFIALDAA  216 (225)
# T ss_dssp             HHHHTTHHHHHHHSTTTTCCSCHHHHHHHHHHHHHHHHHHHHHHHHHHH
# T ss_pred             HHHHHHHHHHHHHCCCCCCCCCHHHHHHHHHHHHHHHHHHHHHHHHHHH
# T ss_conf             9999999999985556545455289989999999999999999999999
# 
# 
# No 3  
# >d1xioa_ f.13.1.1 (A:) Sensory rhodopsin {Anabaena sp. PCC 7120 [TaxId: 103690]}
# Probab=79.41   E-value=6.6e+02  Score=3.22  Aligned_columns=45  Identities=20%
# 
# Q ss_dssp             ---------------------------------------------------
# Q ss_pred             HHHHHHHHHHHHHHHHHHHH---CCCCCHHHHHHHHHHHHHHHHHHHHHHH
# Q ss_conf             99999999999999999862---4740025699999999999868999999
# Q PF00002_consen  235 KATLVLLPLLGITWILGLFA---VNDDSDGTLSLVFAYLFAILNSLQGLFI  282 (293)
# Q Consensus       235 k~~l~L~pLlGitW~~~~~~---~~~~~~~~~~~~~~ylf~ilnslQG~fI  282 (293)
#                       .-..++=.+.++-|.++..-   .+++   .....+.+++.+--..=|+++
# T Consensus       170 ~~~~v~W~~YPi~~~l~~~g~g~~~~~---~~~i~Y~ilDv~~K~~fgl~l  217 (226)
# T d1xioa_         170 TYFTVLWIGYPIVWIIGPSGFGWINQT---IDTFLFCLLPFFSKVGFSFLD  217 (226)
# T ss_dssp             HHHHHHHHHHHHHHHHSTTTTCSSCHH---HHHHHHHHHHHHHHHHHHHHH
# T ss_pred             HHHHHHHHHHHHHHHHCCCCCCCCCHH---HHHHHHHHHHHHHHHHHHHHH
# T ss_conf             999999999999999632556767868---999999999999999999999

# Returns the following structure
# my %obj = 
#         (
#             match => "++.=.+..+-|.++.-..+..........+.+++.+--..=|+++.-.+", 
#             q_cons => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_cons => "~v~W~iYPi~y~l~~~g~~~~~~~~~~~~y~i~D~i~K~~FG~~i~~~a", 
#             q_seq => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_seq => "VILWAIYPFIWLLGPPGVALLTPTVDVALIVYLDLVTKVGFGFIALDAA"
#         );


sub parse_hh_aligns
{
    my ($data, $input) = @_;
    
    my %aligns;
    my $error = "";
    
    for(my $i = 0; $i < @$data; $i++)
    {
        if($$data[$i] =~ /^\s*No\s+(\d+)/)
        {
            my @aligns;
            
            my $number = $1;

            $i += 4;
            my $counter = 0;
            
            my @aligned_seq;
            
            for(; $i < @$data && $$data[$i] !~ /^\s*No\s+(\d)+/; $i++)
            {
                if($$data[$i] ne "")
                {
                    push(@aligned_seq, $$data[$i]);
                }
                else
                {
                    $counter++;
                }    
            }
            
            if($counter % 2 != 0)
            {
                return "parse_hh_aligns: failed parsing HMM aligns: unexpected number of empty lines among alignments!";
            }
            
            $counter /= 2;
            
            if(scalar(@aligned_seq) % $counter != 0)
            {
                return "parse_hh_aligns: failed parsing HMM aligns: unexpected number of non empty lines among alignments!";
            }
            
            my $block_size = scalar(@aligned_seq) / $counter;

            my $match  = get_match_position(\@aligned_seq);

            my $q_seq  = $match - 2;
            my $q_cons = $match - 1;

            my $t_cons = $match + 1;
            my $t_seq  = $match + 2;
            
            my %obj = (match => "", q_cons => "", t_cons => "", q_seq => "", t_seq => "");
            
            for(my $k = 0; $k < scalar(@aligned_seq) / $block_size; $k++)
            {
                $obj{q_seq}  .= get_sequence($aligned_seq[$k * $block_size + $q_seq], $input);
                $obj{q_cons} .= get_sequence($aligned_seq[$k * $block_size + $q_cons], $input);
                $obj{match}  .= get_match_info($aligned_seq[$k * $block_size + $q_cons], $aligned_seq[$k * $block_size + $match]);
                $obj{t_cons} .= get_sequence($aligned_seq[$k * $block_size + $t_cons], $input);
                $obj{t_seq}  .= get_sequence($aligned_seq[$k * $block_size + $t_seq], $input);
            }

            $aligns{$number} = \%obj;
            
#             print "$obj{q_seq}\n$obj{q_cons}\n$obj{match}\n$obj{t_cons}\n$obj{t_seq}\n\n";

            $i--;
        }
    }

    return \%aligns;
}


# ==============================================================================
# Q ss_pred             EEEEECCEEEEEEEEEC
# Q ss_conf             99970993799999969
# Q ref|ZP_0189400  161 VNIGNDDTLVSVTPEPL  177 (177)
# Q Consensus       161 ~~is~~~~~vev~~~~l  177 (177)
#                       +||++++++|+|+|++|
# T Consensus       161 ~~is~~~~~vev~~~~l  177 (177)
# T ref|ZP_0189400  161 VNIGNDDTLVSVTPEPL  177 (177)
# T ss_pred             EEEEECCEEEEEEEEEC
# T ss_conf             99970993799999969        C

# Returns "+||++++++|+|+|++|"

sub get_match_info
{
    my($q_consensus, $line) = @_;
    
    my $match_info = "";
    
    if($q_consensus =~ /(Q\s+Consensus\s+\d+\s+)/)
    {
        my $length = length($1);
        $match_info .= substr($line, $length);
    }

    return $match_info;
}

# ==============================================================================
# Q ss_pred             EEEEECCEEEEEEEEEC
# Q ss_conf             99970993799999969
# Q ref|ZP_0189400  161 VNIGNDDTLVSVTPEPL  177 (177)
# Q Consensus       161 ~~is~~~~~vev~~~~l  177 (177)
#                       +||++++++|+|+|++|
# T Consensus       161 ~~is~~~~~vev~~~~l  177 (177)
# T ref|ZP_0189400  161 VNIGNDDTLVSVTPEPL  177 (177)
# T ss_pred             EEEEECCEEEEEEEEEC
# T ss_conf             99970993799999969        C

# Returns 4

sub get_match_position
{
    my($lines) = @_;
    
    my $counter = 0;
    
    for(my $i = 0; $i < @$lines; $i++)
    {
        if($$lines[$i] =~ /^\s+/)
        {
            return $counter++;
        }
        $counter++;
    }

    return 0;
}


# ==============================================================================
# Q ss_pred             EEEEECCEEEEEEEEEC
# Q ss_conf             99970993799999969
# Q ref|ZP_0189400  161 VNIGNDDTLVSVTPEPL  177 (177)
# Q Consensus       161 ~~is~~~~~vev~~~~l  177 (177)
#                       +||++++++|+|+|++|
# T Consensus       161 ~~is~~~~~vev~~~~l  177 (177)
# T ref|ZP_0189400  161 VNIGNDDTLVSVTPEPL  177 (177)
# T ss_pred             EEEEECCEEEEEEEEEC
# T ss_conf             99970993799999969        C

# Returns "VNIGNDDTLVSVTPEPL"

sub get_sequence
{
    my($line, $input) = @_;
    
    my $match_info = "";
    
    if($line =~ /^[Q|T]\s+\S+\s+\d+\s+(\S+)\s+\d+/)
    {
        return $1;
    }
    print STDERR "$input#$line#\n";
    print STDERR "get_sequence: can't find sequence!";
}

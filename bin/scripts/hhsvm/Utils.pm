package Utils;
use warnings;
use strict;
require Exporter;
@Parsers::ISA = qw(Exporter);

use Parsers;
use Stats;
use charges;##{{MM ed.}}


##{{MM ed.
my  $chdata = charges->new();
my  $CHARGES = $chdata->Charges();
##}}

# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-05-09 17:39:58 +0300 (Sat, 09 May 2009) $
# $Revision: 67 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/Utils.pm $
# ==============================================================================

# ==============================================================================
# HHout obj:
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
# 
# 
# $aln_obj = {index => $obj, pos => $possible_position, scores => [1,2,3]};
# $index = 5
 
sub print_svm_features
{
    my ($hh_obj, $aln_obj, $class_label) = @_;
    
    printf("%d ", $class_label);
    
    my $counter = 1;
    
    foreach my $score (@{$aln_obj->{scores}})
    {
        printf("$counter:%0.2f ", $score);  
        $counter++;  
    }
    
    print "#$hh_obj->{query} $hh_obj->{hits}->{$aln_obj->{index}}->{template} prob=$hh_obj->{hits}->{$aln_obj->{index}}->{prob}\n";  
}
 

# ==============================================================================
# my %hit = (
#             number => 1, 
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
# my %alignment = 
#         (
#             match => "++.=.+..+-|.++.-..+..........+.+++.+--..=|+++.-.+", 
#             q_cons => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_cons => "~v~W~iYPi~y~l~~~g~~~~~~~~~~~~y~i~D~i~K~~FG~~i~~~a", 
#             q_seq => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_seq => "VILWAIYPFIWLLGPPGVALLTPTVDVALIVYLDLVTKVGFGFIALDAA"
#         );
# %position = (
#               name => "2g3w.pos",
#               e_pos => [2],
#               pd_pos => [15, 16],
#               exk_pos => [37,38,39],
#         );
# %hhm_obj = (seq => 5, neff =>3.7, stats => [\%obj1, \%obj2 ...], stats_hash => { 1 => \%obj1, 2 => \%obj2 ...})
# %obj = (
#               amino_acid => "A",
#               number => 158,
#               M_M => 0,
#               M_I => 99999,
#               M_D => 99999,
#               I_M => 99999,
#               I_I => 99999,
#               D_M => 99999,
#               D_D => 99999, 
#               Neff => 3383,
#               Neff_I => 0, 
#               Neff_D => 0,
#               freq => [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
#         );
# 
# There are 2 possible modes: for positive data - "positive" mode and for negative - "negative".
  
sub score_manager
{
    my ($template_hhm_path, $alignment, $hit, $positions, $mode, $query_length, $query_hhm, $no_hhsearch_prob, $use_e_pos) = @_;
    
    my @scores;
    my(@locscores1, @locscores2 );##{{MM ed.}}
    my($n, $s1, $s2, $rr );##{{MM ed.}}
    
    my $hhm_obj = Parsers::parse_hhm($template_hhm_path);
    
    push(@scores, $hit->{ss});
        
    if($no_hhsearch_prob == 0)
    {
        push(@scores, $hit->{prob});
    }
       
    my $most_important_positions = most_important_positions($positions, $use_e_pos);
    
    push(@scores, conservative_position_score($alignment, $hit, $positions, $mode, 0, $most_important_positions));
    
    if($mode eq "positive")
    {
        my $reflection_pos = reflect($alignment->{q_seq}, $hit->{query_hmm_begin}, $alignment->{t_seq}, $hit->{template_hmm_begin});
        
        push(@scores, conservation_level($query_hhm, $hhm_obj, $most_important_positions, $reflection_pos));
        
#         push(@scores, conservative_position_hydropathy($most_important_positions, $reflection_pos, $query_hhm, $hhm_obj));
    
##{{MM ed.}}        push(@scores, neff($query_hhm, $query_hhm->{stats}[0]->{number}, $query_hhm->{stats}[-1]->{number}));
##{{MM ed.}}        push(@scores, ($hit->{query_hmm_end} - $hit->{query_hmm_begin} + 1) / $query_length);
##{{MM ed.}}        push(@scores, neff($query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end}));         
##{{MM ed.}}        push(@scores, hidropathy($query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end}));         
        
##{{MM ed.}}        push(@scores, neff($hhm_obj, $hhm_obj->{stats}[0]->{number}, $hhm_obj->{stats}[-1]->{number}));
        push(@scores, ($hit->{template_hmm_end} - $hit->{template_hmm_begin} + 1) / $hit->{template_length});
##{{MM ed.}}        push(@scores, neff($hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end})); 
##{{MM ed.}}        push(@scores, hidropathy($hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end}));

        ##{{MM ed.
            push( @locscores1, neff($query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end} ));
            push( @locscores2, neff($hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end} ));
            if( $#locscores1 != $#locscores2 ) {
                die( "ERROR: score_manager: Scores obtained from query and subject are incompatible." );
            }
            for( $n = 0; $n <= $#locscores1; $n++ ) {
                $s1 = $locscores1[$n];
                $s2 = $locscores2[$n];
                $s2 = 0.0001 if( $s2 == 0 );
                $rr = $s1 / $s2;
                if( $n == $#locscores1 ) {
                    push( @scores, $s1 );
                    push( @scores, $s2 );
                }
                else {
                    push( @scores, $rr );
                }
            }
            $s1 = hidropathy( $query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end} );
            $s2 = hidropathy( $hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end} );
            $s2 = 0.0001 if( $s2 == 0 );
            $s1 /= $s2;
            push( @scores, $s1 );

            $s1 = pI( $query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end} );
            $s2 = pI( $hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end} );
            $s2 = 0.0001 if( $s2 == 0 );
            $s1 /= $s2;
            push( @scores, $s1 );
        ##}}
    }
    elsif($mode eq "negative")
    {
        my $reflection_pos = reflect($alignment->{t_seq}, $hit->{template_hmm_begin}, $alignment->{q_seq}, $hit->{query_hmm_begin});
        
        push(@scores, conservation_level($hhm_obj, $query_hhm, $most_important_positions, $reflection_pos));
        
#         push(@scores, conservative_position_hydropathy($most_important_positions, $reflection_pos, $hhm_obj, $query_hhm));
    
##{{MM ed.}}        push(@scores, neff($hhm_obj, $hhm_obj->{stats}[0]->{number}, $hhm_obj->{stats}[-1]->{number}));
##{{MM ed.}}        push(@scores, ($hit->{template_hmm_end} - $hit->{template_hmm_begin} + 1) / $hit->{template_length});
##{{MM ed.}}        push(@scores, neff($hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end})); 
##{{MM ed.}}        push(@scores, hidropathy($hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end}));
               
##{{MM ed.}}        push(@scores, neff($query_hhm, $query_hhm->{stats}[0]->{number}, $query_hhm->{stats}[-1]->{number}));
        push(@scores, ($hit->{query_hmm_end} - $hit->{query_hmm_begin} + 1) / $query_length);
##{{MM ed.}}        push(@scores, neff($query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end}));
##{{MM ed.}}        push(@scores, hidropathy($query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end}));

        ##{{MM ed.
            push( @locscores1, neff($hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end} ));
            push( @locscores2, neff($query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end} ));
            if( $#locscores1 != $#locscores2 ) {
                die( "ERROR: score_manager: Scores obtained from query and subject are incompatible." );
            }
            for( $n = 0; $n <= $#locscores1; $n++ ) {
                $s1 = $locscores1[$n];
                $s2 = $locscores2[$n];
                $s2 = 0.0001 if( $s2 == 0 );
                $rr = $s1 / $s2;
                if( $n == $#locscores1 ) {
                    push( @scores, $s1 );
                    push( @scores, $s2 );
                }
                else {
                    push( @scores, $rr );
                }
            }
            $s1 = hidropathy( $hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end} );
            $s2 = hidropathy( $query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end} );
            $s2 = 0.0001 if( $s2 == 0 );
            $s1 /= $s2;
            push( @scores, $s1 );

            $s1 = pI( $hhm_obj, $hit->{template_hmm_begin}, $hit->{template_hmm_end} );
            $s2 = pI( $query_hhm, $hit->{query_hmm_begin}, $hit->{query_hmm_end} );
            $s2 = 0.0001 if( $s2 == 0 );
            $s1 /= $s2;
            push( @scores, $s1 );
        ##}}

    }
    
    return \@scores;
} 
  
# ==============================================================================
# %hhm_obj = (seq => [\%seq1], neff =>3.7, stats => [\%obj1, \%obj2 ...], stats_hash => { 1 => \%obj1, 2 => \%obj2 ...})
# %seq1 = (
#           header => "Consensus",
#           seq    => "AxAA",
#         )
# %obj = (
#               amino_acid => "A",
#               number => 158,
#               M_M => 0,
#               M_I => 99999,
#               M_D => 99999,
#               I_M => 99999,
#               I_I => 99999,
#               D_M => 99999,
#               D_D => 99999, 
#               Neff => 3383,
#               Neff_I => 0, 
#               Neff_D => 0,
#               freq => [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
#         );
# 
  
sub hidropathy
{
    my ($hhm_obj, $begin, $end) = @_;
    
    my @scores;
    my ($rress, $rfreqs );##{{MM ed.}}
    my ($hi, $fr, $val, $n );##{{MM ed.}}

##printf( STDERR "MM BEGIN\n");
    for(my $i = $begin; $i <= $end; $i++)
    {
##printf( STDERR "%s", $hhm_obj->{stats_hash}->{$i}->{amino_acid});
##{{MM ed.}}        push(@scores, hidropathy_index($hhm_obj->{stats_hash}->{$i}->{amino_acid}));
        ##{{MM ed.
            $rress = $hhm_obj->{stats_hash}->{residues};
            $rfreqs = $hhm_obj->{stats_hash}->{$i}->{freq};
            if( $#$rress != $#$rfreqs ) {
                die( "ERROR: Dimensions of frequency vector from HMM are incompatible. " );
            }
            $val = 0.0;
            for( $n = 0; $n <= $#$rress; $n++ ) {
                $hi = hidropathy_index( $$rress[$n] );
                $fr = $$rfreqs[$n];
                if( $fr < 0.0 || 1.0 < $fr ) {
                    die( "ERROR: Residue frequency value from HMM is invalid." );
                }
                $val += $fr * $hi;
            }
            push( @scores, $val );
        ##}}
    }
    
##printf( STDERR "\n");
##printf( STDERR "MM hidropathy: Stats::mean: begin=%d end=%d\n", $begin, $end);
##printf( STDERR "MM");
##printf( STDERR " %f", $_ ) foreach( @scores );
##printf( STDERR "\n\n");
    return Stats::mean(\@scores);
}

# ==============================================================================
sub hidropathy_index
{
    my ($amino_acid) = @_;
    
    my %hidropathy =
    (
        R => -4.5,
        K => -3.9,
        N => -3.5,
        D => -3.5,
        Q => -3.5,
        E => -3.5,
        H => -3.2,
        P => -1.6,
        Y => -1.3,
        W => -0.9,
        S => -0.8,
        T => -0.7,
        G => -0.4,
        A =>  1.8,
        M =>  1.9,
        C =>  2.5,
        F =>  2.8,
        L =>  3.8,
        V =>  4.2,
        I =>  4.5,
    );

    return $hidropathy{$amino_acid} if( exists $hidropathy{$amino_acid});
    return 0.0;
}
  
##--------------------------------------------------------------------
## {{MM ed.
## calculate pI
##
sub pI
{
    my ($hhm_obj, $begin, $end) = @_;

    my  %rinds = ('K'=>0,'R'=>1,'H'=>2,'D'=>3,'E'=>4,'C'=>5,'Y'=>6);
    my  %rcnts;
    my  $rsyms;
    my ($res, $n, $cnt, $tmp );

    $rsyms .= $_ foreach( keys %rinds );
    $rcnts{$_} = 0 foreach( keys %rinds );

    ##for( $n = 0; $n <= length($hhm_obj); $n++ ) {
    for( $n = $begin; $n <= $end; $n++ ) {
        ##$res = substr( $hhm_obj, $n, 1 );
        $res = $hhm_obj->{stats_hash}->{$n}->{amino_acid};
        $rcnts{$res}++ if( $rsyms =~ /$res/ );
    }

    my  $accuracy = 0.001;
    my  $pHleft = 0;
    my  $pHright = 14.0;
    my  $pH = 6.5;
    my  $pHindleft;
    my  $pHindright;
    my  $pHind;
    my  $chsum;##charge at the given pH value

    ##-- bisection method to find pH --
    ##
    while( 1 ) {
        $pHind = int( $pH * 100.0 );
        $pHindleft = int( $pHleft * 100.0 );
        $pHindright = int( $pHright * 100.0 );
        last if( $#$CHARGES < $pHind );
        last if( $pHind < 0 );
        last if( $pHindright - $pHindleft < 2 );##no progress

        $chsum = 0.0;
        foreach( keys %rinds ) {
            $n = $rinds{$_};
            $cnt = $rcnts{$_};
            die( "ERROR: pI: Array index exceeds limits." ) if $#{$CHARGES->[$pHind]} < $n;
            next unless $cnt;
            $chsum += $cnt * $CHARGES->[$pHind][$n];
        }

        if( $chsum < 0.0 ) {
            $tmp = $pH;
            $pH -= ( $pH - $pHleft ) * 0.5;
            $pHright = $tmp;
        }
        else {
            $tmp = $pH;
            $pH += ( $pHright - $pH ) * 0.5;
            $pHleft = $tmp;
        }
        ##print( "pI: $pHleft $pH $pHright: $chsum\n" );
        last if(( $pH - $pHleft < $accuracy )&&( $pHright - $pH < $accuracy ));
    }

    return $pH;
}

##}}


# ==============================================================================
# %hhm_obj = (seq => [\%seq1], neff =>3.7, stats => [\%obj1, \%obj2 ...], stats_hash => { 1 => \%obj1, 2 => \%obj2 ...})
# %seq1 = (
#           header => "Consensus",
#           seq    => "AxAA",
#         )
# %obj = (
#               amino_acid => "A",
#               number => 158,
#               M_M => 0,
#               M_I => 99999,
#               M_D => 99999,
#               I_M => 99999,
#               I_I => 99999,
#               D_M => 99999,
#               D_D => 99999, 
#               Neff => 3383,
#               Neff_I => 0, 
#               Neff_D => 0,
#               freq => [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
#         );
# 
# 
# %position = (
#               name => "2g3w.pos",
#               e_pos => [2],
#               pd_pos => [15, 16],
#               exk_pos => [37,38,39],
#         );

sub neff
{
    my ($hhm_obj, $begin, $end) = @_;
    
    my @score_M_M;
    my @score_M_I;
    my @score_M_D;
    my @score_I_M;
    my @score_I_I;
    my @score_D_M;
    my @score_D_D;

    my @score_neff;
    my @score_neff_i;
    my @score_neff_d;
    
    my @entropy;
    
    for(my $i = $begin; $i <= $end; $i++)
    {
        push(@score_M_M, $hhm_obj->{stats_hash}->{$i}->{M_M});
        push(@score_M_I, $hhm_obj->{stats_hash}->{$i}->{M_I});
        push(@score_M_D, $hhm_obj->{stats_hash}->{$i}->{M_D});
        push(@score_I_M, $hhm_obj->{stats_hash}->{$i}->{I_M});
        push(@score_I_I, $hhm_obj->{stats_hash}->{$i}->{I_I});
        push(@score_D_M, $hhm_obj->{stats_hash}->{$i}->{D_M});
        push(@score_D_D, $hhm_obj->{stats_hash}->{$i}->{D_D});
    
        push(@score_neff  , $hhm_obj->{stats_hash}->{$i}->{Neff});
        push(@score_neff_i, $hhm_obj->{stats_hash}->{$i}->{Neff_I});
        push(@score_neff_d, $hhm_obj->{stats_hash}->{$i}->{Neff_D});
        
        push(@entropy, Stats::entropy($hhm_obj->{stats_hash}->{$i}->{freq}));
    }
    
    my @data;
    
    push(@data, \@score_M_M);
    push(@data, \@score_M_I);
    push(@data, \@score_M_D);
    push(@data, \@score_I_M);
    push(@data, \@score_I_I);
    push(@data, \@score_D_M);
    push(@data, \@score_D_D);
    
    push(@data, \@score_neff);
    push(@data, \@score_neff_i);
    push(@data, \@score_neff_d);
    
    push(@data, \@entropy);
    
    my @scores;

    foreach my $arr (@data)
    {
        my $mean = Stats::mean($arr);

        push(@scores, $mean);
    }

    return @scores;
}
 
# ============================================================================== 
# Finds PDEXK. Returns an array of indeces of PDEXK.
 
sub find_PDEXK
{
    my ($obj, $positives, $lower_limit, $upper_limit) = @_;
    
    my @ids;
    
    for my $key (sort {$a <=> $b} keys %{$obj->{hits}})
    {
        if(($obj->{hits}->{$key}->{prob} >= $lower_limit && 
            $obj->{hits}->{$key}->{prob} <= $upper_limit &&
            $obj->{hits}->{$key}->{template} !~ /$obj->{query}/) && 
            test_PDEXK($obj->{hits}->{$key}->{template}, $positives))
        {
            push(@ids, $key);
        }       
    }
    
    return \@ids;
}


# Some PDEXK are unreliable. Skips them.
# List of
# %position = (
#               name => "2g3w.pos",
#               e_pos => [2],
#               pd_pos => [15, 16],
#               exk_pos => [37,38,39],
#         );

sub test_PDEXK
{
    my ($template, $positives) = @_;
    
#       Unreliable PDEXK
#       PF04720 PF03749 PF04754
#       CRISP
#       PF09670 PF09651 PF09659 PF09623
#       Has analogs in SCOP with 100 HHsearch prob
#       PF04257 PF07152 PF09194 PF09631 PF09225 PF09126 PF09233 PF09208 PF03871 PF01974
#       Lack of positional information
#       PF04556 PF09810
#       Too thin alignments
#       d1dzfa1 d2czra1 d1rzna_ d2gw6a1 d1a79a1 d1r0va1 d1r0va2
#       d1dmua_ d1sa3a_ d1tx3a1 d1wtea_
#     
#     my @skip = qw[PF04720 PF03749 PF04754 PF09670 PF09651 PF09659 PF09623
#                   PF04257 PF07152 PF09194 PF09631 PF09225 PF09126 PF09233 
#                   PF09208 PF03871 PF01974 PF04556 PF09810
#                   d1dzfa1 d2czra1 d1rzna_ d2gw6a1 d1a79a1 d1r0va1 d1r0va2
#                   d1dmua_ d1sa3a_ d1tx3a1 d1wtea_];
    
    foreach my $obj (@$positives)
    {
        if($template =~ /$obj->{name}/)
        {
            return 1;
        }
    }
    return 0;
}

# Finds not PDEXK. Use the threshold of 80.

sub find_not_PDEXK
{
    my ($obj, $threshold) = @_;
        
    my @ids;
    
    for my $key (sort {$a <=> $b} keys %{$obj->{hits}})
    {
        if($obj->{hits}->{$key}->{prob} >= $threshold  && 
           $obj->{hits}->{$key}->{hierarchy} !~ /c.52/ && # SCOP
           $obj->{hits}->{$key}->{template} !~ /^\d+/  && # PDB
           $obj->{hits}->{$key}->{template} !~ /^PF\d+/)  # PFAM
        {
            push(@ids, $key);
        }   
    }
    return \@ids;
}
# ==============================================================================
# Returns conservative positions of the concrete template.

sub get_PDEXK_positions
{
    my ($positions, $template) = @_;
    
    my $counter = 0;
    my $pos;

    for(my $i = 0; $i < @$positions; $i++)
    {
        if($$positions[$i]->{name} =~ /^$template/)
        {
            $pos = $$positions[$i];
            $counter++;
        }
    }

    if($counter > 1)
    {
        print STDERR "ERR: more than one match: \'$template\'\n";
    }
    return $pos;
}

# ==============================================================================
# Tests if both, only one or none positions were aligned.
# Input parameter $template_query has two values query or template.
# If the negative data set has been analysing , then a value for the parameter must be "query",
# otherwise - "template".

sub test_aligned_region
{
    my $SHRTINTERGAP = 15;##{{MM ed.}}-gap between two motifs still considered as short gap

    my ($hh_obj, $possible_position, $obj, $template_query) = @_;

    if (($hh_obj->{hits}->{$obj}->{$template_query . "_hmm_begin"} <= $possible_position->{pd_pos}[0] &&
         $possible_position->{pd_pos}[-1] <= $hh_obj->{hits}->{$obj}->{$template_query . "_hmm_end"}) &&
        ($hh_obj->{hits}->{$obj}->{$template_query . "_hmm_begin"} <= $possible_position->{exk_pos}[0] &&
         $possible_position->{exk_pos}[-1] <= $hh_obj->{hits}->{$obj}->{$template_query . "_hmm_end"}))
    {
        return 2;
    }
    elsif (($hh_obj->{hits}->{$obj}->{$template_query . "_hmm_begin"} <= $possible_position->{pd_pos}[0] &&
            $possible_position->{pd_pos}[-1] <= $hh_obj->{hits}->{$obj}->{$template_query . "_hmm_end"}) ||
           ($hh_obj->{hits}->{$obj}->{$template_query . "_hmm_begin"} <= $possible_position->{exk_pos}[0] &&
            $possible_position->{exk_pos}[-1] <= $hh_obj->{hits}->{$obj}->{$template_query . "_hmm_end"}))
    {
        ##{{MM}}-pretend as if there's no alignment of those motifs if they are originally close to each other
##        return 0 if( $possible_position->{exk_pos}[0] - $possible_position->{pd_pos}[-1] <= $SHRTINTERGAP ); ##{{MM ed.}}
        return 1;
    }
    
    return 0;
}

# ==============================================================================
# %positions = (
#               name => "2g3w.pos",
#               e_pos => [2],
#               pd_pos => [15, 16],
#               exk_pos => [37,38,39],
#         );

sub most_important_positions
{
    my ($positions, $use_e_pos) = @_;
    
    my @positions = ([$positions->{pd_pos}[0]],
                     [$positions->{pd_pos}[1]], 
                     [$positions->{exk_pos}[0]],
                     [$positions->{exk_pos}[2]]);

    ##{{MM ed.
    if( 2 < $#{$positions->{exk_pos}}) {
        $positions[2] = [$positions->{exk_pos}[0]];
        $positions[3] = [$positions->{exk_pos}[1]];
        $positions[4] = [$positions->{exk_pos}[2]];
        $positions[5] = [$positions->{exk_pos}[3]];
    }
    ##}}

    if($use_e_pos == 1)
    {
        push(@positions, [$positions->{e_pos}[0]]);
    }
    
    return \@positions;
}

# ==============================================================================
# my %hit = (
#             number => 1, 
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
# my %alignment = 
#         (
#             match => "++.=.+..+-|.++.-..+..........+.+++.+--..=|+++.-.+", 
#             q_cons => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_cons => "~v~W~iYPi~y~l~~~g~~~~~~~~~~~~y~i~D~i~K~~FG~~i~~~a", 
#             q_seq => "LVLLPLLGITWILGLFAVNDDSDGTLSLVFAYLFAILNSLQGLFIFILY", 
#             t_seq => "VILWAIYPFIWLLGPPGVALLTPTVDVALIVYLDLVTKVGFGFIALDAA"
#         );
# There are 2 possible modes: for positive data - "positive" mode and for negative - "negative".
# Shift means +- conservative start/end position
#          relative - position in the alignment

sub conservative_position_score
{
    my ($alignment, $hit, $positions, $mode, $shift, $important_positions) = @_;

    if($mode ne "positive" && $mode ne "negative")
    {
        die "ERR: $0: conservative_position_score: don't know the mode: $mode\n";
    }

    my @scores;
    
    foreach my $cons_positions (@$important_positions)
    {
        my $sum = 0;
        my $counter = 0;
    
        foreach my $position (@$cons_positions)
        {
            $counter++;
            
            if($position ne "*")
            {
                my $relative_position;
            
                if($mode eq "positive")
                {
                    $relative_position = find_rel_dist($alignment->{t_seq}, 
                                                       $position,
                                                       $hit->{template_hmm_begin}, 
                                                       $hit->{template_hmm_end});
                }
                else
                {
                    $relative_position = find_rel_dist($alignment->{q_seq}, 
                                                       $position,
                                                       $hit->{query_hmm_begin}, 
                                                       $hit->{query_hmm_end});
                }
                
                if(defined($relative_position))
                {
                    $sum += alignment_score(substr($alignment->{match}, $relative_position, 1));
                }
                else
                {
                    $sum += 0;
                }
            }
            else
            {
                $sum = -10;
            }
        }  
          
        push(@scores, $sum / $counter);
    }

    return @scores;
} 

# ==============================================================================
#     =   :   very bad match   column score below -1.5
#     -   :   bad match   column score between -1.5 and -0.5
#     .   :   neutral match   column score between -0.5 and +0.5
#     +   :   good match  column score between +0.5 and +1.5
#     |   :   very good match     column score above +1.5
# normalization: (x - min) / (max - min) * 9 --> [0, 9]

sub alignment_score
{
    my ($similarity) = @_;

    if($similarity eq "="){ return -10.0; }
    if($similarity eq "-"){ return  -6.0 ; }
    if($similarity eq "."){ return   0.0; }
    if($similarity eq "+"){ return   6.0; }
    if($similarity eq "|"){ return  10.0; }  
      
    return 0;
}

# ============================================================================== 
# Accepts
#  position = 10
# template_begin = 5; template_end = 25;
# template_seq = LGFPINFLTLYVTVQHKKLRTPLN
# query_seq    = --LVALLLTIIIFLLFRSLRSTRT
# Returns 5
  
sub find_rel_dist
{
    my ($template_seq, $search_position, $template_begin, $template_end) = @_;
    
    if($search_position < $template_begin || $search_position > $template_end)
    {
        return;
    }
    
    my $position = $template_begin;
    
    my $template_pos = 0;
    
    my $dist = 0;
    
    while($position < $search_position)
    {
        if(substr($template_seq, $template_pos, 1) ne "-")
        {
            $position++;
        }
        
        $dist++;
        
        $template_pos++;
    }    
    
    return $dist;
}

# ==============================================================================
# Accepts
# 5
# q_seq => "AAA--", 
# 7
# t_seq => "-BBB-"
# 
# Returns
# %reflection_positions = ( 7 => 6, 8 => 7);
#                       template => query

sub reflect
{
    my ($query, $q_begin, $template, $t_begin) = @_;
    
    if(length($query) != length($template))
    {
        die "ERR: $0: reflect: a query and a template length doesn't match!"
    }
    
    my %reflection;

    my $q_pos = 0;
    my $t_pos = 0;

    for(my $i = 0; $i < length($template); $i++)
    {
        my $char_q = substr($query, $i, 1);
        my $char_t = substr($template, $i, 1);
        
        if($char_q ne "-" && $char_t ne "-")
        {
            $reflection{$t_begin + $t_pos} = $q_begin + $q_pos;
            
            $q_pos++;
            $t_pos++;
        }
        elsif($char_q ne "-")
        {
            $q_pos++;
        }
        elsif($char_t ne "-")
        {
            $t_pos++;
        }
    }
    return \%reflection;
}

# ==============================================================================
# %hhm_obj = (seq => [\%seq1], neff =>3.7, stats => [\%obj1, \%obj2 ...], stats_hash => { 1 => \%obj1, 2 => \%obj2 ...})
# %seq1 = (
#           header => "Consensus",
#           seq    => "AxAA",
#         )
# %obj = (
#               amino_acid => "A",
#               number => 158,
#               M_M => 0,
#               M_I => 99999,
#               M_D => 99999,
#               I_M => 99999,
#               I_I => 99999,
#               D_M => 99999,
#               D_D => 99999, 
#               Neff => 3383,
#               Neff_I => 0, 
#               Neff_D => 0,
#               freq => [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
#         );

sub conservative_position_hydropathy
{
    my ($important_positions, $reflection_pos, $q_hhm, $t_hhm) = @_;
    
    my @scores;
    
    foreach my $cons_positions (@$important_positions)
    {
        foreach my $position (@$cons_positions)
        {
            if(defined($reflection_pos->{$position}))
            {
                push(@scores, hidropathy_index($q_hhm->{stats_hash}->{$reflection_pos->{$position}}->{amino_acid}));
                push(@scores, hidropathy_index($t_hhm->{stats_hash}->{$position}->{amino_acid}));
            }
            else
            {
                push(@scores, -10);
                push(@scores, -10);
            }
        }
    }
    return @scores;
}

# ==============================================================================
# %hhm_obj = (seq => [\%seq1], neff =>3.7, stats => [\%obj1, \%obj2 ...], stats_hash => { 1 => \%obj1, 2 => \%obj2 ...})
# %seq1 = (
#           header => "Consensus",
#           seq    => "AxAA",
#         )
# %obj = (
#               amino_acid => "A",
#               number => 158,
#               M_M => 0,
#               M_I => 99999,
#               M_D => 99999,
#               I_M => 99999,
#               I_I => 99999,
#               D_M => 99999,
#               D_D => 99999, 
#               Neff => 3383,
#               Neff_I => 0, 
#               Neff_D => 0,
#               freq => [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
#         );

# %reflection_positions = ( 7 => 6, 8 => 7);
#                       template => query


sub conservation_level
{
    my ($q_hhm_obj, $t_hhm_obj, $important_positions, $reflection_pos) = @_;
    
    my  @scores;
    my (@probs1, @probs2);##{{MM ed.}}
    my ($frqs1, $frqs2);##{{MM ed.}}
    my ($ent1, $ent2, $rat);##{{MM ed.}}
    my ($n, $s1, $s2 );##{{MM ed.}}
    
    foreach my $cons_positions (@$important_positions)
    {
        my $sum = 0;
    
        foreach my $position (@$cons_positions)
        {
            if(defined($reflection_pos->{$position}))
            {
##{{MM ed.}}                push(@scores, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{M_M});
##{{MM ed.}}                push(@scores, $t_hhm_obj->{stats_hash}->{$position}->{M_M});

                ##{{MM ed.
                splice @probs1;
                splice @probs2;

                push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{M_M};
                ##push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{M_I};
                ##push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{M_D};
                ##push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{I_M};
                ##push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{I_I};
                ##push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{D_M};
                ##push @probs1, $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{D_D};

                push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{M_M};
                ##push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{M_I};
                ##push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{M_D};
                ##push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{I_M};
                ##push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{I_I};
                ##push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{D_M};
                ##push @probs2, $t_hhm_obj->{stats_hash}->{$position}->{D_D};

                $frqs1 = $q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{freq};
                $frqs2 = $t_hhm_obj->{stats_hash}->{$position}->{freq};
                $ent1 = Stats::entropy( $frqs1 );
                $ent2 = Stats::entropy( $frqs2 );

                ##if( $ent1 == 0 && $ent2 == 0 ) { $rat = 1.0; }
                ##else{ 
                ##    $ent2 = 0.00001 if( $ent2 == 0 );
                ##    $rat = $ent1 / $ent2;
                ##}
                ##for( $n = 0; $n <= $#probs1; $n++ ) {
                ##    $s1 = $probs1[$n];
                ##    $s2 = $probs2[$n];
                ##    $s2 = 0.0001 unless $s2;
                ##    push @scores, $s1 / $s2;
                ##}
                push @scores, @probs1;
                push @scores, @probs2;
                ##push @scores, Stats::distance( $frqs1, $frqs2 );
                ##push @scores, $rat;
                push @scores, $ent1;
                push @scores, $ent2;
                ##}}
##{{MM ed.}}                push(@scores, Stats::entropy($q_hhm_obj->{stats_hash}->{$reflection_pos->{$position}}->{freq}));
##{{MM ed.}}                push(@scores, Stats::entropy($t_hhm_obj->{stats_hash}->{$position}->{freq}));
            }
            else
            {
                push(@scores, -1);
                push(@scores, -1);
                ##push(@scores, -1);
                ##push(@scores, -1);
                ##push(@scores, -1);
                ##push(@scores, -1);
                ##push(@scores, -1);
                ##push(@scores, -1);
                push(@scores, -1);
                push(@scores, -1);
##{{MM ed.}}                push(@scores, -1);
##{{MM ed.}}                push(@scores, -1);
            }
        }
    }

    return @scores;
}

# ==============================================================================
# HHout obj:
# %hh_obj = (
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
# Positions 
# %pos = (
#               name => "2g3w.pos",
#               pd_pos => [15, 16],
#               exk_pos => [37,38,39],
#         );
# Mode: template:query
# Unknown hierarchies will be treated as $unknown

sub distribution_by_superfamily
{
    my ($hh_obj, $positions, $mode, $unknown) = @_;
    
    my %distribution;
    
    my $hits = $hh_obj->{hits};

    for my $key (keys %$hits)
    {
        my $possible_position;
        if($mode eq "template")
        {
            $possible_position = get_PDEXK_positions($positions, $hh_obj->{hits}->{$key}->{template});
        }
        else
        {
            $possible_position = get_PDEXK_positions($positions, $hh_obj->{query});
        }
        if(defined($possible_position))
        {
            my $alignment_mode = test_aligned_region($hh_obj, $possible_position, $key, $mode);
            if($alignment_mode != 0)
            {
                if($hits->{$key}->{hierarchy} eq "Nan")
                {
                    $distribution{$unknown}++;
                }
                else
                {
                    $distribution{get_superfamily($hits->{$key}->{hierarchy})}++;
                } 
            }
        }   
    }

    return \%distribution;
}

# ==============================================================================
# Accepts c.52.1.1
# Returns c.52

sub get_superfamily
{
    my ($hierarchy) = @_;
    
    my @tmp = split(/\./, $hierarchy);
    my $superfamily = $tmp[0] . "." . $tmp[1];
    
    return $superfamily;
}


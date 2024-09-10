package Parsers;
use warnings;
use strict;
use File::Basename;
use IO::File;
require Exporter;
@Parsers::ISA    = qw(Exporter);

# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-05-09 17:39:58 +0300 (Sat, 09 May 2009) $
# $Revision: 55 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/Parsers.pm $
# ==============================================================================

# ==============================================================================
# Parses fasta format
# >test
# ab
# ac
# 
# Returns an array of:
# 
# my %obj = (
#             header => ">test",
#             seq    => "abac",
#           );

sub parse_fas
{
    my ($input) = @_;
    
    open INPUT, "<", $input or die "Cannot open INPUT file: $input!";
    
    my @objects;
   
    my $curr_obj;
   
    while(my $line = <INPUT>)
    {
        chomp($line);
    
        if($line !~ /^#/ && $line !~ /^\s*$/)
        {
            if($line =~ /^>/)
            {
                my %obj = (header => $line, seq => "");
                
                $curr_obj = \%obj;
                          
                push(@objects, \%obj);
            }
            else
            {
                $curr_obj->{seq} .= $line;
            }
        }
    }
    
    close INPUT;
    
    return \@objects;
}


# ==============================================================================
# Parses the following lines
# labels 1 2
# 1 0.996316 0.00368422 
# 1 0.996249 0.00375073
# 
# Returns an array of:
# 
# my %obj = (
#             class_label => 1,
#             prob_1      => 0.996316 ,
#             prob_2      => 0.00368422, 
#           );

sub parse_svm_prob
{
    my ($input) = @_;
    
    open INPUT, "<", $input or die "Cannot open INPUT file: $input!";
    
    my @lines;
   
    while(my $line = <INPUT>)
    {
        chomp($line);
        
        push(@lines, $line);
    }
    
    close INPUT;
    
    my @objects;
    
    if(scalar(@lines) > 1)
    {
        foreach my $line (@lines)
        {
            if($line =~ /^\d+\s+/)
            {
                my @info = split(/\s+/, $line);
                
                push(@objects, {class_label => $info[0],
                                prob_1      => $info[1],
                                prob_2      => $info[2]});
            }
        }
    }
    else
    {
        push(@objects, {class_label => -1,
                        prob_1      => -1,
                        prob_2      => -1});
    }
    
    return \@objects;
}


# ==============================================================================
# Parses the following lines
# 1 1:7.00 2:12.00 3:12.00 4:41.96 5:94846.64 6:95421.14 #2e52_A d1y88a2 prob=49.1
# 
# Returns an array of:
# 
# my %obj = (
#             class_label => 1,
#             comment     => "2e52_A d1y88a2 prob=49.1",
#             scores      => [7.00,12.00,12.00,41.96,94846.64,95421.14],
#           );

sub parse_svm
{
    my ($input) = @_;
    
    open INPUT, "<", $input or die "Cannot open INPUT file: $input!";
    
    my @objects;
   
    while(my $line = <INPUT>)
    {
        chomp($line);
        
        my $features;
        my $comment;
        
        my @data = split(/\s+#/, $line);
        
        if(@data == 2)
        {
            $features = $data[0];
            $comment  = $data[1];
        }
        elsif(@data == 1)
        {
            $features = $data[0];
        }
        else
        {
            die "ERR: $0: parse_svm: incorrect SVM format: $input!\n";
        }
        
        my @values = split(/\s+/, $features);
        
        my %obj = (
                    class_label => shift(@values),
                    comment     => $comment,
                  );

        my @scores;
        
        foreach my $value (@values)
        {
            my @info = split(":", $value);
            push(@scores, $info[1]);
        }
        
        $obj{scores} = \@scores;
        
        push(@objects, \%obj);
    }
    
    close INPUT;
    
    return \@objects;
}

# ==============================================================================
# Input is .hhm file type with many of such lines
# /home/minlag/Documents/svm_project/data_from_hhpred/scop70_1.75_hhm/d12asa_.hhm
# Returns
# %list_obj = (d12asa_ => "/home/minlag/Documents/svm_project/data_from_hhpred/scop70_1.75_hhm/d12asa_.hhm")
# 

sub parse_list
{
    my($input, $suffix) = @_;

    my $handle = new IO::File;

    my %list_obj;

    if($handle->open("< $input"))
    {
        while(my $line = <$handle>)
        {
            chomp($line);
            if($line ne "")
            {
                my $name = fileparse($line, $suffix);
                $list_obj{$name} = $line;
            }
        }
        $handle->close();
    }
    else
    {
        die "ERR: $0: Cannot open INPUT file: \'$input\'!";
    }

    return \%list_obj;
}


# ==============================================================================
# Input is .hhm file type with many of such lines
# A 158  *    *    *    *    *   *    *   *    *    *    *   *    *   *    *    *    *    *    *   0    158
#        0    *   *   *   *   *   *   3383    0   0
# Returns
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

sub parse_hhm
{
    my($input) = @_;

    my $handle = new IO::File;

    my %hhm_obj;

    if($handle->open("< $input"))
    {
        my $line = "";
        
        while($line !~ /^SEQ/ && !eof($handle))
        {
            $line = <$handle>;
            if($line =~ /^NEFF\s+([\d\.]+)/)
            {
                $hhm_obj{neff} = $1;
            }
        }
        
        my @sequences;
        my $curr_obj;
        
        while($line !~ /^#/ && !eof($handle))
        {
            $line = <$handle>;
            chomp($line);
            
            if($line !~ /^#/)
            {
                if($line =~ /^>/)
                {
                    my %obj = (header => $line, seq => "");
                    $curr_obj = \%obj;
                    push(@sequences, $curr_obj);
                }
                else
                {
                    $curr_obj->{seq} .= $line;
                }
            }
        }
        
        $hhm_obj{seq} = \@sequences;

        my @data;
        my %data_hash;
        while($line = <$handle>)
        {            
            ##{{MM ed.
            if( $line =~ /^HMM(.+)$/) {
                $line = $1;
                my  @res;
                push @res, $1 while( $line =~ /\s+(\w)/g );
                $data_hash{residues} = \@res;
            }
            ##}}
            if($line =~ /^(\w)+\s+(\d+)\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+[\d\*]+\s+(\d+)/)
            {
                my %obj = (amino_acid => $1, number => $2);
            
                my @info = split(/\s+/, $line);
                
                my @freq;

                for(my $i = 2; $i < scalar(@info) - 1; $i++)
                {
                    if($info[$i] eq "*")
                    {
                        push(@freq, 0);
                    }
                    else
                    {
                        push(@freq, 2**($info[$i] / (-1000)));
                    }
                }
                    
                $line = <$handle>;
#               M->M    M->I    M->D    I->M    I->I    D->M    D->D    Neff    Neff_I  Neff_D
#               0   *   *   *   *   0   *   3541    0   1000
                if($line =~ /^\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)\s+([\d\*]+)/)
                {
                    $obj{M_M}   = $1;
                    if($obj{M_M} eq "*") { $obj{M_M} = 99999; }
                    $obj{M_I} = $2;
                    if($obj{M_I} eq "*") { $obj{M_I} = 99999; }
                    $obj{M_D} = $3;
                    if($obj{M_D} eq "*") { $obj{M_D} = 99999; }
                    $obj{I_M}   = $4;
                    if($obj{I_M} eq "*") { $obj{I_M} = 99999; }
                    $obj{I_I} = $5;
                    if($obj{I_I} eq "*") { $obj{I_I} = 99999; }
                    $obj{D_M} = $6;
                    if($obj{D_M} eq "*") { $obj{D_M} = 99999; }
                    $obj{D_D} = $7;
                    if($obj{D_D} eq "*") { $obj{D_D} = 99999; }
                    $obj{Neff}   = $8;
                    if($obj{Neff} eq "*")  { $obj{Neff} = 99999; }
                    $obj{Neff_I} = $9;
                    if($obj{Neff_I} eq "*"){ $obj{Neff_I} = 99999; }
                    $obj{Neff_D} = $10;
                    if($obj{Neff_D} eq "*"){ $obj{Neff_D} = 99999; }
                }
                else
                {
                    print STDERR "WRN: hhm_parser: can't recognize: $line\n";
                }
                    
                $obj{freq} = \@freq;
                
                push(@data, \%obj);
                
                if(!defined($data_hash{$obj{number}}))
                {
                    $data_hash{$obj{number}} = \%obj;
                }
                else
                {
                    print STDERR "WRN: hhm_parser: the same amino acid number: $line\n";
                }
            }
        }   
        
        $hhm_obj{stats} = \@data;
        $hhm_obj{stats_hash} = \%data_hash;
        
        $handle->close();
    }
    else
    {
        die "ERR: $0: Cannot open INPUT file: \'$input\'!";
    }

    return \%hhm_obj;
}

# ==============================================================================
# Input consists of the following lines
# 2g3w.pos 2,15,16,37,38,39

# Returns an array of
# %obj = (
#               name => "2g3w.pos",
#               e_pos => [2],
#               pd_pos => [15, 16],
#               exk_pos => [37,38,39],
#         );
# 



sub parse_pos_list
{
    my($input) = @_;

    my $handle = new IO::File;

    my $list;

    if($handle->open("< $input"))
    {
        my @data;
        
        while(my $line = <$handle>)
        {
            if($line =~ /^(\S+)\s+([\*\d]+),(\d+),(\d+),(\d+),(\d+),(\d+),?(\d*)/)##{{MM ed.}}
            {
                push(@data, {name => $1, e_pos => [$2], pd_pos => [$3, $4], exk_pos => [$5, $6, $7, $8]}) if $8;##{{MM ed.}}
                push(@data, {name => $1, e_pos => [$2], pd_pos => [$3, $4], exk_pos => [$5, $6, $7]}) unless $8;
            }
            else
            {
                print STDERR "WRN: parse_pos_list: can't recognize: $line\n;";
            }
        }   

        $list = \@data;
        
        $handle->close();
    }
    else
    {
        die "ERR: $0: Cannot open INPUT file: $input!";
    }

    return $list;
}

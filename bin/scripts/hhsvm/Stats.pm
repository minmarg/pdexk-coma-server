package Stats;

use strict;
require Exporter;
@Stats::ISA = qw(Exporter);
@Stats::EXPORT = qw( mean variance );

# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-05-09 17:39:58 +0300 (Sat, 09 May 2009) $
# $Revision: 29 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/Stats.pm $
# ==============================================================================

sub mean
{
    my($values) = @_;
    
    my $sum = 0;
    my $counter = 0;

    foreach my $value (@$values)
    {
        $sum += $value;
        $counter++;
    }
    
    if($counter != 0)
    {
        return $sum / $counter;
    }
    
    return 0;
}

# ==============================================================================
sub variance
{
    my($values, $mean) = @_;
    
    if(!defined($mean))
    {
        $mean = mean($values);
    }

    my $sum = 0;
    my $counter = 0;
    
    foreach my $value (@$values)
    {
        $sum += ($value - $mean) ** 2;
        $counter++;
    }
    
    if($counter != 0)
    {
        return $sum / $counter;
    }
    
    return 0;
}

# ==============================================================================

sub wild_variance
{
    my($values, $mean) = @_;
    
    if(!defined($mean))
    {
        $mean = mean($values);
    }
    
    my $sum = 0;
    my $counter = 0;
    
    foreach my $value (@$values)
    {
        $sum += ($value - $mean)** 2;
        $counter++;
    }
    
    if($counter - 1 != 0)
    {
        return $sum / ($counter - 1);
    }
    
    return 0;
}

# ==============================================================================
sub entropy
{
    my($values) = @_;

    my $sum = 0;
    
    foreach my $value (@$values)
    {
        if($value != 0)
        {
            $sum += $value * log2($value);
        }
    }

    return (-1) * $sum;
}

sub log2
{
    my ($n) = @_;
    
    return log($n)/log(2);
}

## =============================================================================
## {{MM ed.}}
## Calculate relative entropy
##
sub relent
{
    my  $rprob1 = shift;
    my  $rprob2 = shift;
    my ($n, $rnt, $num, $den ) = (0,0,0,0);

    if( $#$rprob1 != $#$rprob2 ) {
        printf( STDERR "ERROR: relent: Dimensions of probability vectors incompatible.\n");
        return 1000.0;
    }
    for( $n = 0; $n <= $#$rprob1; $n++ ) {
        $num = $$rprob1[$n];
        $den = $$rprob2[$n];
        next if $num == 0 && $den == 0;
        $num = 0.00001 if $num == 0;
        $den = 0.00001 if $den == 0;
        $rnt += $num * log( $num / $den );
    }
    return $rnt;
}

## =============================================================================
## {{MM ed.}}
## Calculate distance between two vectors
##
sub distance
{
    my  $rprob1 = shift;
    my  $rprob2 = shift;
    my ($n, $dst, $v1, $v2 ) = (0,0,0,0);

    if( $#$rprob1 != $#$rprob2 ) {
        printf( STDERR "ERROR: relent: Dimensions of probability vectors incompatible.\n");
        return 1000.0;
    }
    for( $n = 0; $n <= $#$rprob1; $n++ ) {
        $v1 = $$rprob1[$n];
        $v2 = $$rprob2[$n];
        next if $v2 == 0 && $v2 == 0;
        $dst += ( $v1 - $v2 ) * ( $v1 - $v2 );
    }
    return 0.0 unless $dst;
    return sqrt( $dst );
}

# ==============================================================================

sub normalize
{
    my ($values) = @_;
    
    my $min;
    my $max;
    
    for my $value (@$values)
    {
        if((not defined $min) || $min > $value)
        {
            $min = $value;
        }
        
        if((not defined $max) || $max < $value)
        {
            $max = $value;
        }
    }
    
    my @normalized;
    
    if($min == $max)
    {
        for my $value (@$values)
        {
                push(@normalized, 1);
        }
    }
    else
    {
        for my $value (@$values)
        {
            push(@normalized, ($value - $min)/($max - $min));
        }
    }
    
    return \@normalized;
}

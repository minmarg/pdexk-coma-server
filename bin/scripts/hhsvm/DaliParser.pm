package DaliParser;

use strict;
use File::Basename;
use IO::File;
require Exporter;
@Parsers::ISA    = qw(Exporter);


# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-05-09 17:39:58 +0300 (Sat, 09 May 2009) $
# $Revision: 4 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/DaliParser.pm $
# ==============================================================================

# Returns an array of the following structure
# my %aln_obj = 
#                 (
#                     z_score => 5.2,
#                     query  => "AAA",
#                     subject => "BB-",
#                 );

sub parse_dali_aln
{
    my($input) = @_;

    my $handle = new IO::File;

    my @data;

    if ($handle->open("< $input"))
    {
        my $line = "";
    
        while(!eof($handle))
        {
            if($line =~ /Z-score=([\d\.]+)/)
            {
                my %aln_obj = (z_score => $1);
                
                $line = <$handle>;
                
                my $query = "";
                my $subject = "";
                
                while(!eof($handle) && $line !~ /Z-score=([\d\.]+)/)
                {
                    if($line =~ /^\s*Query\s+([A-Za-z\.]+)\s+/)
                    {
                        $query .= uc($1);
                    }
                    elsif($line =~ /^\s*Sbjct\s+([A-Za-z\.]+)\s/)
                    {
                        $subject .= uc($1);
                    }
                    
                    $line = <$handle>;
                }
                
                $aln_obj{query} = $query;
                $aln_obj{subject} = $subject;
                
                push(@data, \%aln_obj);
            }
            else
            {
                $line = <$handle>;
            }
        }
        
        
        $handle->close;
    }
    else
    {
        die "$0: Cannot open INPUT file: $input!";
    }

    return \@data;
}

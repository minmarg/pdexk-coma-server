# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-03-10 14:54:18 +0200 (Tue, 10 Mar 2009) $
# $Revision: 2 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/SUsage.pm $
# ==============================================================================

#* 
#  Simple usage message generator
#**

package SUsage;

use strict;
require Exporter;
@SUsage::ISA = qw(Exporter);
@SUsage::EXPORT = qw( usage );

sub usage
{
    my $script = shift;
    $script = $0 unless defined $script;

    open( SCRIPT, $script ) or die("Could not open $script: $!");
    while( <SCRIPT> ) {
    if( /^\s*#\*/ .. /^\s*#\*\*/ ) {
        /^\s*#\*?\*?/;
        print "$'";
        }
    }
    close SCRIPT;
}

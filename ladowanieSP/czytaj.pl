#!/usr/bin/perl
use strict;
use warnings;

foreach my $line ( <STDIN> )  {
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    my @pola = split /:/, $line;
    my $matrixSize = @pola;
#    print "$matrixSize"."$line"."\n";
    for (my $i=0; $i < $matrixSize; $i++) {
       $pola[$i] =~ s/^\s+//;
       $pola[$i] =~ s/\s+$//;
       if (($matrixSize == 1) && ($i == 0)){
           print "$pola[$i]";
       }
       if (($matrixSize == 2) && ($i == 0)){
           print "$pola[$i]:";
       }
       if (($matrixSize == 2) && ($i == 1)){
           print "$pola[$i]";
       }
       if (($matrixSize == 3) && ($i == 0)){
           print "$pola[$i]:";
       }
       if (($matrixSize == 3) && ($i == 1)){
           print "$pola[$i]:";
       }
       if (($matrixSize == 3) && ($i == 2)){
           print "$pola[$i]";
       }
    }
}


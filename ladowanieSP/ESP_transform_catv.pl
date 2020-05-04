#!/usr/bin/perl
#use warnings;
#use strict;
use List::Util qw( min max );
# use module
use XML::Simple;
use Data::Dumper;
my $working_dir="/home/goramate/skrypty/ladowanieSP/working"; 
my $out_dir="/home/goramate/skrypty/ladowanieSP/";
my $lineno=0;
#flaga drukowania SP
my $flag=0;
my $flaga_mozaiki=0;
my $kanal=0;
my $right_screen=0;
my $right_screen_flag=0;
my $right_list_flag=0;
my $class_list_flag=0;
my @kanaly;
my @right_screeny;
#wersja SP
my $wersja;
#technologia
my $technologia;
#right screeny
my %right_screens;
#typy kanalu
my %kind;
#dluga nazwa
my %Lng_nme;
#krotka nazwa
my %Sht_nme;
#rozdzielczosc
my %ResT;
#numer USI
my %USI;
#EPG ID
my %EPG_ID;
#zrodlo IP,DTH, DTT
my %Src;
#male logo
my %LogoRefb;
#duze logo
my %LogoRefs;
#lista uprawnieni
my %RightList;
my $strona_mozaiki=0;
#my @strony_mozaiki;
my %mozaika;
#wersja TSP
my $TSP_wersja;
#zmienna pomocnicza - informacje satelitarne dla aktualnego kanalu
my $akt_ON_ID=-1;
#lista z info z TSP
my %ON_ID;
#naglowek do wydruku
my $naglowek;
#nowy plik
my $lista="$working_dir/lista_kanalow.csv";
my $mozaika="$working_dir/mozaika.csv";
my $rs;


#parametry TSP -- nowe podejscie 
 my  %IP_parameters ={};
 #nowa funkcja do parsowania TSP
 sub initialize_TSP{

	 # create object
	 my $xml = new XML::Simple;
	 # read XML file
	 my $data = $xml->XMLin("working/TSP.txt");
	 #print Dumper(@$data->{'IP_S'}->{'S_IPList'}->{'IPSrv'});
	 foreach (@{$data->{'IP_S'}->{'S_IPList'}->{'IPSrv'}}){	
		 $IP_parameters->{$_->{'USI'}} = $_;		
	 }	
 }
# #inicjalizacja powyższego hasha z danymi z TSP 
 initialize_TSP;
#parametry TSP



initialize_TSP;
print Dumper($IP_parameters->{'443'}->{'IP'});

open FILE, "$working_dir/ESP.txt" or die $!;
while (<FILE>) {
	#print $lineno++;
#	print ": $_";
	#poczatek listy kanalow
	#"Version":"01.00.40",
	if ( /\"Version\"/ ) {
                my $tmp=$_;
                $tmp =~ s/\"Version\":\"//;
                $tmp =~ s/\",\n//;
         #       print "Wersja: $tmp \n";
                $wersja=$tmp;
	}
	
	#"Env":"IPTV_NEZ",
	 if ( /\"Env\"/ ) {
                my $tmp=$_;
                $tmp =~ s/\"Env\":\"//;
                $tmp =~ s/\",\n//;
              #  print "Technologia: $tmp \n";
                $technologia=$tmp;
        }
	#Rozpoznanie SP Dakoty
	if ( /Universe_DAKOTA/ ) {
                my $tmp=$_;
                my $tmp=$_;
                print "Technologia: ICU100 \n";
                $technologia="IPTV_Fiber_ICU100";
        }


	if ( /Chnl/  ) {
	#	print "PASUJE";
	}
         
	 if ( /\"Rights_ID\"/  ) {
#               print "\nRIGHTS: $_";
                my $tmp=$_;
                $tmp =~ s/\{"Rights_ID"://;
                $tmp =~ s/,\n//;
 #              print "RIGHT_SCREEN o numerze: $tmp \n";
		$right_screen_flag=1;
		$right_screen=$tmp;
		
   #             $kanal=$tmp;
  #              $flaga_mozaiki=0;
                push @right_screeny,  $right_screen;
	#	print "HELL@right_screeny";
		next;
        }
	  if ( /\"CLASS_LIST\"/  ) {
  #             print "LISTA_KLAS $_";
                $class_list_flag=1;
		next;
        }

	

	 if (( $right_screen_flag==1) && ($right_screen > 0) && ( $class_list_flag ==1) ) {

#                $right_screen_flag=0;
		$class_list_flag =0;
   #             print "RS:  $right_screen";
#		print "\nRS2: $_";
                 my $tmp=$_;
                 my $count = ($_ =~ s/]/]/g);
 #               print "\nRS3: $count";

                if ( $count != 1 ) {
                 #       print "\nLista praw3: $count";
 #                        $right_screen_flag=1;
			 $class_list_flag =1;
                }

                 $tmp =~ s/\[//;
                 $tmp =~ s/\]\}//;
                 $tmp =~ s/\n//;
		 $tmp =~ s/,//;
	
#		print "\nRS4: $tmp";	
                if ( exists $right_screens{$right_screen} )
                {
                #        $RightList{$kanal}="$RightList{$kanial}$tmp";
			$right_screens{$right_screen}="$right_screens{$right_screen},$tmp"; 
 #                       print "\nISTNIEJE";
                }
                else
                {
			$right_screens{$right_screen} =$tmp;
  #                      print "\nNIE ISTNIEJE";
                }
                 #print "\nLista praw6: $RightList{$kanal}; ";

        }
		


	#LCN
        if ( /\"LCN\"/  ) {
 #       	print "Kanal $_";
		my $tmp=$_;
		$tmp =~ s/\{"LCN"://;
		$tmp =~ s/,\n//;
#		print "Kanal o numerze: $tmp \n";
		$kanal=$tmp;
		$flaga_mozaiki=0;
		push @kanaly,  $kanal;
        }
	#mozaika
	if ( /\"Mosaic_List\"/ ) {
		 $flaga_mozaiki=1;
		 $kind{$kanal}="MOZAIKA";
	}
	
	
	if ( /\"USI\"/ && ($flaga_mozaiki > 0) ){
		 my $tmp=$_;
		 $tmp =~ s/\{"USI"://;		 
	     $tmp =~ s/\,\n//;
		 $tmp =~ s/\s//;
		#print "typ strony mozaiki: $tmp \n"; 
		#push @strony_mozaiki, $tmp;	
		$strona_mozaiki++;
		#print Dumper($IP_parameters->{$tmp}->{'IP'});
		$mozaika{$strona_mozaiki}="$tmp;$IP_parameters->{$tmp}->{'IP'}";
		#print $tmp;
		#print "STRONA MOZAIKI: $strona_mozaiki; $mozaika{$strona_mozaiki} ". Dumper($IP_parameters->{$tmp}->{'IP'});;
		
	}
	#strona mozaiki
	#"Template":"Box20"	
	if ( /\"Template\"/ ){
		 my $tmp=$_;
		 $tmp =~ s/"Template":"//;
	     $tmp =~ s/",\n//;
		#print "typ strony mozaiki: $tmp \n"; 
		#push @strony_mozaiki, $tmp;	
		
		$mozaika{$strona_mozaiki}="$mozaika{$strona_mozaiki};$tmp";
		#print "STRONA MOZAIKI: $strona_mozaiki; $mozaika{$strona_mozaiki}\n";
	}
	# "TargetLcn"
	if ( /\"TargetLcn\"/ ){
                 my $tmp=$_;
                 $tmp =~ s/.*"TargetLcn"://;
                 $tmp =~ s/}\n//;
                #print "nr kanalu zaiki: $tmp \n";
                               
                $mozaika{$strona_mozaiki}="$mozaika{$strona_mozaiki};$tmp";
                #print "STRONA MOZAIKI: $strona_mozaiki; $mozaika{$strona_mozaiki}\n";
        }

	if ( /\"SrvI\"/ ) {
		 $kind{$kanal}="SERWIS INTERAKTYWNY";
		#print "TECHMOL:$technologia\n";
		if ($technologia =~ m/IPTV_NEZ/){
		#	print "NEZ\n";
			$ON_ID{$kanal}=";;;;;;;;;;";
		}
		else {
			$ON_ID{$kanal}=";;;;;;;;";
		}
	}
	#typ kanalu
	if (($_ =~ m/\"Kind\"/) && ($kanal > 0)) {
	#		print "typ\n";
		 my $tmp=$_;
                $tmp =~ s/\"Kind":"//;
                $tmp =~ s/",\n//;
		$kind{$kanal}=$tmp;
	}
	#"Lng_nme":"Public TV of Armenia",
	 if (($_ =~ m/\"Lng_nme\"/) && ($kanal > 0)) {
                my $tmp=$_;
                $tmp =~ s/\"Lng_nme":"//;
                $tmp =~ s/\n//;
                $tmp =~ s/",//;
		$tmp =~ s/;//;
                $Lng_nme{$kanal}=$tmp;
        }
	#"Sht_nme":"Al Aoula Inter"
	 if (($_ =~ m/\"Sht_nme\"/) && ($kanal > 0)) {
                my $tmp=$_;
                $tmp =~ s/\"Sht_nme":"//;
                $tmp =~ s/",\n//;
		$tmp =~ s/",//;
                $Sht_nme{$kanal}=$tmp;
        }
	

	#	 "ResT":"SD",
	  if (($_ =~ m/\"ResT\"/) && ($kanal > 0)) {
                my $tmp=$_;
                $tmp =~ s/\"ResT":"//;
                $tmp =~ s/",\n//;
                $ResT{$kanal}=$tmp;
        }
	# {"USI":200116,
	    if (($_ =~ m/\"USI\"/) && ($kanal > 0)) {
                my $tmp=$_;
		#$tmp =~ s/\{//;
                $tmp =~ s/.*\"USI"://;
                $tmp =~ s/,\n//;
                $USI{$kanal}=$tmp;
        }
	# {"EPG_ID":15055,
	 if (($_ =~ m/\"EPG_ID\"/) && ($kanal > 0)) {
                my $tmp=$_;
                #$tmp =~ s/\{//;
                $tmp =~ s/.*\"EPG_ID"://;
                $tmp =~ s/,\n//;
                $EPG_ID{$kanal}=$tmp;

	}
	# "Src":"DTH"
	  if (($_ =~ m/\"Src\"/) && ($kanal > 0)) {
                my $tmp=$_;
                #$tmp =~ s/\{//;
                $tmp =~ s/.*\"Src":"//;
                $tmp =~ s/",\n//;
                $Src{$kanal}=$tmp;

        }
	# LogoRefb
	# "LogoRefb":"_8e11b0e8793c6c8a9db8a35ea.default_sd_big__big",
         if (($_ =~ m/\"LogoRefb\"/) && ($kanal > 0)) {
                my $tmp=$_;
                #$tmp =~ s/\{//;
                $tmp =~ s/.*\"LogoRefb":"//;
                $tmp =~ s/",\n//;
                $LogoRefb{$kanal}=$tmp;
        }



	# "LogoRefs":"_91f6b119a2486ec2353988be8.default_sd__small",
	 if (($_ =~ m/\"LogoRefs\"/) && ($kanal > 0)) {
                my $tmp=$_;
                #$tmp =~ s/\{//;
                $tmp =~ s/.*\"LogoRefs":"//;
                $tmp =~ s/",\n//;
		$tmp =~ s/"//;
		$tmp =~ s/\n//;
                $LogoRefs{$kanal}=$tmp;
        }
	
	if (( $right_list_flag==1) && ($kanal > 0)) {
		
		 $right_list_flag=0;
		#print "\nLista praw: $_ ; kanal $kanal";		
		 my $tmp=$_;
		 my $count = ($_ =~ s/]/]/g);
		 #print "\nLista praw2: $count";
		
		if ( $count != 1 ) {
		#	 print "\nLista praw3: $count";
			 $right_list_flag=1;
		}

		 $tmp =~ s/\[//;
		 $tmp =~ s/\]\}//;	
		 $tmp =~ s/\n//;
		if ( exists $RightList{$kanal} )
		{ 		
			$RightList{$kanal}="$RightList{$kanal}$tmp";
		#	 print "\nLista praw4: jest";
		}
		else
		{
	         	$RightList{$kanal}=$tmp;
		#	 print "\nLista praw5: nie ma";
		}
		 #print "\nLista praw6: $RightList{$kanal}; ";

	}
	 if (($_ =~ m/\"List_Rights_ID\"/) && ($kanal > 0)) {
		$right_list_flag=1;	
	}
	#drukowanie	
	if ($flag==1) {
		print ": $_";	
	
	}
}


close FILE;

#wersja TSP

#odwrocenie hasha z USI i kanalami
my %rUSI = reverse %USI;


sub transformDTH 
{
	my $linia= shift @_;
	# <USI>256</USI>
	  if ( $linia =~ /<USI>/ ) {
                my $tmp=$_;
                $tmp =~ s/.*<USI>//;
                $tmp =~ s/<\/USI>\n//;
		#print "TEST: \"$tmp\"  WART \"$rUSI{$tmp}\"\n";
		 # print "Value EXISTS, but may be undefined.\n" if defined  $rUSI{ 1234567 };i
	   
	    #sprawdzenie czy kanal zostal wykorzystany w ESP 
	    if (defined  $rUSI{ $tmp } )  {
#		print "Kanal istnieje i jest w ESP na pozycji $rUSI{ $tmp }\n";
	#	$kanal=$rUSI{ $tmp }; 
		$kanal = $tmp;
		}
	     else {
#		print "Kanal nie zostal zdefiniowany.\n";
		$kanal=  max (@kanaly) +1;
		push @kanaly,  $kanal ;
		$kind{$kanal}="Kanal_nie_wykorzystany_w_ESP";
		}		
		#przypisanie danych satelitarnych
		$ON_ID{$kanal}=$akt_ON_ID;
        }

		# <ON_ID>10</ON_ID>
		  if ( $linia =~ /<ON_ID>/ ) {
        	        my $tmp=$_;
                	$tmp =~ s/.*<ON_ID>//;
	                $tmp =~ s/<\/ON_ID>\n//;
        #	        print "ON_ID:\"$tmp\"";
                 	$akt_ON_ID="$tmp;";
			

		}
	 #   <TS_ID>400</TS_ID>
		 if ( $linia =~ /<TS_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<TS_ID>//;
                        $tmp =~ s/<\/TS_ID>\n//;
              #          print "TS_ID:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID$tmp;";
		}
		
		 #  <Frq>11278</Frq>
		  if ( $linia =~ /<Frq>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Frq>//;
                        $tmp =~ s/<\/Frq>\n//;
             #           print "Frq:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID$tmp;";
                }
		
           	# <Pol>1</Pol>
		  if ( $linia =~ /<Pol>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Pol>//;
                        $tmp =~ s/<\/Pol>\n//;
            #            print "Pol:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID$tmp;";
                }

	         #   <Mod>2</Mod>
		    if ( $linia =~ /<Mod>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Mod>//;
                        $tmp =~ s/<\/Mod>\n//;
           #             print "Mod:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID$tmp;";
                }

	          #  <SbR>27500</SbR>	
		   if ( $linia =~ /<SbR>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<SbR>//;
                        $tmp =~ s/<\/SbR>\n//;
          #              print "SbR:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID$tmp;";
                  } 

          #  <FEC_I>3</FEC_I>
		 if ( $linia =~ /<FEC_I>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<FEC_I>//;
                        $tmp =~ s/<\/FEC_I>\n//;
     #                   print "FEC_I:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID${tmp}";
                  }

         #   <Rof>1</Rof>
		# if ( $linia =~ /<Rof>/ ) {
                 #       my $tmp=$_;
                  #      $tmp =~ s/.*<Rof>//;
                 #       $tmp =~ s/<\/Rof>\n//;
                  #      print "Rof:\"$tmp\"";
                 #       $akt_ON_ID="$akt_ON_ID${tmp}Rof;";
                 # }

         #   <Pil>1</Pil>
		# if ( $linia =~ /<Pil>/ ) {
                #        my $tmp=$_;
                #        $tmp =~ s/.*<Pil>//;
                #        $tmp =~ s/<\/Pil>\n//;
                #        print "Pil:\"$tmp\"";
                #        $akt_ON_ID="pil$akt_ON_ID${tmp}Pil;";
                #  }
	#	 <S_N>HBO HD</S_N>
		 if ( $linia =~ /<S_N>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<S_N>//;
                        $tmp =~ s/<\/S_N>\n//;
			  $tmp =~ s/&#x142;//;
      #                  print "S_N:\"$tmp\"";
			$ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                        ;
                  }

        # <S_ID>3105</S_ID>
		 if ( $linia =~ /<S_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<S_ID>//;
                        $tmp =~ s/<\/S_ID>\n//;
       #                 print "S_ID:\"$tmp\"";
                        $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                  }

       	#   <Type>1</Type>
		 if ( $linia =~ /<Type>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Type>//;
                        $tmp =~ s/<\/Type>\n//;
        #                print "Type:\"$tmp\"";
                        $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                  }

        # <C_R>1</C_R>
		 if ( $linia =~ /<C_R>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<C_R>//;
                        $tmp =~ s/<\/C_R>\n//;
         #               print "C_R:\"$tmp\"";
                        $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                  }




	

}




sub transformRFTV 
{
	my $linia= shift @_;
	# <USI>256</USI>
	  if ( $linia =~ /<USI>/ ) {
                my $tmp=$_;
                $tmp =~ s/.*<USI>//;
                $tmp =~ s/<\/USI>\n//;
		#print "TEST: \"$tmp\"  WART \"$rUSI{$tmp}\"\n";
		 # print "Value EXISTS, but may be undefined.\n" if defined  $rUSI{ 1234567 };i
	   
	    #sprawdzenie czy kanal zostal wykorzystany w ESP 
	    if (defined  $rUSI{ $tmp } )  {
#		print "Kanal istnieje i jest w ESP na pozycji $rUSI{ $tmp }\n";
		#$kanal=$rUSI{ $tmp }; 
		$kanal= $tmp ; 
		}
	     else {
#		print "Kanal nie zostal zdefiniowany.\n";
		$kanal=  max (@kanaly) +1;
		push @kanaly,  $kanal ;
		$kind{$kanal}="Kanal_nie_wykorzystany_w_ESP";
		}		
		#przypisanie danych satelitarnych
		$ON_ID{$kanal}=$akt_ON_ID;
        }

		# <ON_ID>10</ON_ID>
		  if ( $linia =~ /<ON_ID>/ ) {
        	        my $tmp=$_;
                	$tmp =~ s/.*<ON_ID>//;
	                $tmp =~ s/<\/ON_ID>\n//;
        #	        print "ON_ID:\"$tmp\"";
                 	$akt_ON_ID="$tmp;";
			

		}
	 #   <TS_ID>400</TS_ID>
		 if ( $linia =~ /<TS_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<TS_ID>//;
                        $tmp =~ s/<\/TS_ID>\n//;
              #          print "TS_ID:\"$tmp\"";
                        $akt_ON_ID="$akt_ON_ID$tmp;";
		}
		
	#	 <S_N>HBO HD</S_N>
		 if ( $linia =~ /<S_N>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<S_N>//;
                        $tmp =~ s/<\/S_N>\n//;
			 $tmp =~ s/;//g;
                #        print "S_N:\"$tmp\"";
			$ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                        ;
                  }

        # <S_ID>3105</S_ID>
		 if ( $linia =~ /<S_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<S_ID>//;
                        $tmp =~ s/<\/S_ID>\n//;
       #                 print "S_ID:\"$tmp\"";
                        $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                  }


        # <C_R>1</C_R>
		 if ( $linia =~ /<C_R>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<C_R>//;
                        $tmp =~ s/<\/C_R>\n//;
         #               print "C_R:\"$tmp\"";
                        $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                  }




}	



sub transformIPTV
{
        my $linia= shift @_;
        # <USI>256</USI>

	if ( $linia =~ /<USI>/ ) {
                my $tmp=$_;
                $tmp =~ s/.*<USI>//;
                $tmp =~ s/<\/USI>\n//;
               # print "TEST: \"$tmp\"  WART \"$rUSI{$tmp}\"\n";
                 # print "Value EXISTS, but may be undefined.\n" if defined  $rUSI{ 1234567 };i

            #sprawdzenie czy kanal zostal wykorzystany w ESP
            if (defined  $rUSI{ $tmp } )  {
                #  print "Kanal istnieje i jest w ESP na pozycji $rUSI{ $tmp }\n";
            #    $kanal=$rUSI{ $tmp };
		$kanal = $tmp ;
                }
             else {
                #print "Kanal nie zostal zdefiniowany.\n";
                $kanal=  max (@kanaly) +1;
                push @kanaly,  $kanal ;
                $kind{$kanal}="Kanal_nie_wykorzystany_w_ESP";
                }
        
         }

             #    <ON_ID>10</ON_ID>
                  if ( $linia =~ /<ON_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<ON_ID>//;
                        $tmp =~ s/<\/ON_ID>\n//;
                        #print "ON_ID:\"$tmp\"";
		       #$ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
			 $ON_ID{$kanal}="$tmp"
                }
  #  		    <TS_ID>320</TS_ID>
		if ( $linia =~ /<TS_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<TS_ID>//;
                        $tmp =~ s/<\/TS_ID>\n//;
                        #print "TS_ID:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";                       
                }


	   #     <S_ID>419</S_ID>
		if ( $linia =~ /<S_ID>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<S_ID>//;
                        $tmp =~ s/<\/S_ID>\n//;
                        #print "S_ID:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                }

	    #    <Type>1</Type>
		if ( $linia =~ /<Type>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Type>//;
                        $tmp =~ s/<\/Type>\n//;
                        #print "type:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                }

   #     <IP>232.0.6.139</IP>
		if ( $linia =~ /<IP>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<IP>//;
                        $tmp =~ s/<\/IP>\n//;
                        #print "IP:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                }

       # <Port>5500</Port>
		if ( $linia =~ /<Port>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Port>//;
                        $tmp =~ s/<\/Port>\n//;
                        #print "Port:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                }

     #   <Ptcl>0</Ptcl>
		if ( $linia =~ /<Ptcl>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<Ptcl>//;
                        $tmp =~ s/<\/Ptcl>\n//;
                        #print "Ptcl:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp;$sname";
                }

      #  <S_N>TVP2</S_N>
		if ( $linia =~ /<S_N>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<S_N>//;
                        $tmp =~ s/<\/S_N>\n//;
			$tmp =~ s/;//;
                        #print "S_N:\"$tmp\"";
                        my $sname="$tmp";
                       #$ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                }

       # <C_R>1</C_R>
		if ( $linia =~ /<C_R>/ ) {
                        my $tmp=$_;
                        $tmp =~ s/.*<C_R>//;
                        $tmp =~ s/<\/C_R>\n//;
                        #print "C_R:\"$tmp\"";
                       $ON_ID{$kanal}="$ON_ID{$kanal};$tmp";
                }

}










open FILE, "$working_dir/TSP.txt" or die $!;

while(<FILE>) {

 #        print $_;
	#<Version>
	  if ( /<Version>/ ) {
                my $tmp=$_;
                $tmp =~ s/<Version>//;
                $tmp =~ s/<\/Version>\n//;
	#                print "Wersja TSP: $tmp \n";
                $TSP_wersja=$tmp;
        }

	if ($technologia=~"IPTV_NEZ") {

	        transformDTH  $_;
		$naglowek="KANAL;typ;nazwa_dluga;Nazwa_krotka;Rozdzielczosc;USI;EPG_ID;typ_kanalu;male_logo;duze_logo;Lista_praw;ON_ID;TS_ID;Frequency;Polaryzacja;Modulacja;SymbolRate;FEC;Nazwa_TSP;Service_Id;Typ_ESP;C_R;\n";

	}
	elsif  ($technologia=~"IPTV_Fiber")
	 {
		transformIPTV $_;
		$naglowek="KANAL;typ;nazwa_dluga;Nazwa_krotka;Rozdzielczosc;USI;EPG_ID;typ_kanalu;male_logo;duze_logo;Lista_praw;ON_ID;TS_ID;S_ID;Type;IP;Port;Protocol;Service_Name;Content_Rights;\n";

	}
	 elsif  ($technologia=~"IPTV_EZ")
         {
                transformIPTV $_;
                $naglowek="KANAL;typ;nazwa_dluga;Nazwa_krotka;Rozdzielczosc;USI;EPG_ID;typ_kanalu;male_logo;duze_logo;Lista_praw;ON_ID;TS_ID;S_ID;Type;IP;Port;Protocol;Service_Name;Content_Rights;\n";

        }
	 elsif  ($technologia=~"IPTV_RFTV")
         {

		transformRFTV  $_;
                $naglowek="KANAL;typ;nazwa_dluga;Nazwa_krotka;Rozdzielczosc;USI;EPG_ID;typ_kanalu;male_logo;duze_logo;Lista_praw;ON_ID;TS_ID;nn;S_ID;nazwaESP;nm;wersjaSP;\n";
       }


	
}
close(FILE);

$mozaika="$out_dir/$technologia/mozaika.csv";
$lista="$out_dir/$technologia/lista_kanalow.csv";
$rs="$out_dir/$technologia/lista_right_screenow.csv";
#print "PLIK KTOREGO NIE MA: $mozaika";
open MOZAIKA, ">$mozaika"  or die $!;
open LISTA, ">$lista"  or die $!;
open RSLIST, ">$rs"  or die $!;

 print "Technologia:\t$technologia\n";
 $TSP_wersja =~ s/\s//g;
 print "Wersja ESP:\t$wersja \n";
 print "Wersja TSP:\t$TSP_wersja \n";
 print LISTA $naglowek;

 foreach my $p (@kanaly)
                    {
     print LISTA "$p;$kind{$p};$Lng_nme{$p};$Sht_nme{$p};$ResT{$p};$USI{$p};$EPG_ID{$p};$Src{$p};$LogoRefs{$p};$LogoRefb{$p};$RightList{$p};$ON_ID{$USI{$p}};T${TSP_wersja}_E${wersja};\n";
#     print  "$p;ZZZZ$kind{$p};$Lng_nme{$p};$Sht_nme{$p};$ResT{$p};$USI{$p};$EPG_ID{$p};$Src{$p};$LogoRefs{$p};$LogoRefb{$p};$RightList{$p};$ON_ID{$USI{$p}};T${TSP_wersja}_E${wersja};\n";
                    }


 for ( my $i=1; $i<=$strona_mozaiki; $i++)
                    {
		 print MOZAIKA "$technologia;$i;$mozaika{$i}\n"
                    }
#print "LISTA RIGHTSCREENow\n";
foreach my $p (@right_screeny){

	print RSLIST "$p;$right_screens{$p}\n";


}
close $mozaika;
close $lista;
close $rs;


#!/bin/bash 
working_dir="/home/goramate/skrypty/ladowanieSP/working";
out_dir="/home/goramate/skrypty/ladowanieSP";
transform_script="/home/goramate/skrypty/ladowanieSP/ESP_transform_catv.pl";


echo "STARTER";
if [ $# -lt 1 ] 
then 
	echo "Podaj nazwe pliku do analizy";
	exit;
fi;
if [ ! -e $1 ]
then
	 echo "Plik nie istnieje!";
	exit;
fi;
if [[ $1 =~ ".*IPTV_EZ.*" ]] 
then
	echo "Technologia IPTV";
	technologia="IPTV_EZ";
	mv $out_dir/IPTV_EZ/lista_kanalow.csv $out_dir/IPTV_EZ/old_lista_kanalow.csv
	mv $out_dir/IPTV_EZ/mozaika.csv $out_dir/IPTV_EZ/old_mozaika.csv
fi;

if [[ $1 =~ ".*IPTV_NEZ.*" ]]
then
        echo "Technologia DTH";
	technologia="IPTV_NEZ";
        mv $out_dir/IPTV_NEZ/lista_kanalow.csv $out_dir/IPTV_NEZ/old_lista_kanalow.csv
        mv $out_dir/IPTV_NEZ/mozaika.csv $out_dir/IPTV_NEZ/old_mozaika.csv
fi;

if [[ $1 =~ ".*IPTV_Fiber.*Default.*" ]]
then
        echo "####Technologia FTTH $1";
	technologia="IPTV_Fiber";
        mv $out_dir/IPTV_Fiber/lista_kanalow.csv $out_dir/IPTV_Fiber/old_lista_kanalow.csv
        mv $out_dir/IPTV_Fiber/mozaika.csv $out_dir/IPTV_Fiber/old_mozaika.csv
fi;







echo "ANALIZA PLIKU: $1";
echo "WYPAKOWUJE PLIK DO KATALOGU: $working_dir";
tar -xvf $1 -C $working_dir;
plik=${1##*/};
wersja_SP=${plik:0:22};

#cat $working_dir/$wersja_SP/ESP*  | sed 's/,/,\n/g' | sed 's/{/\n{/g' |  sed 's/\[/\n\[/g' |  sed 's/}/}\n/g' > $working_dir/ESP.txt
cat $working_dir/$wersja_SP/ESP*  | sed -e "s/}, {/},{/g" | ./czytaj.pl | sed 's/,/,\n/g' | sed 's/{/\n{/g' | sed 's/\[/\n\[/g' | sed 's/}/}\n/g' | sed 's/\[ {/\[{/g' | sed 's/} \]/}]/g' | sed ':a;N;$!ba;s/,\n\"TargetEP\":\n{ }\n,\n\"LogoRef\":\"\"}/}/g' > $working_dir/ESP.txt

#awk -f filtr.awk $working_dir/ESP.txt
cp  $working_dir/$wersja_SP/TSP* $working_dir/TSP.txt
perl $transform_script 
echo "END"; 

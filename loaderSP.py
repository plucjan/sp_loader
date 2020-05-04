#!/usr/bin/python

import json
import xml.etree.ElementTree as xmlTree
 
working_dir = "/home/goramate/skrypty/ladowanieSP/working/"
out_dir = "/home/goramate/skrypty/ladowanieSP/"

# right screens
right_screens = {}

# mosaic
mosaic = []

# channel list
channels = []

# esp
epg_id = {}
usi = {}
src = {}
sht_nme = {}
lng_nme = {}
kind = {}
rest = {}
logo_big = {}
logo_small = {}
list_rights_id = {}

# tsp
on_id = {}
ts_id = {}
s_id = {} #
typee = {} #
ip = {}
port = {}
ptcl = {}
s_n = {} #
c_r = {} #
st_values = {}

tsp = xmlTree.parse(working_dir + 'TSP.xml').getroot()
tsp_version = tsp.findtext("Version")

with open (working_dir + "ESP.json") as esp_file:
    data = json.load(esp_file);
    esp_version = data["Version"]
    tech = data["Env"]
    for univers_list in data["UNIVERS_LIST"]:
        name = univers_list["Name"]
        if "Universe_DAKOTA" in name:
            tech = tech + '_ICU100'
        for list_rights in univers_list["List_Rights"]:
            rights_id = list_rights["Rights_ID"]
            for soid_list in list_rights["SOID_List"]:
                for class_list in soid_list["CLASS_LIST"]:
                    if rights_id in right_screens:
                        right_screens[rights_id] = right_screens[rights_id] + ', ' + str(class_list)
                    else:
                        right_screens[rights_id] = str(class_list)
        for bqt_list in univers_list["Bqt_List"]:
            for chnl_list in bqt_list["Chnl_List"]:
		if "Mosaic_List" in chnl_list:
                    for mosaic_list in chnl_list["Mosaic_List"]:
                        for page_list in mosaic_list["PageList"]:
                            tmp_usi = page_list["USI"]
                            template = page_list["Template"]
                            if tech != "IPTV_NEZ":
                                for ipsrv in tsp.findall(".//IPSrv"):
                                    if ipsrv.findtext("USI") == str(tmp_usi):
                                        mosaic.append(str(tmp_usi) + ";" + ipsrv.findtext("IP") + ";" + template)
                            else:
                                mosaic.append(str(tmp_usi) + ";;" + template)
                            for cell_list in page_list["CellList"]:
                                mosaic[-1] = mosaic[-1] + ";" + str(cell_list["TargetLcn"])
                channels.append(chnl_list["LCN"])
                lcn = chnl_list["LCN"]
                if "Srv_List" in chnl_list:
                    for srv_list in chnl_list["Srv_List"]:
                        epg_id[lcn] = srv_list["EPG_ID"]
                        usi[lcn] = srv_list["USI"]
                        src[lcn] = srv_list["Src"]
                        sht_nme[lcn] = srv_list["Sht_nme"]
                        lng_nme[lcn] = srv_list["Lng_nme"]
                        kind[lcn] = srv_list["Kind"]
                        rest[lcn] = srv_list["ResT"]
                        logo_big[lcn] = srv_list["LogoRefb"]
                        logo_small[lcn] = srv_list["LogoRefs"]
                        list_rights_id[lcn] = ''
                        for rights in srv_list["List_Rights_ID"]:
                            list_rights_id[lcn] = list_rights_id[lcn] + str(rights)
                elif "SrvI" in chnl_list:
                    kind[lcn] = "SERWIS INTERAKTYWNY"
                    sht_nme[lcn] = chnl_list["SrvI"]["Sht_nme"].rstrip()
                    lng_nme[lcn] = chnl_list["SrvI"]["Lng_nme"].rstrip()
                    logo_big[lcn] = chnl_list["SrvI"]["LogoRefb"]
                    logo_small[lcn] = chnl_list["SrvI"]["LogoRefs"]
                elif lcn == 0:
                    kind[lcn] = "MOZAIKA"

def tspNotNEZ():
    for ipsrv in tsp.findall("./IP_S/S_IPList/IPSrv"):
        tmpLCN = []
        usiTSP = int(ipsrv.findtext("USI"))
        if usiTSP in usi.values():
            for keyLCN, valUSI in usi.items():
                if usiTSP == valUSI:
                    tmpLCN.append(keyLCN)
        else:
            tmpLCN.append(max(channels) + 1)
            kind[tmpLCN[0]] = "Kanal_nie_wykorzystany_w_ESP"
            usi[tmpLCN[0]] = usiTSP
            channels.append(tmpLCN[0])
        for valLCN in tmpLCN:
            on_id[valLCN] = ipsrv.findtext("ON_ID")
            ts_id[valLCN] = ipsrv.findtext("TS_ID")
            s_id[valLCN] = ipsrv.findtext("S_ID")
            typee[valLCN] = ipsrv.findtext("Type")
            ip[valLCN] = ipsrv.findtext("IP")
            port[valLCN] = ipsrv.findtext("Port")
            ptcl[valLCN] = ipsrv.findtext("Ptcl")
            s_n[valLCN] = ipsrv.findtext("S_N").replace(u"\u2013", "-")
            c_r[valLCN] = ipsrv.findtext("C_R")

def tspNEZ():
    for st in tsp.findall("./DTH_S/SAT_List/SAT/ST_List/*"):
        tmpST = st.findtext("ON_ID") + ";" + st.findtext("TS_ID") + ";" + st.findtext("Frq") + ";" + st.findtext("Pol") + ";" + st.findtext("Mod") + ";" + st.findtext("SbR") + ";" + st.findtext("FEC_I")
        for ssrv in st.findall("./S_SList/SSrv"):
            tmpLCN = []
            usiTSP = int(ssrv.findtext("USI"))
            if usiTSP in usi.values():
                for keyLCN, valUSI in usi.items():
                    if usiTSP == valUSI:
                        tmpLCN.append(keyLCN)
            else:
                tmpLCN.append(max(channels) + 1)
                kind[tmpLCN[0]] = "Kanal_nie_wykorzystany_w_ESP"
                usi[tmpLCN[0]] = usiTSP
                channels.append(tmpLCN[0])
            for valLCN in tmpLCN:
                st_values[valLCN] = tmpST
                s_n[valLCN] = ssrv.findtext("S_N")
                s_id[valLCN] = ssrv.findtext("S_ID")
                typee[valLCN] = ssrv.findtext("Type")
                c_r[valLCN] = ssrv.findtext("C_R")

version = "T" + tsp_version + "_E" + esp_version

print "Technologia:\t" + tech
print "Wersja ESP:\t" + esp_version
print "Wersja TSP:\t" + tsp_version

list_path = out_dir + tech + "/lista_kanalow.csv"
rs_path = out_dir + tech + "/lista_right_screenow.csv"
moz_path = out_dir + tech + "/mozaika.csv"

list_file = open(list_path, "w+")
if tech != "IPTV_NEZ":
    tspNotNEZ()

    list_file.write("KANAL;typ;nazwa_dluga;Nazwa_krotka;Rozdzielczosc;USI;EPG_ID;typ_kanalu;male_logo;duze_logo;Lista_praw;ON_ID;TS_ID;S_ID;Type;IP;Port;Protocol;Service_Name;Content_Rights;Version\n")
    for lcnID in channels:
        if kind[lcnID] == "SERWIS INTERAKTYWNY":
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";" + lng_nme[lcnID] + ";" + sht_nme[lcnID] + ";;;;;" + logo_small[lcnID] + ";" + logo_big[lcnID] + ";;;;;;;;;;;" + version + "\n").encode('ISO-8859-2'))
        elif kind[lcnID] == "MOZAIKA":
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";;;;;;;;;;;;;;;;;;;" + version + "\n").encode('ISO-8859-2'))
        elif kind[lcnID] == "Kanal_nie_wykorzystany_w_ESP":
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";;;;" + str(usi[lcnID]) + ";;;;;;" + on_id[lcnID] + ";" + ts_id[lcnID] + ";" + s_id[lcnID] + ";" + typee[lcnID] + ";" + ip[lcnID] + ";" + port[lcnID] + ";" + ptcl[lcnID] + ";" + s_n[lcnID] + ";" + c_r[lcnID] + ";" + version + "\n").encode('ISO-8859-2'))
        else:
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";" + lng_nme[lcnID] + ";" + sht_nme[lcnID] + ";" + rest[lcnID] + ";" + str(usi[lcnID]) + ";" + str(epg_id[lcnID]) + ";" + src[lcnID] + ";" + logo_small[lcnID] + ";" + logo_big[lcnID] + ";" + list_rights_id[lcnID] + ";" + on_id[lcnID] + ";" + ts_id[lcnID] + ";" + s_id[lcnID] + ";" + typee[lcnID] + ";" + ip[lcnID] + ";" + port[lcnID] + ";" + ptcl[lcnID] + ";" + s_n[lcnID] + ";" + c_r[lcnID] + ";" + version + "\n").encode('ISO-8859-2'))

else:
    tspNEZ()

    list_file.write("KANAL;typ;nazwa_dluga;Nazwa_krotka;Rozdzielczosc;USI;EPG_ID;typ_kanalu;male_logo;duze_logo;Lista_praw;ON_ID;TS_ID;Frequency;Polaryzacja;Modulacja;SymbolRate;FEC;Nazwa_TSP;Service_Id;Typ_ESP;C_R;Version\n")
    for lcnID in channels:
        if kind[lcnID] == "SERWIS INTERAKTYWNY":
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";" + lng_nme[lcnID] + ";" + sht_nme[lcnID] + ";;;;;" + logo_small[lcnID] + ";" + logo_big[lcnID] + ";;;;;;;;;;;;;" + version + "\n").encode('ISO-8859-2'))
        elif kind[lcnID] == "MOZAIKA":
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";;;;;;;;;;;;;;;;;;;;;" + version + "\n").encode('ISO-8859-2'))
        elif kind[lcnID] == "Kanal_nie_wykorzystany_w_ESP":
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";;;;" + str(usi[lcnID]) + ";;;;;;" + st_values[lcnID] + ";" + s_n[lcnID] + ";" + s_id[lcnID] + ";" + typee[lcnID] + ";" + c_r[lcnID] + ";" + version + "\n").encode('ISO-8859-2'))
        else:
            list_file.write((str(lcnID) + ";" + kind[lcnID] + ";" + lng_nme[lcnID] + ";" + sht_nme[lcnID] + ";" + rest[lcnID] + ";" + str(usi[lcnID]) + ";" + str(epg_id[lcnID]) + ";" + src[lcnID] + ";" + logo_small[lcnID] + ";" + logo_big[lcnID] + ";" + list_rights_id[lcnID] + ";" + st_values[lcnID] + ";" + s_n[lcnID] + ";" + s_id[lcnID] + ";" + typee[lcnID] + ";" + c_r[lcnID] + ";" + version + "\n").encode('ISO-8859-2'))

list_file.close()

rs_file = open(rs_path, "w+")
for r_id in sorted(right_screens):
    rs_file.write(str(r_id) + ";" + right_screens[r_id] + "\n")
rs_file.close()

moz_file = open(moz_path, "w+")
for idx, mos in enumerate(mosaic, 1):
    moz_file.write(tech + ";" + str(idx) + ";" + mos + "\n")
moz_file.close()


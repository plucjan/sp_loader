set +

echo "./analiza_new.sh /data/viasp/SDRP/PRO/IPTV_Fiber/ServicePlan/Default/`ls -1t /data/viasp/SDRP/PRO/IPTV_Fiber/ServicePlan/Default/ | head -n1`" |sh
echo "./analiza_new.sh /data/viasp/SDRP/PRO/IPTV_EZ/ServicePlan/Default/`ls -1t /data/viasp/SDRP/PRO/IPTV_EZ/ServicePlan/Default/ | head -n1`" |sh
echo "./analiza_new.sh /data/viasp/SDRP/PRO/IPTV_NEZ/ServicePlan/Default/`ls -1t /data/viasp/SDRP/PRO/IPTV_NEZ/ServicePlan/Default/ | head -n1`" |sh
echo "./analiza.sh /data/viasp/SDRP/PRO/IPTV_RFTV/ServicePlan/Default/`ls -1t /data/viasp/SDRP/PRO/IPTV_RFTV/ServicePlan/Default/ | head -n1`" |sh
#Dakota
echo "./analiza_new.sh /data/viasp/SDRP/PRO/IPTV_Fiber/ServicePlan/00214C_ICU100_2/` ls -1t /data/viasp/SDRP/PRO/IPTV_Fiber/ServicePlan/00214C_ICU100_2/ | head -n1`" |sh
./ladowanie_do_bazy.sh

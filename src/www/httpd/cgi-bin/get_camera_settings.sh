#!/bin/sh

export PATH=$PATH:/mnt/mmc/sonoff-hack/bin:/mnt/mmc/sonoff-hack/sbin:/mnt/mmc/sonoff-hack/usr/bin:/mnt/mmc/sonoff-hack/usr/sbin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mnt/mmc/sonoff-hack/lib

if [ -f /tmp/privacy ]; then
    SWITCH_ON="no"
else
    SWITCH_ON="yes"
fi
MOTION_DETECTION=$(sqlite3 /mnt/mtd/db/ipcsys.db "select c_enable from t_mdarea where c_index=0;")
if [ "$MOTION_DETECTION" == "0" ]; then
    MOTION_DETECTION="no"
else
    MOTION_DETECTION="yes"
fi
SENSITIVITY=$(sqlite3 /mnt/mtd/db/ipcsys.db "select c_sensitivity from t_mdarea where c_index=0;")
if [ "$SENSITIVITY" == "0" ]; then
    SENSITIVITY="off"
elif [ "$SENSITIVITY" == "25" ]; then
    SENSITIVITY="low"
elif [ "$SENSITIVITY" == "50" ]; then
    SENSITIVITY="medium"
elif [ "$SENSITIVITY" == "75" ]; then
    SENSITIVITY="high"
fi
LOCAL_RECORD=$(sqlite3 /mnt/mtd/db/ipcsys.db "select c_enabled from t_record_plan where c_recplan_no=1;")
if [ "$LOCAL_RECORD" == "0" ]; then
    LOCAL_RECORD="no"
else
    LOCAL_RECORD="yes"
fi
IR=$(sqlite3 /mnt/mtd/db/ipcsys.db "select c_param_value from t_sys_param where c_param_name=\"InfraredLamp\";")
if [ "$IR" == "2" ]; then
    IR="auto"
elif [ "$IR" == "0" ]; then
    IR="on"
elif [ "$IR" == "1" ]; then
    IR="off"
fi
ROTATE=$(sqlite3 /mnt/mtd/db/ipcsys.db "select c_param_value from t_sys_param where c_param_name=\"mirror\";")
if [ "$ROTATE" == "0" ]; then
    ROTATE="no"
else
    ROTATE="yes"
fi

printf "Content-type: application/json\r\n\r\n"
printf "{\n"
printf "\"%s\":\"%s\",\n" "SWITCH_ON"               "$SWITCH_ON"
printf "\"%s\":\"%s\",\n" "MOTION_DETECTION"        "$MOTION_DETECTION"
printf "\"%s\":\"%s\",\n" "SENSITIVITY"             "$SENSITIVITY"
printf "\"%s\":\"%s\",\n" "LOCAL_RECORD"            "$LOCAL_RECORD"
printf "\"%s\":\"%s\",\n" "IR"                      "$IR"
printf "\"%s\":\"%s\" \n" "ROTATE"                  "$ROTATE"
printf "}"

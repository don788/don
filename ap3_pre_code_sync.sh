#!/bin/bash
#######################################################

LOG="/tmp/rsync.log"
TMP="/tmp/tmp.txt"
DATE=`/bin/date +"%F_%H_%M_%S"`
resultstatus=1
#######################################################
format() {
         echo "$DATE" >> "$LOG"
         echo "----------------------------------" >> "$LOG"
         cat "$TMP" >> "$LOG"
         rm -f "$TMP"
        }
#终端颜色
function font
{
  while (($#!=0))
  do
      case $1 in
          -b      )   echo -ne " ";;
          -t      )   echo -ne "    ";;
          -n      )   echo -ne "\n";;
          -black  )   echo -ne "\033[30m";;
          -red    )   echo -ne "\033[31m";;
          -green  )   echo -ne "\033[32m";;
          -yellow )   echo -ne "\033[33m";;
          -blue   )   echo -ne "\033[34m";;
          -purple )   echo -ne "\033[35m";;
          -cyan   )   echo -ne "\033[36m";;
          -gray   )   echo -ne "\033[37m";;
          -reset  )   echo -ne "\033[0m";;
          -h|-help|--help )       echo "Usage: font -color1 message1 -color2 message2 ...";
                                  echo "eg:    font -red [ -blue message1 message2 -red ]";;
          *       )   echo -ne "$1";;
      esac
      shift
  done
}

#自定义显示颜色
statuscolor(){
    if [ $resultstatus -eq 0 ];then
        discolors="#008800"
        tercolors="green"
        disstatus="Ok"
    else
        discolors="red"
        tercolors="red"
        disstatus="Fail"
    fi
}
#自定义输出
printhtml=0
for argument in $(echo $*)
  do 
    case "$argument" in
      colorhtml)
        printhtml=1
      esac
  done
echotitle(){
    statuscolor
    if [[ -t 1 ]];then
        font -purple "$result ..." -reset -n
    else
        echo  "<a style='color:#0000FF;font-weight:bold;font-size:16px'>    $result ...</a>"
        #font -purple "$result ..." -reset -n
    fi
}
#自定义输出
echoinfo(){
    statuscolor
    if [[ -t 1 ]];then
        font -t -$tercolors "$result"  -reset -n
    else
        echo "<a style='color: $discolors;font-weight:bold;font-size:15px' >    $result</a>"
        #font -t -$tercolors "$result"  -reset -n
    fi
}

appre3code(){
    Rsync_server="10.181.1.4"
    Rsync_mode="HQAPPRE3CODE"
    Rsync_bin="/usr/bin/rsync"
    Local_path="/www/hqap3/"
    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|.git/|.env*|.docker|docker-compose.*.yml|public/uploads/*|var/backup|var/log/*|var/run/*|var/tmp/*"
    rsynctoweb
}

rsynctoweb(){
    if [ "$rsync_exclude" ]
    then
      IFS='|'
      exclude_arr=($rsync_exclude)
      for e_arr in ${exclude_arr[@]}
        do
            echo $e_arr >>/tmp/${DATE}_excludefile.txt
        done
      result=$("$Rsync_bin" -vzcrltD   --exclude-from="/tmp/${DATE}_excludefile.txt"  "$Rsync_server"::"$Rsync_mode"/  "$Local_path" 2>&1|tee -a "$TMP"|grep rsync|grep  "failed\|error")
    else
      result=$("$Rsync_bin" --vzcrltD   "$Rsync_server"::"$Rsync_mode"/  "$Local_path" 2>&1|tee -a  "$TMP"|grep rsync|grep "failed\|error")
    fi

  if [ -n "$result" ]; then
    resultstatus=1
    echoinfo
    result="Rsync change to web failed!"
    echoinfo
    exit 1
  else
    result="Rsync to web ok!"
    resultstatus=0
    echoinfo
  fi
  echo "====================================" >> "$LOG"
}


tag=0
for argument in $(echo $*)
    do 
      case "$argument" in
            allpltapi)
                tag=1
                allpltapi
                ;;  
            appre3code)
                tag=1
                appre3code
        esac
    done
if [ "$tag" -eq 0 ];then
    echo $"Usage: {appre3code}"
    exit 3
fi

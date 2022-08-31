#!/bin/bash
#auther:zaki
# version: 1.0.0
# desc: nginx_code_rsync.sh
# date: 2020/04/12


#######################################################

LOG="/tmp/rsync.log"
TMP="/tmp/tmp.txt"
DATE=`/bin/date +"%F_%H_%M_%S"`
Nginx_bin='/usr/local/webserver/nginx/sbin/nginx'
Rsync_bin="/usr/bin/rsync"
resultstatus=1
reloadnginx=0
echo "">$TMP
 # sed -i   '/ap3\/jixing\/pubconf/d' /usr/local/webserver/nginx/conf/nginx.conf
 # sed -i   '/ap3\/jixing\/domain/d' /usr/local/webserver/nginx/conf/nginx.conf
cleannginxfile() {
  #sed -i '/sites-enabled2\/ap3\/jixing\/jixing.conf/s/^ *#//' /usr/local/webserver/nginx/conf/nginx.conf 
  #rm -rf  /usr/local/webserver/nginx/conf/sites-enabled2/ap3
  sleep 0.0001
 }
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
    if [ $printhtml == 1 ];then
        echo  "<a style='color:#0000FF;font-weight:bold;font-size:16px'>    $result ...</a>"
    else
        font -purple "$result ..." -reset -n
        #font -purple "$result ..." -reset -n
    fi
}
#自定义输出
echoinfo(){
    statuscolor
    if [ $printhtml == 1 ];then
        echo "<a style='color: $discolors;font-weight:bold;font-size:15px' >    $result</a>"
    else
        font -t -$tercolors "$result"  -reset -n
        #font -t -$tercolors "$result"  -reset -n
    fi
}

apol3code(){
    Rsync_server="10.181.1.4"
    Rsync_mode="HQAPPRE3CODE"
    Rsync_bin="/usr/bin/rsync"
    Local_path="/www/hqap3/"
    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|.git/|.env*|.docker|docker-compose.*.yml|public/uploads/*|var/backup|var/log/*|var/run/*|var/tmp/*"
    messageresult="code"
    rsynctoweb
}
apol3codesport(){
    Rsync_server="10.181.1.4"
    Rsync_mode="HQAPPRE3CODE-SPORT"
    Rsync_bin="/usr/bin/rsync"
    Local_path="/www/hqap3sport/"
    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|.git/|.env*|.docker|docker-compose.*.yml|public/uploads/*|var/backup|var/log/*|var/run/*|var/tmp/*"
    messageresult="codesport"
    rsynctoweb
}
appre3codejump(){
    Rsync_server="10.181.1.4"
    Rsync_mode="HQAPPRE3JUMP"
    Rsync_bin="/usr/bin/rsync"
    Local_path="/www/yangmao/ap3jump/"
    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|.git/|.docker|docker-compose.*.yml|public/uploads/*|var/backup|var/log/*|var/run/*|var/tmp/*|storage/*"
    messageresult="code"
    rsynctoweb
    chown -R www.www /www/yangmao/ap3jump/public/upload/data/
}
appre3codechat(){
    Rsync_server="10.181.1.4"
    Rsync_mode="HQAPPRE3CHAT"
    Rsync_bin="/usr/bin/rsync"
    Local_path="/www/yangmao/ap3chat/"
    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|.git/|.docker|docker-compose.*.yml|public/uploads/*|var/backup|var/log/*|var/run/*|var/tmp/*|storage/*"
    messageresult="code"
    rsynctoweb
}
sporttools(){
    Rsync_server="10.181.1.4"
    Rsync_mode="HQAPPRE3sporttools"
    Rsync_bin="/usr/bin/rsync"
    Local_path="/www/hqap3-sporttools/"
    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|log|.git/|.docker|docker-compose.*.yml|public/uploads/*|var/backup|var/log/*|var/run/*|var/tmp/*|storage/*"
    messageresult="code"
    rsynctoweb
}
#apol3image(){
#    Rsync_server="10.182.1.4"
#    Rsync_mode="HQAPOL3Image"
#    Rsync_bin="/usr/bin/rsync"
#    Local_path="/www/hqap3/public/uploads/"
#    messageresult="image"
#    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak|*.old|*.cache|*.tmp|*.temp|*.txt|*.pid|*.lock|*.locks|_tmp|temp|.git/|.env*|.docker"
#    rsynctoweb
#}

#apzhaoshang(){
#    Rsync_server="10.182.1.7"
##    Rsync_mode="zhaoshang"
#    Rsync_bin="/usr/bin/rsync"
#    Local_path="/www/ap3aff/"
#    rsync_exclude="runtime/|logs/|upload/|nohup.out"
#    if [ ! -d "$Local_path" ]; then
##      mkdir -p $Local_path
#    fi
#    rsynctoweb
#}

#apol3nginxcontrol(){
#    Rsync_server="10.182.1.7"
#    Rsync_mode="HqAp3NginxControl"
#    Rsync_bin="/usr/bin/rsync"
#    Local_path="/usr/local/webserver/nginx/conf/"
#    rsync_exclude="*.gz|*.rar|*.tar|*.zip|*.bak"
#    messageresult="ip control"
#    rsynctoweb
#    reloadnginx=1
#}
#

# rsyncnginxconf(){
#     Rsync_server="119.9.90.176"
#     Rsync_mode="NginxConf_AP3"
#     Rsync_bin="/usr/bin/rsync"
#     Nginx_bin='/usr/local/webserver/nginx/sbin/nginx'
#     Local_path="/usr/local/webserver/nginx/conf/sites-enabled2/ap3/"
#     rsync_exclude=".git"
#     cleannginxfile
#     rsynctoweb
#     addincludetonginxconf
#     reloadnginx=1
# }
# addincludetonginxconf(){
#   num=`sed -n '/sites-enabled2\/ap3\/jixing\/jixing\.conf/=' /usr/local/webserver/nginx/conf/nginx.conf |tail -n1`
#     if [  -z "$num" ];then
#       nums=`sed -n '/sites-enabled/=' /usr/local/webserver/nginx/conf/nginx.conf|tail -n1`
#       if [ ! -z "$nums" ];then
#         if [ -f "/usr/local/webserver/nginx/conf/sites-enabled2/ap3/jixing/jixing.conf" ];then
#           sed -i "${nums} a\  include sites-enabled2/ap3/jixing/jixing.conf;" /usr/local/webserver/nginx/conf/nginx.conf

#           result="    Add jixing include file to nginxconf ok!"
#           resultstatus=0
#           echoinfo
#         else
#           result="    Add jixing include file to nginxconf Fail!"
#           resultstatus=1
#           echoinfo
#         fi
#       fi
#     fi
# }
rsynctoweb(){
    if [ "$rsync_exclude" ]
    then
      IFS='|'
      exclude_arr=($rsync_exclude)
      for e_arr in ${exclude_arr[@]}
        do
            echo $e_arr >>/tmp/${DATE}_excludefile.txt
        done
      result=$("$Rsync_bin" -vzrlpgotD   --exclude-from="/tmp/${DATE}_excludefile.txt"  "$Rsync_server"::"$Rsync_mode"/  "$Local_path" 2>&1|tee -a "$TMP"|grep rsync|grep  "failed\|error")
      #result=$("$Rsync_bin" -vzcrltD   --exclude-from="/tmp/${DATE}_excludefile.txt"  "$Rsync_server"::"$Rsync_mode"/  "$Local_path" 2>&1)
    else
      result=$("$Rsync_bin" -vzrlpgotD   "$Rsync_server"::"$Rsync_mode"/  "$Local_path" 2>&1|tee -a  "$TMP"|grep rsync|grep "failed\|error")
    fi

  if [ -n "$result" ]; then
    resultstatus=1
    echoinfo
    result="    Rsync $messageresult change to web failed!"
    echoinfo
    exit 1
  else
    result="    Rsync $messageresult to web ok!"
    resultstatus=0
    echoinfo
  fi
  echo "====================================" >> "$LOG"
}


nginxreload(){
    #同步成功reload nginxoweb
    if [ $resultstatus -eq 0 ];then
        format
        "$Nginx_bin" -t > /dev/null 2>&1
            if [ "$?" -eq 0 ];then
                "$Nginx_bin" -s reload
                 sleep 0.5
                 currenttime=`date "+%H:%M"`
                 lastcurrenttime=`date "+%H:%M" -d "-1 minute"`
                 reloadtime=$(ps aux|grep nginx|grep -v grep |grep -v master|awk '{ print $9 }'|grep -E  "$currenttime|$lastcurrenttime")
                if [ "$?" -eq 0 ];then
                  echo "Nginx reload ok!" >> "$LOG"
                  result="    Nginx reload ok!"
                  resultstatus=0
                  echoinfo
                else
                  echo "Nginx reload Error!" >> "$LOG"
                  resultstatus=1
                  result="    Nginx  reload Error!"
                  echoinfo
                fi

            else
                echo "Nginx reload Error!" >> "$LOG"
                resultstatus=1
                result="    Nginx  reload Error!"
                echoinfo
            fi
    else
        format
    fi
    echo "====================================" >> "$LOG"
}

# forcehttps(){
#   cd "/usr/local/webserver/nginx/conf/sites-enabled2/ap3/jixing/conf/"
#     for i in group*ssl.conf
#         do
#             num=`sed -n '/$scheme/=' $i |tail -n1`
#             endnum=$((num+2))
#             sed -i "${num},${endnum}s/#//" $i
#         done
#     result="    Set Force https Success!"
#     resultstatus=0
#     echoinfo
# }

# noforcehttps(){
#     cd "/usr/local/webserver/nginx/conf/sites-enabled2/ap3/jixing/conf/"
#     for i in group*ssl.conf
#       do
#           num=`sed -n '/$scheme/=' $i |tail -n1`
#           endnum=$((num+2))
#           sed -i "${num},${endnum}s/#//" $i
#           sed -i "${num},${endnum}s/^/#&/" $i

#       done
#     result="    Cancle set Force https Success!"
#     resultstatus=0
#     echoinfo
# }
# if [ ! -d "/usr/local/webserver/nginx/conf/sites-enabled2/ap3/" ]; then
#     mkdir  -p /usr/local/webserver/nginx/conf/sites-enabled2/ap3/
# fi
# clearnginxcache(){
#   if [ ! -d "/home/zaki/empty/" ]; then
#     mkdir -p /home/zaki/empty
#   fi
  #使用rsync 删除缓存并保持原有目录权限
#   "$Rsync_bin"  --delete -rlptD /home/zaki/empty/ /data/nginx_cache/proxy_cache_dirap3/
#    if [ "$?" -eq 0 ];then
#       echo "clear nginx  cache ok!" >> "$LOG"
#       result="    Clear Nginx  Cache Ok!"
#       resultstatus=0
#       echoinfo
#    fi
# }

tag=0
for argument in $(echo $*)
    do
      case "$argument" in
            nginxcontrol)
                tag=1
                apol3nginxcontrol
                ;;
            image)
                tag=1
                apol3image
                ;;
            staticsource)
                tag=1
                apzhaoshang
                ;;
            codejump)
                tag=1
                appre3codejump
                ;;
            codechat)
                tag=1
                appre3codechat
                ;;
            code-sport)
                tag=1
                apol3codesport
                ;;
            code)
                tag=1
                apol3code;;
            sporttools)
                tag=1
                sporttools

        esac
    done
if [ $reloadnginx -eq 1 ];then
    nginxreload
fi
if [ "$tag" -eq 0 ];then
    echo $"Usage: {code|code-sport|nginxcontrol|image|staticsource|codejump|codechat|sporttools}"
    exit 3
fi


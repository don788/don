#!/bin/bash
#auther:zaki
# version: 1.0.0
# desc: 93yule_servername_rsync.sh
# date: 2020/06/09


#######################################################

LOG="/tmp/rsync.log"
TMP="/tmp/tmp.txt"
DATE=`/bin/date +"%F_%H_%M_%S"`
Nginx_bin='/usr/local/webserver/nginx/sbin/nginx'
Rsync_bin="/usr/bin/rsync"
resultstatus=1
reloadnginx=0
echo "">$TMP




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
    result="    Rsync change to web failed!"
    echoinfo
    exit 1
  else
    result="    Rsync $content to web ok!"
    resultstatus=0
    echoinfo
  fi
  echo "====================================" >> "$LOG"
  reloadnginx=1
}

RsyncCoreServerName(){
    Rsync_server="119.9.95.234"
    Rsync_mode="NginxServerNameConf_93yule"
    Rsync_bin="/usr/bin/rsync"
    Nginx_bin='/usr/local/webserver/nginx/sbin/nginx'
    Local_path="/usr/local/webserver/nginx/conf/sites-enabled/93yule/"
    #rsync_exclude="accounts/|archive/|csr/|renewal/|renewal-hooks"
    rsync_exclude=".git"
    rsynctoweb
}
nginxreload(){
    #同步成功reload nginxoweb
    if [ $resultstatus -eq 0 ];then
        format
        "$Nginx_bin" -t > /dev/null 2>&1
            if [ "$?" -eq 0 ];then
                "$Nginx_bin" -s reload
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
        format
    fi
    echo "====================================" >> "$LOG"
}

if [ ! -d "/usr/local/webserver/nginx/conf/sites-enabled/93yule" ]; then
    mkdir  -p /usr/local/webserver/nginx/conf/sites-enabled/93yule
fi

tag=0
for argument in $(echo $*)
    do 
      case "$argument" in
            coreservername)
                tag=1
                RsyncCoreServerName
        esac
    done
 if [ $reloadnginx -eq 1 ];then
     nginxreload
 fi
if [ "$tag" -eq 0 ];then
    echo $"Usage: {coreservername}"
    exit 3
fi


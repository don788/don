#!/bin/bash
#count nginx request ip and users and so on
#by sw 2019-06
###########################################

SUCCESS_LOG=/usr/local/nginx/logs/access.log
FAILED_LOG=/usr/local/nginx/logs/error.log

while true
do
	read -p "请输入查询年份(2019及以后):" YEAR
	if [ $YEAR -lt 2019 ];then
	    echo "请输入2019及以后的年份才有日志"
	else
	    break
	fi
done

while true
do
	read -p "请输入查询月份(1~12):" MOUTH
	if [ $MOUTH -gt 12 -o $MOUTH -le 0 ];then
	echo "请输入正确的月份，必须在1~12之间！"
	else
		case $MOUTH in
		1) MOUTH_N=Jan ;;
		2) MOUTH_N=Feb ;; 
		3) MOUTH_N=Mar ;; 
		4) MOUTH_N=Apr ;; 
		5) MOUTH_N=May ;; 
		6) MOUTH_N=Jun ;; 
		7) MOUTH_N=Jul ;; 
		8) MOUTH_N=Aug ;; 
		9) MOUTH_N=Sept ;; 
		10) MOUTH_N=Oct ;; 
		11) MOUTH_N=Nov ;; 
		12) MOUTH_N=Dec ;; 
		esac
		break
fi
done

while true
do
	read -p "请输入查询日期(1-31):" DAY
	if [ $DAY -gt 31 -o $DAY -lt 0 ];then
		echo "请输入正确的日期，在1-31号之间！"
	else
		break
	fi
done

if [ ! -f ${SUCCESS_LOG} ];then
	echo "请确认日志是否存在或者路径是否错误！"
	exit 1
fi

count_ip() {
#统计访问ip数量,取访问量前10位
echo -e "\033[31m访问网站次数最多的10个ip地址:\033[0m"
cat ${SUCCESS_LOG}|grep ${DAY}/${MOUTH_N}/${YEAR} |awk '{print $1}'|sort -r|uniq -c |sort -rn|head -n 10

#统计访问网站ip总个数
read -p "请输入开始时间：" START_TIME
read -p "请输入结束时间：" END_TIME	

IP_COUNT=`grep ${DAY}/${MOUTH_N}/${YEAR} ${SUCCESS_LOG}|awk 'BEGIN{RS="2019:"}$1>"'${START_TIME}'"&&$1<"'${END_TIME}'"{print $(NF-3)}' |sort -r|uniq|wc -l`
echo "从${START_TIME}到${END_TIME},总IP个数是：${IP_COUNT}"

echo -e "\033[32m本日访问网站的总ip个数:\033[0m"
grep ${DAY}/${MOUTH_N}/${YEAR} ${SUCCESS_LOG}|awk '{print $1}'|sort -r|uniq |wc -l
}

request_fail() {
#统计访问失败次数
FAIL_COUNT=`grep ${DAY}/${MOUTH_N}/${YEAR} ${SUCCESS_LOG}|awk '{print $9}'|grep -v 200|wc -l`
SUCES_COUNT=`grep ${DAY}/${MOUTH_N}/${YEAR} ${SUCCESS_LOG}|awk '{print $9}'|grep 200|wc -l`
COUNT=$((${FAIL_COUNT}+${SUCES_COUNT}))
#PERCENT=$(printf "%.2f%%" $((${FAIL_COUNT}*100/${COUNT})))
PERCENT=`awk 'BEGIN {printf "%.2f%%\n",('${FAIL_COUNT}'/'${COUNT}')*100}'`
echo -e "\033[33m本日访问网站的失败次数: \033[0m"
echo  "${FAIL_COUNT}"
echo -e "\033[33m失败次数占总访问量的百分比: \033[0m"
echo  "${PERCENT}"
}

request_flow() {
#统计访问流量
echo -e "\033[34m本日访问网站总流量:\033[0m"
FLOW_COUNT=`grep ${DAY}/${MOUTH_N}/${YEAR} ${SUCCESS_LOG}|awk '{print $10}'|grep -v "-"|awk '{a+=$1}END{print a}'`
if [ ${FLOW_COUNT} -ge 1024 -a ${FLOW_COUNT} -lt 1048576 ];then
	K=`awk 'BEGIN {printf "%.2f\n",('${FLOW_COUNT}'/'1024')}'`
	echo "${K}K"
elif [ ${FLOW_COUNT} -ge 1048576 -a ${FLOW_COUNT} -lt 1073741824 ];then
	M=`awk 'BEGIN {printf "%.2f\n",('${FLOW_COUNT}'/'1048576')}'`
	echo "${M}M"
elif [ ${FLOW_COUNT} -ge 1073741824 ];then
	G=`awk 'BEGIN {printf "%.2f\n",('${FLOW_COUNT}'/'1073741824')}'`
	echo "${G}G"
fi
}

count_ip
request_fail
request_flow


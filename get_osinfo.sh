#!/bin/sh
# free, hostname, grep, cut, awk, uname, sar, ps, netstat
HOSTNAME=`hostname -s`
#memory
MEMORY=`free | grep Mem | awk '{print $2}'`

#cpu info
CPUS=`cat /proc/cpuinfo | grep processor | wc -l | awk '{print $1}'`
CPU_MHZ=`cat /proc/cpuinfo | grep MHz | tail -n1 | awk '{print $4}'`
CPU_TYPE=`cat /proc/cpuinfo | grep vendor_id | tail -n 1 | awk '{print $3}'`
CPU_TYPE2=`uname -m`

OS_NAME=`uname -s`
OS_KERNEL=`uname -r`
UPTIME=`uptime`
PROC_COUNT=`ps -ef | wc -l`

body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}

#print it out
echo "��Ҫ��Ϣ" `date +'%Y-%m-%d %H:%S'`
echo "----------------------------------"
echo "��������            : $HOSTNAME"
echo "�ڴ��С          : $MEMORY"
echo "CPU����           : $CPUS"
echo "CPU����           : $CPU_TYPE $CPU_TYPE2 $CPU_MHZ MHz"
echo "����ϵͳ          : $OS_NAME"
echo "�ں˰汾          : $OS_KERNEL"
echo "��������          : $PROC_COUNT"
echo "����ʱ�估����    : $UPTIME"
echo
echo "�ڴ�ʹ�����"
echo "----------------------------------"
free -m
echo 
echo "����ʹ�����"
echo "----------------------------------"
df -h
echo 
echo "�����������"
echo "----------------------------------"
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
echo 
echo "����������"
echo "----------------------------------"
netstat -tnpl | awk 'NR>2 {printf "%-20s %-15s \n",$4,$7}'
echo 
echo "�ڴ���Դռ��Top 10"
echo "----------------------------------"
ps -eo rss,pmem,pcpu,vsize,args |body sort -k 1 -r -n | head -n 10
echo 
echo "CPU��Դռ��Top 10"
echo "----------------------------------"
ps -eo rss,pmem,pcpu,vsize,args |body sort -k 3 -r -n | head -n 10
echo 
echo "���1Сʱ��������ͳ��"
echo "----------------------------------"
sar -n DEV -s `date -d "1 hour ago" +%H:%M:%S`
echo 
echo "���1Сʱcpuʹ��ͳ��"
echo "----------------------------------"
sar -u -s `date -d "1 hour ago" +%H:%M:%S`
echo 
echo "���1Сʱ����IOͳ��"
echo "----------------------------------"
sar -b -s `date -d "1 hour ago" +%H:%M:%S`
echo 
echo "���1Сʱ���̶��к�ƽ������ͳ��"
echo "----------------------------------"
sar -q -s `date -d "1 hour ago" +%H:%M:%S`
echo 
echo "���1Сʱ�ڴ�ͽ����ռ��ͳ��ͳ��"
echo "----------------------------------"
sar -r -s `date -d "1 hour ago" +%H:%M:%S`
echo

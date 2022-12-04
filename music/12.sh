fifofile=/tmp/$$
mkfifo $fifofile
exec 1000<>$fifofile


thread=10
for ((i=0;i<$thread;i++))
do
    echo >&1000
done

cat /tmp/databases.list | while read line
do
    read -u1000
    {
        echo `echo $line`
        echo >&1000
    } &
done

wait
exec 1000>&-
rm -f $fifofile

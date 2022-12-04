mkfifo 123.fifo
mkfifo 123.fifo
exec 1000<>123.fifo
echo >&1000

for i in `seq 1 10`
do
       read -u1000
     {	
        date +%T
	echo $i
	sleep 1
	  echo >&1000
}&
done
wait
echo >&1000
rm -f 123.fifo

	

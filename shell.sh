												shell语法

1.特殊变量
$0 脚本自身名字
$? 判断执行是否成功 0为成功 非0为失败
$# 位置参数总数
$* 所以位置参数被看做一个字符串
$@ 每个位置参数被看做独立字符串
$$ 显示当前的pid
$! 上一条执行后台进程的PID

2.shell字符串处理${} 
1.1 获取字符串长度
A='zhangcaiwang'
echo $A
取长度: echo ${#A}
1.2 字符串切片
A='zhangcaiwang'
echo ${A:0:5}   #0:5 取值空间
echo ${A:6:2}    #取6个字符串后两个
echo ${A:(-1)}  #截取最后一个字符串
echo ${A:(-3):2} #截取后三个字符串的两个字符

1.3 替换字符串 格式${parameter/pattern/string}
A='zhang cai wang'
echo ${A/cai/wang}
全部替换 echo ${A//cai/wang}
正则匹配字符串
var=123abc
echo ${var//[^0-9]/}
echo ${var//[0-9]/}

1.4字符串截取  #去掉左边 最短匹配模式 ##最长匹配模式   %去掉右边 最短匹配模式 %%最长匹配模式
URL="http://www.baidu.com/user/a.html"
以//为分隔符截取右边字符串：
echo ${URL#*//}  #以//为分隔符 获取最右边字符串
www.baidu.com/user/a.html

以/为分隔符截取右边字符串：
echo ${URL##*/}
a.html

以//为分隔符截取左边字符串：
echo ${URL%%//*}
http:

以/为分隔符截取左边字符串：
echo ${URL%/*}
http://www.baidu.com/user

1.5 字体颜色
echo -e "\033[31m Hello world! \033[0m"  红色
30：黑
31：红
32：绿
33：黄
34：蓝色
35：紫色
36：深绿
37：白色
40：黑
41：深红
42：绿
43：黄色
44：蓝色
45：紫色
46：深绿
47：白色

3.shell条件表达式 
[ expression ]  示例  [ 1 -eq 1 ]
[[ expression ]] 示例  [[ 1 -eq 1 ]]
test expression   示例 test 1 -eq 1 等同于[]

3.1 整数比较
-eq 等于  示例  [ 1 -eq 1 ] 为true
-ne 不等于 示例  [ 1 -ne 1 ] 为false
-gt 大于   示例  [ 2 -gt 1 ] 为true
-lt 小于 示例 [ 2 -lt 1 ] 为false
-ge 大于等于  示例  [ 2 -ge 1 ] 为true
-le  小于等于 示例  [ 2 -le 1 ] false

3.2 字符串比较
== 等于  示例  [ "a" == "a" ] 为true
!= 不等于  示例  [ "a" != "a" ] 为false
-n 字符串长度不等于0为真  示例 A=1 B=""  [ -n "$A" ] 为true [ -n "$B" ] 为false
-z 字符串长度等于0为真 示例  A=1 B="" [ -z "$A" ] 为false  [ -z "$B" ] 为true
str 字符串存在为真     示例  A=1 B="" [ $A ] 为true  [ $B ] 为false
************使用-z 或-n 判断字符串长度时，变量要加双引号****
 A="" B=1
[ -z "$A" ] && echo yes || echo no   #如果$A 值为空 输出 yes  否则输入no
[ -n "$B" ] && echo yes || echo no    #如果$B 有值 输出yes  否则输入no

使用双中括号就不用引号
[[ -z $A ]] && echo yes || echo no  #空为真 不空为假
[[ -n $B ]] && echo yes || echo no   #不空为真 非空位为假 

3.3 文件测试
-e 文件或目录存在   [ -e path ] path 存在为true
-f 文件存在为真   [ -f file_path ] 文件存在为true
-d 目录存在为真    [ -d dir_path ] 目录存在为true
-r 有读权限为真    [ -r file_path ] file_path 有读权限为 true 
-w  有写权限为真   [ -w file_path ] file_path 有写权限为 true 
-x  有执行权限为真  [ -x file_path ] file_path 有执行权限为 true 

3.4 布尔运算符
！非关系 条件结果取反  示例 [ ! 1 -eq 2 ]为 true 
-a 和关系，在[]表达式中使用  [ 1 -eq 1 -a 2 -eq 2 ]为 true
-o 或关系，在[]表达式中使用   [ 1 -eq 1 -o 2 -eq 1 ]为 

3.5 逻辑判断符
&&  逻辑和，在[[]]和(())表达式中或判断表达式是否为真时使用
示例
[[ 1 -eq 1 && 2 -eq 2 ]]为 true 
(( 1 == 1 && 2 == 2 ))为 true
[ 1 -eq 1 ] && echo yes 如果&&前面表达式为 true 则执行后面的

|| 逻辑或，在[[]]和(())表达式中或判断表达式是否为真时使用
[[ 1 -eq 1 || 2 -eq 1 ]]为 true
(( 1 == 1 || 2 == 2 ))为 true
[ 1 -eq 2 ] || echo yes 如果||前面表达式为 false 则执行后面的

3.6 数学运算 + 加 - 减 *乘 /除 % 取余
运算表达式 $(())  示例 $((1+1))           $[]   示例   $[1+1]
复杂运算 let  赋值并运算，支持++、 --           示例   let VAR=(1+2)*3 ; echo $VAR 
expr 乘法*需要加反斜杠转义\*    示例 expr 1 \* 2 运算符两边必须有空格
bc 计算器   示例     echo 'scale=2;10/3' |bc   用 scale 保留两位小数点


4.shell括号总结
( ) 用途 1：在运算中，先计算小括号里面的内容     用途 2：数组   用途 3：匹配分组
(( )) 用途 1：表达式，不支持-eq 这类的运算符。不支持-a 和-o，支持<=、 >=、 <、 >这类比较符和&&、 ||  
用途 2： C 语言风格的 for(())表达式
$( )  执行 Shell 命令，与反撇号等效
$(( )) 用途 1：简单算数运算  用途 2：支持三目运算符 $(( 表达式?数字:数字 ))
[ ]  条件表达式，里面不支持逻辑判断符
[[ ]]  条件表达式，里面不支持-a 和-o，不支持<=和>=比较符，支持-eq、 <、 >这类比较符。支持=~模式匹配，也可以不用双引号也不会影响原意，比[]更加通用
$[ ]  简单算数运算
{ } 对逗号（,）和点点（...）起作用，比如 touch {1,2}创建 1 和 2 文件， touch{1..3}创建 1、 2 和 3 文件
${ }  用途 1：引用变量 用途 2：字符串处理


5.shell流程控制
5.1 if 语句
单分支
if 条件表达式; then
	命令
fi

示例
#!/bin/bash
A=10 
if [ $A -gt 5 ];then
	echo yes
fi

双分支
if 条件表达式; then
	命令
else
	命令
fi

示例1：
A=10
if [ $A -lt 5 ];then
	 echo yes
else
	echo no
fi

示例2：
判断nginx进程是否在运行
#!/bin/bash
NAME=nginx
NUM=$(ps -ef | grep nginx | grep -vc grep)
if [ $NUM -gt 1 ];then
	echo "$NAME running"
else
	echo "$NAME no running"
fi

多分支
if 条件表达式; then
	命令
elif 条件表达式; then
	命令
else
	命令
fi

示例 1：
#!/bin/bash
N=$1
if [ $N -eq 3 ]; then
	echo "eq 3"
elif [ $N -eq 5 ]; then
	echo "eq 5"
elif [ $N -eq 8 ]; then
	echo "eq 8"
else
	echo "no"
fi


示例2:
#!/bin/bash
if [ -e /etc/redhat-release ]; then
	yum install wget -y
elif [ $(cat /etc/issue |cut -d' ' -f1) == "Ubuntu" ]; then
	apt-get install wget -y
else
	Operating system does not support.
exit
fi


5.2 for 循环
for 变量名 in 取值列表; do
		命令
done

示例1：
#!/bin/bash
for i in {1..3}; do
	echo $i
done

示例2：
#!/bin/bash
for i in "$@"; { # $@是将位置参数作为单个来处理
	echo $i
}

默认for 循环的取值列表是以空白符分隔系统变量里的$IFS,如果想指定分隔符，可以重新赋值$IFS 变量：
#!/bin/bash
OLD_IFS=$IFS
IFS=":"
for i in $(head -1 /etc/passwd); do
	echo $i
done
IFS=$OLD_IFS # 恢复默认值


for 循环c语言写法：
for (( expr1 ; expr2 ; expr3 )) ; do list ; done

示例3:
#!/bin/bash
for ((i=1;i<=5;i++)); do # 也可以 i--
	echo $i
done

示例4:检查多个域名是否可以访问
#!/bin/bash
URL="www.baidu.com www.sina.com www.jd.com"
for url in $URL; do
HTTP_CODE=$(curl -o /dev/null -s -w %{http_code} http://$url)
if [ $HTTP_CODE -eq 200 -o $HTTP_CODE -eq 301 ]; then
	echo "$url OK."
else
	echo "$url NO!"
fi
done

5.3 while 语句
while 条件表达式; do
	命令
done

示例1：
#!/bin/bash
N=0
while [ $N -lt 5 ]; dolet N++
echo $N
done

示例2: 逐行读文件

#!/bin/bash
cat ./a.txt | while read LINE; do
echo $LINE
done
或
#!/bin/bash
while read LINE; do
	echo $LINE
done < ./a.txt
或
#!/bin/bash
exec < ./a.txt # 读取文件作为标准输出
while read LINE; do
	echo $LINE
done



break 是终止循环
#!/bin/bash
N=0
while true; do
let N++
if [ $N -eq 5 ]; then
	break
fi
	echo $N
done

continue 是跳出当前循环
#!/bin/bash
N=0
while [ $N -lt 5 ]; do
	let N++
if [ $N -eq 3 ]; then
	continue
fi
	echo $N
done


5.4 case语句
case 模式名 in
模式 1)
	命令
;;
模式 2)
	命令
;;
*)
	不符合以上模式执行的命令
esac

示例3：
#!/bin/bash
case $1 in
start)
	echo "start."
;;
stop)
	echo "stop."
;;
restart)
	echo "restart."
;;
*)
echo "Usage: $0 {start|stop|restart}"
esac

示例4：
#!/bin/bash
case $1 in
[0-9])
	echo "match number."
;;
[a-z])
	echo "match letter."
;;
'-h'|'--help')
	echo "help"
;;
*)
	echo "Input error!"
	exit
esac

5.5 select 语句类似for循环语句
select 变量 in 选项 1 选项 2; do
	break
done

#!/bin/bash
PS3="Select a number: "
while true; do
select mysql_version in 5.1 5.6 quit; do
		case $mysql_version in
			5.1)
				echo "mysql 5.1"
				break
				;;
			5.6)
				echo "mysql 5.6"
				break
				;;
			quit)
				exit
				;;
			*)
				echo "Input error, Please enter again!"
				break
		esac
	done
done

6.shel函数与数组
格式：
func(){
	command
}

示例1：函数返回值
#!/bin/bash
func() {
VAR=$((1+1))
return $VAR
echo "This is a function."
}
func
echo $?

示例2：通过 Shell 位置参数给函数传参
#!/bin/bash
func() {
echo "Hello $1"
}
func world


7.数组 array=(元素 1 元素 2 元素 3 ...)
定义方法 1：初始化数组
获取所有元素
array=a b c
echo ${array[*]}  # *和@ 都是代表所有元素
array=(a b c)


定义方法 2：新建数组并添加元素
array[下标]=元素
获取元素下标：
a=(1 2 3)
echo ${!a[@]}

获取数组长度：
a=(1 2 3 4 5 6 7 8)
echo ${#array[*]}

获取第一个元素：
echo ${array[0]}

获取第二个元素：
echo ${array[1]}

获取第三个元素：
echo ${array[2]}

添加元素:
array=(1 2 3)
array[3]=d
echo ${array[*]}
a b c d

添加多个元素：
array+=(e f g)
echo ${array[*]}
a b c d e f g

删除第一个元素：
unset array[0] # 删除会保留元素下标
echo ${array[*]}
b c d e f g

删除数组：
unset array

示例1：
#!/bin/bash
for i in $(seq 1 10); do
	array[a]=$i
	let a++
done
echo ${array[*]}

示例2：
#/bin/bash
IP=(192.168.1.1 192.168.1.2 192.168.1.3)
for ((i=0;i<${#IP[*]};i++)); do
	echo ${IP[$i]}
done


7.shell 正则表达式
基础正则表达式： BRE（basic regular express）
扩展正则表达式： ERE（extend regular express），扩展的表达式有+、 ?、 |和()
. 匹配除换行符(\n)之外的任意单个字符  	示例  匹配 123： echo -e "123\n456" |grep '1.3'
^ 匹配前面字符串开头  示例  匹配以 abc 开头的行： echo -e "abc\nxyz" |grep ^abc
$ 匹配前面字符串结尾  示例  匹配以 xyz 结尾的行：  echo -e "abc\nxyz" |grep xyz$
* 匹配前面一个字符零个或多个  匹配x,xo和xoo:   echo -e "x\nxo\nxoo\no\noo" | grep "xo*"  x 是必须的，批量了0零个或多个
+ 匹配前面字符1个或多个     匹配 abc 和 abcc：echo -e "abc\nabcc\nadd" |grep -E 'ab+'  			
						    匹配单个数字： echo "113" |grep -o '[0-9]'
							连续匹配多个数字： echo "113" |grep -E -o '[0-9]+
							
				
? 匹配前面字符0个或 1个     匹配 ab或abc: echo -e "ac\nabc\nadd" | grep -E 'a?c'
[] 匹配中括号之中的任意一个字符  匹配a或c:   echo -e "a\nb\nc" | grep '[ac]'
[.-.] 匹配中括号范围内的任意一个字符  匹配所有字母: echo -e "a\nb\nc" |grep '[a-z]'
[^] 匹配[^字符] 之外的任意一个字符   匹配a或b: echo -e "a\nb\nc" | grep '[^c-z]'
^[^] 匹配不是中括号内任意一个字符开头的行  匹配不是#开头的行：grep '^[^#]' /etc/http/conf/httpd.conf
{n}或{n,} 匹配花括号前面字符最少n个字符    匹配abc字符串(至少三个字符以上字符串)  echo -e "a\nabc\nc" |grep -E '[a-z]{3}'
{n,m} 匹配花括号前面字符至少n个字符 最多m个字符  匹配12和123  echo -e "1\n12\n123\n1234" | grep -E -w -o '[0-9]{2,3}'
\< 边界符 匹配字符串开始  匹配开始是123和1234  echo -e "1\n12\n123\n1234" |grep '\<123'
\> 边界符 匹配字符串结束  匹配结束是1234 echo -e "1\n12\n123\n1234" | grep '4\>'
() 小括号里面作为一个组合    匹配123a字符串   echo "123abc" |grep -E -o '([o-9a-z]){4}'
| 匹配竖杠两边的任意一个  匹配12和123  echo -e "1\n12\n123\n1234" | grep -E '12\>|123\>'
\ 转义符     			  匹配 1\.2 


8.shell文本处理三剑客
grep 
-E    扩展正则表达式
-P    perl正则表达式
-e	  使用模式匹配  可指定多个模式匹配
-f     从文件的每一行获取匹配模式
-i 	   忽略大小写
-w     模式匹配整个单词
-x     模式匹配整行
-v 		打印不匹配的行
-m      输出匹配的结果num数
-n      打印行号
-H        打印每个匹配的文件名
-h			不输出文件名
-o			只打印匹配的内容
-q			不输出正常信息
-s				不输出错误信息
-r				递归目录
-c				只打印每个文件匹配的行数
-B                打印匹配的前几行
-A					打印匹配的后几行
-C					打印匹配的前后几行
--color 			匹配的字体颜色

1)输出b文件中在a文件相同的行
grep -f a b

2)输出b文件中在a文件不同的行
grep -v -f a b

3)匹配多个模式
echo "a bc de" | xargs -n1 | grep -e 'a' -e 'bc'  #xargs -n1 打印竖着排列

4)去除空格http.conf文件空行或开头#号的行
grep -E -v "^$|^#" /etc/http/conf/httpd.conf

5)匹配开头不分大小写的单词
echo "A a b c" | xargs -n1 | grep '[Aa]'

6)只显示匹配的字符串
echo "this is a test" |grep -o 'is'

7)输出匹配的前五个结果
seq 1 20 | grep -m 5 -E '[0-9]{2}'

8)统计匹配多少行
seq 1 20 |grep -c -E '[0-9]{2}'

9)匹配b字符开头的行
echo "a bc de" | xargs -n1 |grep '^b'

10)匹配de字符结尾的行并输出匹配的行
echo "a ab abc abcd abcde" | xargs -n1 | grep -n 'de$'

11)递归搜索/etc/目录下包含ip的conf后缀文件
grep -r '192.168.1.1' /etc  --include *.

12)排除搜索bak后缀的文件
grep -r '192.168.1.1' /opt  --exclude *.bak

13)排除来自file中的文件
grep -r '192.168.1.1' /opt --exclude-from file

14)匹配41或42的数字
seq 41 45 | grep -E '4[12]'

15)匹配至少2个字符
seq 13 | grep -E '[0-9]{2}'

16)匹配至少2个字符的单词 最多3个字符的单词
echo "a ab abc abcd abcde" |xargs -n1 |grep -E -w -o '[a-z]{2,3}'

17)匹配所有ip
ifconfig |grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"

18)打印5后3行
seq 1 10 | grep 5 -A 3

19)打印匹配结果及前3行
seq 1 10 | grep 5 -B 3

20)打印匹配结果及前后3行
seq 1 10 | grep 5 -C 3

21) 不显示输出
grep -s 'a' abc   不显示错误输出
grep -q 'a' a.txt 不显示正常输出


sed 
-n 不打印模式
-e 执行脚本 表达式来处理
-f 执行动作从文件读取执行
-i  修改原文件
-r 使用扩展正则

s/regexp/replacement/  替换字符串
p					打印当前模式空间
P  					打印模式空间的第一行
d					  删除模式空间  开始下个一个循环
D						删除模式空间的第一行 开始下一个循环
=						打印当前行号
a \text			  		当前行追加文本
i \text					当前行上面插入文本
c \text					 所选行替新文本
q						 退出sed脚本
r						 追加文本来自文件
:label			         label为b 和t 命令
b label 				分支到脚本中带有标签的位置
t label					如果s/// 是一个成功的替换 才跳转到标签
h H						 复制/追加模式空间到保持空间
g G						  复制/追加保持空间到模式空间
x						   交换模式空间和保持空间
l			                 打印模式空间的行  并显示控制字符$
n N						   读取/追加下一行输入到模式空间
w filename			      写入当前模式空间到文件
！						    取反 否定
&							  引用已匹配字符串
first^step				   步长 每step行 从first开始
$								匹配最后一行
/regexp/						   正则表达式匹配行
number						    只匹配指定行
addr1 addr2				     开始匹配addr1 行开始	直接addr2 行结束
addr1  ~N					 从addr1行开始    到N行结束


借助文本tail /etc/services演示
3gpp-cbsp       48049/tcp               # 3GPP Cell Broadcast Service Protocol
isnetserv       48128/tcp               # Image Systems Network Services
isnetserv       48128/udp               # Image Systems Network Services
blp5            48129/tcp               # Bloomberg locator
blp5            48129/udp               # Bloomberg locator
com-bardac-dw   48556/tcp               # com-bardac-dw
com-bardac-dw   48556/udp               # com-bardac-dw
iqobject        48619/tcp               # iqobject
iqobject        48619/udp               # iqobject
matahari        49000/tcp               # Matahari Broker



匹配打印(p)
1)打印匹配blp5开头的行
tail /etc/services | sed -n '/^blp5/p'

2)打印第一行
tail /etc/services | sed -n '1p'

3)打印第一行至第三行
tail /etc/services | sed -n '1,3p'

4)打印奇数行
seq 10 | sed -n '1~2p'

5)打印匹配行及后一行
tail /etc/services | sed -n '/blp5/,+1p'

6)打印最后一行
tail /etc/services | sed -n '$p'

7)不打印最后一行
tail /etc/services | sed -n '$!p'

8)匹配范围
tail /etc/services | sed -n '/^blp5/,/^com/p'

9)匹配开头行到最后一行:
tail /etc/services | sed -n '/blp5/,$p'

10)引用变量取行
a=1
tail /etc/services | sed -n "$a,3p"

11)匹配删除
tail /etc/services | sed '/blp5/d'

12)删除第一行
tail /etc/services |sed '1d'

13)删除1和2行
tail /etc/services | sed '1~2d'

14)删除1至3行
tail /etc/services |sed '1,3d'

15)替换字符串  全局替换加g s'/blp5/test/g'
tail /etc/services |sed 's/blp5/test/'

16)替换开头是blp5的字符串并打印
tail /etc/services | sed -n 's/blp5/test/p'

17)使用&命令引用匹配内容并替换
tail /etc/services |sed 's/48049/&.0/'

18) ip加引号
echo '10.10.10.1 10.10.10.2 10.10.10.3' |sed -r 's/[^ ]+/"&"/g

19)对1-4行的blp5进行替换
tail /etc/services | sed '1,4s/blp5/test/'

20)对匹配行进行替换
tail /etc/services | sed '/48129\/tcp/s/blp5/test/'

21)二次匹配替换
tail /etc/services | sed 's/blp5/test/;s/3g/4g/'

22)分组使用，在每个字符串后面添加 123
tail /etc/services |sed -r 's/(.*) (.*)(#.*)/\1\2test \3/'
#第一列是第一个小括号匹配，第二列第二个小括号匹配， 第三列一样。 将不变的字符串匹配分组，
#通过\数字按分组顺序反向引用

23)将协议与端口号位置调换
tail /etc/services |sed -r 's/(.*)(\<[0-9]+\>)\/(tcp|udp)(.*)/\1\3\/\2\4/'

24)替换 x 字符为大写：
echo "abc cde xyz" |sed -r 's/(.*)x/\1X/'

25)456 与 cde 调换：
echo "abc:cde;123:456" |sed -r 's/([^:]+)(;.*:)([^:]+$)/\3\2\1/'

26)注释匹配行后的多少行
seq 10 |sed '/5/,+3s/^/#/'

27)注释指定多行
seq 5 |sed -r '/^3|^4/s/^/#/' 

28)去除开头和结尾空格或制表符
echo " 1 2 3 " |sed 's/^[ \t]*//;s/[ \t]*$//'

29)多重编辑-e
tail /etc/services |sed -e '1,2d' -e 's/blp5/test/'

30)在 blp5 上一行添加 test
tail /etc/services |sed '/blp5/i \test'

31)在 blp5 下一行添加 test
tail /etc/services |sed '/blp5/a \test'

32)读取文件并追加到匹配行后（r）
cat a.txt
123
456
tail /etc/services |sed '/blp5/r a.txt'

33)将匹配行写到文件（w）
tail /etc/services |sed '/blp5/w b.txt'

34)获取总行数
seq 10 |sed -n '$='

35)每三个数字加个一个逗号
echo "123456789" |sed -r 's/([0-9]+)([0-9]+{3})/\1,\2/'

awk
-f 从文件中读取awk程序源文件
-F  指定fs为输入字段分隔符
-v  变量赋值
--posix 兼容postix正则表达式
--dump-variables  把awk命令是的全局变量写入文件 默认文件是awkvars.out
--profile  格式化awk语句到文件 默认是awkprof.out
BEGINP{}	 给程序赋予初始状态 先执行的工作
END{}         程序结束之后执行的一些扫尾工作
/regular expression/   为每个输入记录匹配正则表达式
parttern && pattern   逻辑and 满足两个模式
parttern || parttern 逻辑or 满足其中一个模式
! parttern 				逻辑not 不满足模式
parttern1 parttern2     范围模式 匹配所有模式1的记录 直到匹配到模式2
FS 						输入字段分隔符 默认是空格或制表符
OFS						 输出字段分隔符	默认是空格
RS						 输入记录分隔符	  默认是换行符\n
NF							统计当前记录中字段个数
NR							统计记录编号，每处理一行记录，编号就会+1
ARGV						命令行参数数组序列数组，下标从 0 开始， ARGV[0]是 awk
ENVIRON						当前系统的环境变量
FILENAME					输出当前处理的文件名
(...)						  分组
$							  字段引用
++ --				 		  递增 递减
+ - !							加 减 逻辑否
* / %   						乘 	除 取余
|| &						   管道	  
in				                数组成员
&& || 							逻辑and  逻辑or
= += -= *= /= %= ^= 		    变量赋值运算符
 
1.从文件读取 awk 程序处理文件
#cat <<EOF >test.awk
'{print $2}'

tail -n3 /etc/services | awk -f test.awk

2.指定分隔符，打印指定字段
tail -n3 /etc/services |awk '{print $2}'

3.指定冒号为分隔符打印第一字段：
awk -F ':' '{print $1}' /etc/passwd

4.多个分隔符，作为同一个分隔符处理
tail -n3 /etc/services |awk -F'[/#]' '{print $3}'

5.变量赋值
a=123
awk -v a=123 'BEGIN{print a}'

6.打印页眉
tail /etc/services |awk 'BEGIN{print "Service\t\tPort\t\t\tDescription\n==="}{print $0}'

7.打印页尾
tail /etc/services |awk '{print $0}END{print "======\t\t========"}'

8./re/正则匹配
匹配包含 tcp 的行:
tail /etc/services |awk '/tcp/{print $0}'

9.匹配开头是 blp5 的行：
tail /etc/services |awk '/^blp5/{print $0}'

10.匹配第一个字段是 8 个字符的行：
tail /etc/services |awk '/^[a-z0-9]{8} /{print $0}'


11.匹配记录中包含 blp5 和 tcp 的行：逻辑和 &&
tail /etc/services |awk '/blp5/ && /tcp/{print $0}'

12.匹配记录中包含 blp5 或 tcp 的行：逻辑或
tail /etc/services |awk '/blp5/ || /tcp/{print $0}'

13.不匹配开头是#和空行：
awk '! /^#/ && ! /^$/{print $0}' /etc/httpd/conf/httpd.conf

14.匹配范围
tail /etc/services |awk '/^blp5/,/^com/'

15.在程序开始前重新赋值 FS 变量，改变默认分隔符为冒号，与-F 一样。
 awk 'BEGIN{FS=":"}{print $1,$2}' /etc/passwd |head -n5
 
16.OFS 默认以空格分隔，反向引用多个字段分隔的也是空格，如果想指定输出分隔符这样：
awk 'BEGIN{FS=":";OFS=":"}{print $1,$2}' /etc/passwd |head -n5

17 字符串拼接
awk 'BEGIN{FS=":"}{print $1"#"$2}' /etc/passwd |head -n5

18.RS 默认是\n 分隔每行，如果想指定以某个字符作为分隔符来处理记录
echo "www.baidu.com/user/test.html" |awk 'BEGIN{RS="/"}{print $0}'

19.替换某个字符：
tail -n2 /etc/services |awk 'BEGIN{RS="/";ORS="#"}{print $0}'

20.NF是字段的个数
echo "a b c d e f" |awk '{print NF}'

21.打印最后一个字段：
echo "a b c d e f" |awk '{print $NF}'

22.打印倒数第二个字段：
echo "a b c d e f" |awk '{print $(NF-1)}'

23.排除最后两个字段
echo "a b c d e f" |awk '{$NF="";$(NF-1)="";print $0}'

24.排除第一个字段：
echo "a b c d e f" |awk '{$1="";print $0}'

25.打印行数
tail -n5 /etc/services |awk '{print NR,$0}'

26.打印总行数：
tail -n5 /etc/services |awk 'END{print NR}'

27.打印第三行:
tail -n5 /etc/services |awk 'NR==3'

28.打印第三行第二个字段：
tail -n5 /etc/services |awk 'NR==3{print $2}'

29.打印前三行和行号：
tail -n5 /etc/services |awk 'NR<=3{print NR,$0

30.ENVIRON 调用系统变量
export a
awk 'BEGIN{print ENVIRON["a"]}'

31.打印输出
awk 'BEGIN{n=0;if(n)print "true";else print "false"}'

32.截取整数
echo "123abc abc123 123abc123" |xargs -n1 | awk '{print +$0}'

33.打印奇数行
seq 6 |awk 'i=!i'

34.打印偶数行
seq 6 |awk '!(i=!i)'

35.不匹配某行
tail /etc/services |awk '!/blp5/{print $0}'

36.从小到大排序
seq 5 |shuf |awk '{print $0|"sort"}'

37.正则表达式匹配
seq 5 |awk '$0~3{print $0}'
seq 5 |awk '$0~/[34]/{print $0}'
seq 5 |awk '$0!~3{print $0}'

38.判断数组成员
awk 'BEGIN{a["a"]=123}END{if("a" in a)print "yes"}' </dev/null

39.求和
seq 5 |awk '{sum+=1}END{print sum}'

40.匹配数字字母的
 echo "123abc#456cde 789aaa#aaabbb " |xargs -n1 |awk -F# '{if($2~/[0-9]/)print $2}'

41.双分支：
seq 5 |awk '{if($0==3)print $0;else print "no"}'

42.多分支：
awk '{if($1==4){print "1"} else if($2==5){print "2"} else if($3==6){print "3"} else
{print "no"}}' file

43.遍历打印所有字段
awk '{i=1;while(i<=NF){print $i;i++}}' file
awk '{for(i=1;i<=NF;i++)print $i}' file

44.for 语句遍历数组
seq -f "str%.g" 5 |awk '{a[NR]=$0}END{for(v in a)print v,a[v]}'

45.自定义数组
awk 'BEGIN{a[0]="test";print a[0]}'


46.通过 NR 设置记录下标 取值
tail -n3 /etc/passwd |awk -F: '{a[NR]=$1}END{print a[1]}'

47.通过 for 循环遍历数组
打印当前字段属于第几行
tail -n5 /etc/passwd |awk -F: '{a[NR]=$1}END{for(v in a)print a[v],v}'

打印数组的下标
tail -n5 /etc/passwd |awk -F: '{a[NR]=$1}END{for(i=1;i<=NR;i++)print a[i],i}'


48.统计相同字段出现次数
tail /etc/services |awk '{a[$1]++}END{for(v in a)print a[v],v}'


49.打印blp5
tail /etc/services |awk '/blp5/{a[$1]++}END{for(v in a)print a[v],v}'

50.统计TCP连接状态
netstat -antp |awk '/^tcp/{a[$6]++}END{for(v in a)print a[v],v}'

51.只打印出现次数大于等于 2 的
tail /etc/services |awk '{a[$1]++}END{for(v in a) if(a[v]>=2){print a[v],v}}'

52.不打印重复的行：
tail /etc/services |awk '!a[$1]++'

53.根据指定的字段统计出现次数：
cat << EOF > 1.txt
A 192.168.1.1 HTTP
B 192.168.1.2 HTTP
B 192.168.1.2 MYSQL
C 192.168.1.1 MYSQL
C 192.168.1.1 MQ
D 192.168.1.4 NGINX
EOF
awk 'BEGIN{SUBSEP="-"}{a[$1,$2]++}END{for(v in a)print a[v],v}' file


54.排序数组：
seq -f "str%.g" 5 | awk '{a[x++]=$0}END{s=asort(a,b);for(i=1;i<=s;i++)print b[i],i}'
seq -f "str%.g" 5 |awk '{a[x++]=$0}END{s=asorti(a,b);for(i=1;i<=s;i++)print b[i],i}'
asort 将 a 数组的值放到数组 b， a 下标丢弃，并将数组 b 的总行号赋值给 s，新数组 b 下标从 1 开始 然后遍历

55.替换正则匹配的字符串：
tail /etc/services |awk '/blp5/{sub(/tcp/,"icmp");print $0}'


56.在指定行前后加一行：
seq 5 | awk 'NR==2{sub('/.*/',"txt\n&")}{print}'

57.统计字段长度：
tail -n 5 /etc/services |awk '{print length($2)}'

58.统计访问 IP 次数：
awk '{a[$1]++}END{for(v in a)print v,a[v]}' access.log

59.统计访问访问大于 100 次的 IP：
awk '{a[$1]++}END{for(v in a){if(a[v]>100)print v,a[v]}}' access.log

60.统计访问 IP 次数并排序取前 10：
awk '{a[$1]++}END{for(v in a)print v,a[v] |"sort -k2 -nr |head -10"}' access.log

61.统计时间段访问最多的 IP：
awk '$4>="[02/Jan/2017:00:02:00" && $4<="[02/Jan/2017:00:03:00"{a[$1]++}END{for(v in a)print v,a[v]}' access.log

62.统计访问 IP 是 404 状态次数：
awk '{if($9~/404/)a[$1" "$9]++}END{for(i in a)print v,a[v]}' access.log

63.将 a 文件相同 IP 的服务名合并：
cat << EOF > a.txt
192.168.1.1: httpd
192.168.1.1: tomcat
192.168.1.2: httpd
192.168.1.2: postfix
192.168.1.3: mysqld
192.168.1.4: httpd
awk 'BEGIN{FS=":";OFS=":"}{a[$1]=a[$1] $2}END{for(v in a)print v,a[v]}' a.txt

64.获取 Nginx 负载均衡配置端 IP 和端口：
awk '/example-servers1/,/}/{if(NR>2){print s}{s=$2}}' nginx.conf  #example-servers1 为upstream 名

9.shell标准输入 输出和错误
1.打印结果写到文件：
echo "test" > a.txt

2.错误输出结果写到文件：
echo "1 + 1" |bc 2 > error.log

3.标准和错误输出到了空设备。
echo "1 + 1" |bc >/dev/null 2>&1

4.用户输入保存为数组：
read -p "Please input your name: " -a ARRAY
Please input your name: a b c
echo ${ARRAY[*]}

5.让用户选择是否终止循环  trap 命令定义 shell 脚本在运行时根据接收的信号做相应的处理。
#!/bin/bash
trap "func" 2
func() {
	read -p "Terminate the process? (Y/N): " input
	if [ $input == "Y" ]; then
		exit
	fi
}
for i in {1..10}; do
	echo $i
	sleep 1
done

6.环境变量文件
系统级别
/etc/profile # 系统范围内的环境变量和启动文件。不建议把要做的事情写在这里面，最好创建
一个自定义的，放在/etc/profile.d 下
/etc/bashrc # 系统范围内的函数和别名

用户级别
用户级变量文件对自己生效，都在自己家目录下。
~/.bashrc # 用户指定别名和函数
~/.bash_logout # 用户退出执行
~/.bash_profile # 用户指定变量和启动程序
~/.bash_history # 用户执行命令历史文件
开启启动脚本顺序： /etc/profile -> /etc/profile.d/*.sh -> ~/.bash_profile -> ~/.bashrc ->
/etc/bashrc

本地 80 端口转发到本地 8080 端口
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080

批量创建用户
#!/bin/bash
DATE=$(date +%F_%T)
USER_FILE=user.txt
echo_color(){
	if [ $1 == "green" ]; then
			echo -e "\033[32;40m$2\033[0m"
	elif [ $1 == "red" ]; then
		echo -e "\033[31;40m$2\033[0m"
	fi
}
如果用户文件存在并且大小大于 0 就备份
if [ -s $USER_FILE ]; then
	mv $USER_FILE ${USER_FILE}-${DATE}.bak
	echo_color green "$USER_FILE exist, rename ${USER_FILE}-${DATE}.bak"
fi
echo -e "User\tPassword" >> $USER_FILE
for USER in user{1..10}; do
	if ! id $USER &>/dev/null; then
		PASS=$(echo $RANDOM |md5sum |cut -c 1-8)
		useradd $USER
		echo $PASS |passwd --stdin $USER &>/dev/null
		echo -e "$USER\t$PASS" >> $USER_FILE
		echo "$USER User create successful."
	else
		echo_color red "$USER User already exists!"
fi
done



Linux常用命令
ls
-a 显示所有文件，包括隐藏的
-l 长格式列出信息
-i 显示文件 inode 号
-t 按修改时间排序
-r 按修改时间倒序排序
-h 打印易读大小单位

echo
-n 不加换行符
-e 解释转义符

cat
-b 显示非空行行号
-n 显示所有行行号
-T 显示 tab，用^I 表示
-E 显示以$结尾

连接两个文件
cat a b

输入内容
cat <<EOF 
>123
>abc
>EOF

tac
倒序打印每一行：
tac 1.txt

rev 
反向打印文件的每一行
echo "123" |rev


wc 统计行数
-c 打印文件字节数，一个英文字母 1 字节，一个汉字占 2-4 字节（根据编码）
-m 打印文件字符数， 一个汉字占 2 个字符
-l 打印多少行
-L 打印最长行的长度， 也可以统计字符串长度
统计文件多少行：wc -l file

统计字符串长度：echo "hello" | wc -L

cp
-a 归档
-b 目标文件存在创建备份，备份文件是文件名跟~
-f 强制复制文件或目录
-r 递归复制目录
-p 保留原有文件或目录属性
-i 覆盖文件之前先询问用户
-u 当源文件比目的文件修改时间新时才复制
-v 显示复制信息
cp -rf test / 复制目录

mkdir
-p 递归创建目录
-v 显示创建过程
创建多个目录
mkdir {install,tmp}
连续创建目录
mkdir {a..c}

rename 重命名文件
以.htm 后缀的文件替换为.html：
rename .htm .html *.htm

basename 打印路径最后一个名字
basename /www/wwwroot/

du
-h 易读格式显示（K， M， G）
-b 单位 bytes 显示
-k 单位 KB 显示
-m 单位 MB 显示
-s 只显示总大小
--max-depth=<目录层数>，超过层数的目录忽略
--exclude=file 排除文件或目录
--time 显示大小和创建时间

查看目录大小：
du -sh /opt
排除目录某个文件：
du -sh --exclude=test /opt


cut
-b 选中第几个字符
-c 选中多少个字符
-d 指定分隔符分字段，默认是空格
-f 显示选中字段
打印 b 字符：
echo "abc" |cut -b "2"

截取 abc 字符：
echo "abcdef" |cut -c 1-3

以冒号分隔，显示第二个字段：
echo "a:b:c" |cut -d: -f2


tr
-c 替换 SET1 没有 SET2 的字符
-d 删除 SET1 中字符
-s 压缩 SET1 中重复的字符
-t 将 SET1 用 SET2 转换，默认

去重字符
echo "aaacccddd" | tr -s '[a-z]'
替换字符串
echo "aaabbbccc" | tr '[a-z]' '[A-Z]'

stat
-Z 显示 selinux 安全上下文
-f 显示文件系统状态
-c 指定格式输出内容
-t 以简洁的形式打印
显示文件信息：
stat file
只显示文件修改时间：
stat -c %y file

sort
-f 忽略字母大小写
-M 根据月份比较，比如 JAN、 DEC
-h 根据易读的单位大小比较，比如 2K、 1G
-g 按照常规数值排序
-n 根据字符串数值比较
-r 倒序排序
-k 位置 1,位置 2 根据关键字排序， 在从第位置 1 开始， 位置 2 结束
-t 指定分隔符
-u 去重重复行
-o 将结果写入文件
随机数字排序：
seq 5 |shuf |sort
去重重复行
echo -e "1\n1\n2\n3\n3" |sort -u
大小单位排序
du -h |sort -k 1 -h -r

uniq
-c 打印出现的次数
-d 只打印重复行
-u 只打印不重复行
-D 只打印重复行，并且把所有重复行打印出来
-f N 比较时跳过前 N 列
-i 忽略大小写
-s N 比较时跳过前 N 个字符
-w N 对每行第 N 个字符以后内容不做比较
去重复行
sort file |uniq
打印每行重复次数
sort file |uniq -c

tee 从标准输入读取写到标准输出和文件
打印并追加到文件：
echo 123 |tee -a a.log

join 连接两个文件
-i 忽略大小写
-o 按照指定文件栏位显示
-t 使用字符作为输入和输出字段分隔符

将两个文件相同字段合并一列：
join file1 file2

paste 合并文件
-d 指定分隔符，默认是 tab 键分隔
-s 将文件内容平行合并， 默认 tab 键分隔
两个文件合并
paste file1 file2

两个文件合并， +号分隔：
paste -d "+" file1 file2

find
-name 文件名，支持(‘*’ , ‘?’ )
-type 文件类型， d 目录， f 常规文件等
-perm 符合权限的文件，比如 755
-atime -/+n 在 n 天以内/过去 n 天被访问过
-ctime -/+n 在 n 天以内/过去 n 天被修改过
-amin -/+n 在 n 天以内/过去 n 分钟被访问过
-cmin -/+n 在 n 天以内/过去 n 分钟被修改过
-size -/+n 文件大小小于/大于， b、 k、 M、 G
-maxdepth levels 目录层次显示的最大深度
-regex pattern 文件名匹配正则表达式模式
-inum 通过 inode 编号查找文件动作：
-detele 删除文件
-exec command {} \; 执行命令，花括号代表当前文件
-ls 列出当前文件， ls -dils 格式
-print 完整的文件名并添加一个回车换行符
-print0 打印完整的文件名并不添加一个回车换行符
-printf format 打印格式
其他字符：
！ 取反
-or/-o 逻辑或
-and 逻辑和

查找文件名：
find / -name "*http*"
查找文件名并且文件类型：
find /tmp -name core -type f -print
查找文件名并且文件类型删除：
find /tmp -name core -type f -delete
查找当前目录常规文件并查看文件类型：
find . -type f -exec file '{}' \;
查找文件权限是 664：
find . -perm 664
查找大于 1024k 的文件：
find . -size -1024k
查找 3 天内修改的文件：
find /bin -ctime -3
查找 3 分钟前修改的文件：
find /bin -cmin +3
排除多个类型的文件：
find . ! -name "*.sql" ! -name "*.txt"
或条件查找多个类型的文件：
find . -name '*.sh' -o -name '*.bak'
find . -regex ".*\.sh\|.*\.bak"
find . -regex ".*\.\(sh\|bak\)"
并且条件查找文件：
find . -name "*.sql" -a -size +1024k
只显示第一级目录：
find /etc -type d -maxdepth 1
通过 inode 编号删除文件：
rm `find . -inum 671915`
find . -inum 8651577 -exec rm -i {} \;

xargs
-a file 从指定文件读取数据作为标准输入-0 处理包含空格的文件名,print0
-d delimiter 分隔符，默认是空格分隔显示
-i 标准输入的结果以{}代替
-I 标准输入的结果以指定的名字代替
-t 显示执行命令
-p 交互式提示是否执行命令
-n 最大命令行参数
--show-limits 查看系统命令行长度限制
删除/tmp 下名字是 core 的文件：
find /tmp -name core -type f -print | xargs /bin/rm -f
find /tmp -name core -type f -print0 | xargs -0 /bin/rm -f
列转行（去除换行符 ）：
cut -d: -f1 < /etc/passwd | sort | xargs echo
行转列：
echo "1 2 3 4 5" |xargs -n1
最长两列显示：
echo "1 2 3 4 5" |xargs -n2
创建未来十天时间：
seq 1 10 |xargs -i date -d "{} days " +%Y-%m-%d
复制多个目录：
echo dir1 dir2 |xargs -n1 cp a.txt
清空所有日志：
find ./ -name "*.log" |xargs -i tee {} # echo ""> {} 这样不行， >把命令中断了
rm 在删除大量的文件时，会提示参数过长，那么可以使用 xargs 删除：
ls |xargs rm –rf
或分配删除 rm [a-n]* -rf # getconf ARG_MAX 获取系统最大参数限制


wget
下载单个文件到当前目录：
wget http://nginx.org/download/nginx-1.11.7.tar.gz
放到后台下载：
wget -b http://nginx.org/download/nginx-1.11.7.tar.gz
对于网络不稳定的用户使用-c 和--tries 参数，保证下载完成，并下载到指定目录：
wget -t 3 -c http://nginx.org/download/nginx-1.11.7.tar.gz -P down
不下载任何内容，判断 URL 是否可以访问：
wget --spider http://nginx.org/download/nginx-1.11.7.tar.gz
下载内容写到文件：
wget http://www.baidu.com/index.html -O index.html
从文件中读取 URL 下载：
wget -i url.list
下载 ftp 文件：
wget --ftp-user=admin --ftp-password=admin ftp://192.168.1.10/ISO/CentOS-6.5-i386-
minimal.iso伪装客户端，指定 user-agent 和 referer 下载：
wget -U "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko)
Chrome/44.0.2403.157 Safari/537.36" --referer "http://nginx.org/en/download.html"
http://nginx.org/download/nginx-1.11.7.tar.gz
查看 HTTP 头信息：
wget -S http://nginx.org/download/nginx-1.11.7.tar.gz
wget --debug http://nginx.org/download/nginx-1.11.7.tar.gz

curl
-k, --insecure 允许 HTTPS 连接网站
-C, --continue-at 断点续传
-b, --cookie STRING/FILE 从文件中读取 cookie
-c, --cookie-jar 把 cookie 保存到文件
-d, --data 使用 POST 方式发送数据
--data-urlencode POST 的数据 URL 编码
-F, --form 指定 POST 数据的表单
-D, --dump-header 保存头信息到文件
--ftp-pasv 指定 FTP 连接模式 PASV/EPSV
-P, --ftp-port 指定 FTP 端口
-L, --location 遵循 URL 重定向，默认不处理
-l, --list-only 指列出 FTP 目录名
-H, --header 自定义头信息发送给服务器
-I, --head 查看 HTTP 头信息
-o, --output FILE 输出到文件
-#, --progress-bar 显示 bar 进度条
-x, --proxy [PROTOCOL://]HOST[:PORT] 使用代理
-U, --proxy-user USER[:PASSWORD] 代理用户名和密码
-e, --referer 指定引用地址 referer
-O, --remote-name 使用远程服务器上名字写到本地
--connect-timeout 连接超时时间，单位秒
--retry NUM 连接重试次数
--retry-delay 两次重试间隔等待时间
-s, --silent 静默模式，不输出任何内容
-Y, --speed-limit 限制下载速率
-u, --user USER[:PASSWORD] 指定 http 和 ftp 用户名和密码
-T, --upload-file 上传文件
-A, --user-agent 指定客户端信息

下载页面：
curl -o badu.html http://www.baidu.com
不输出下载信息：
curl -s -o baidu.html http://www.baidu.com
伪装客户端，指定 user-agent 和 referer 下载：# curl -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko)
Chrome/44.0.2403.157 Safari/537.36" -e "baike.baidu.com" http://127.0.0.1
模拟用户登录，并保存 cookies 到文件：
curl -c ./cookies.txt -F NAME=user -F PWD=123 http://www.example.com/login.html
使用 cookie 访问：
curl -b cookies.txt http://www.baidu.com
访问 HTTP 认证页面：
curl -u user:pass http://www.example.com
FTP 上传文件：
curl -T filename ftp://user:pass@ip/a.txt
curl ftp://ip -u user:pass-T filename
FTP 下载文件：
curl -O ftp://user:pass@ip/a.txt
curl ftp://ip/filename -u user:pass -o filename
FTP 下载多个文件：
curl ftp://ip/img/[1,3,5].jpg
查看 HTTP 头信息：
curl -I http://www.baidu.com

scp
-i 指定私钥文件
-l 限制速率，单位 Kb/s， 1024Kb=1Mb
-P 指定远程主机 SSH 端口
-p 保存修改时间、访问时间和权限
-r 递归拷贝目录
-o SSH 选项，有以下几个比较常用的：

本地目录推送到远程主机：
scp -P 22 -r src_dir root@192.168.1.10:/dst_dir
远程主机目录拉取到本地：
scp -P 22 root@192.168.1.10:dst_dir src_dir
同步文件方式一样，不用加-r 参数


rsync
-v 显示复制信息
-q 不输出错误信息-c 跳过基础效验，不判断修改时间和大小
-a 归档模式，等效-rlptgoD，保留权限、属组等
-r 递归目录
-l 拷贝软连接
-z 压缩传输数据
-e 指定远程 shell，比如 ssh、 rsh
--progress 进度条，等同-P
--bwlimit=KB/s 限制速率， 0 为没有限制
--delete 删除那些 DST 中 SRC 没有的文件
--exclude=PATTERN 排除匹配的文件或目录
--exclude-from=FILE 从文件中读取要排除的文件或目录
--password-file=FILE 从文件读取远程主机密码
--port=PORT 监听端口
本地复制目录：
rsync -avz abc /opt
本地目录推送到远程主机：
rsync -avz SRC root@192.168.1.120:DST
远程主机目录拉取到本地：
rsync -avz root@192.168.1.10:SRC DST
保持远程主机目录与本地一样：
rsync -avz --delete SRC root@192.168.1.120:DST
排除某个目录：
rsync -avz --exclude=no_dir SRC root@192.168.1.120:DST
指定 SSH 端口：
rsync -avz /etc/hosts -e "ssh -p22" root@192.168.1.120:/opt


nohup
后台运行程序，终端关闭不影响：
nohup bash test.sh &>test.log &

ps
打印系统上所有进程标准语法：
ps -ef
打印系统上所有进程 BSD 语法：
ps aux
打印进程树：
ps axjf 或 ps -ejH
查看进程启动的线程：
ps -Lfp PID
查看当前用户的进程数：
ps uxm 或 ps -U root -u root u自定义格式显示并对 CPU 排序：
ps -eo user,pid,pcpu,pmem,nice,lstart,time,args --sort=-pcpu
或 ps -eo "%U %p %C %n %x %a"

top
刷新一次并输出到文件：
top -b -n 1 > top.log
只显示指定进程的线程：
top -Hp 123
传入交互命令，按 CPU 排序


nc
-i interval 指定间隔时间发送和接受行文本
-l 监听模式，管理传入的连接
-n 不解析域名
-p 指定本地源端口
-s 指定本地源 IP 地址
-u 使用 udp 协议，默认是 tcp
-v 执行过程输出
-w timeout 连接超时时间
-x proxy_address[:port] 请求连接主机使用代理地址和端口
-z 指定扫描监听端口，不发送任何数据

端口扫描：
nc -z 192.168.1.10 1-65535
TCP 协议连接到目标端口：
nc -p 31337 -w 5 192.168.1.10 22
UDP 协议连接到目的端口：
nc -u 192.168.1.10 53
指定本地 IP 连接：
nc -s 192.168.1.9 192.168.1.10 22
探测端口是否开启：
nc -z -w 2 192.168.1.10 22
创建监听 Unix 域 Socket：
nc -lU /var/tmp/ncsocket
通过 HTTP 代理连接主机：
nc -x10.2.3.4:8080 -Xconnect 10.0.0.10 22
监听端口捕获输出到文件：
nc -l 1234 > filename.out
从文件读入到指定端口：
nc host.example.com 1234 < filename.in
收发信息：
nc -l 1234
nc 127.0.0.1 1234
执行 memcahced 命令： printf "stats\n" |nc 127.0.0.1 11211
发送邮件：
nc [-C] localhost 25 << EOF
HELO host.example.com
MAIL FROM: <user@host.example.com>
RCPT TO: <user2@host.example.com>
DATA
Body of email.
.
QUIT
EOF
# echo -n "GET / HTTP/1.0\r\n\r\n" | nc host.example.com 80

eval 执行参数作为 shell 命令
for i in $@; do
	eval $i
done
echo ---
	echo $a
echo $b


iptables 防火墙
iptables -F # 清空表规则，默认 filter 表
iptables -t nat -F # 清空 nat 表
iptables -A INPUT -p tcp --dport 22 -j ACCEPT # 允许 TCP 的 22 端口访问
iptables -I INPUT -p udp --dport 53 -j ACCEPT # 允许 UDP 的 53 端口访问，插入在第一条
iptables -A INPUT -p tcp --dport 22:25 -j ACCEPT # 允许端口范围访问
iptables -D INPUT -p tcp --dport 22:25 -j ACCEPT # 删除这条规则
允许多个 TCP 端口访问
iptables -A INPUT -p tcp -m multiport --dports 22,80,8080 -j ACCEPT
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT # 允许 192.168.1.0 段 IP 访问
iptables -A INPUT -s 192.168.1.10 -j DROP # 对 1.10 数据包丢弃
iptables -A INPUT -i eth0 -p icmp -j DROP # eth0 网卡 ICMP 数据包丢弃，也就是禁 ping
允许来自 lo 接口，如果没有这条规则，将不能通过 127.0.0.1 访问本地服务
iptables -A INPUT -i lo -j ACCEPT
限制并发连接数，超过 30 个拒绝
iptables -I INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 30 -j
REJECT
限制每个 IP 每秒并发连接数最大 3 个
iptables -I INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j
ACCEPT
iptables -A FORWARD -p tcp --syn -m limit --limit 1/s -j ACCEPT
iptables 服务器作为网关时，内网访问公网
iptables –t nat -A POSTROUTING -s [内网 IP 或网段] -j SNAT --to [公网 IP]# 访问 iptables 公网 IP 端口，转发到内网服务器端口
iptables –t nat -A PREROUTING -d [对外 IP] -p tcp --dport [对外端口] -j DNAT --to [内
网 IP:内网端口]
本地 80 端口转发到本地 8080 端口
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
允许已建立及该链接相关联的数据包通过
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# ASDL 拨号上网
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o pppo -j MASQUERADE
设置 INPUT 链缺省操作丢弃所有数据包，只要不符合规则的数据包都丢弃。注意要在最后设置，
以免把自己关在外面！
iptables -P INPUT DROP






















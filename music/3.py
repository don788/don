import sys
import translators as ts

# 必须提供位置参数
if len(sys.argv) < 2:
    print('Usage: %s data' % sys.argv[0])
    sys.exit(1)

# 将命令行上的内容拼接成字符串
data = ' '.join(sys.argv[1:])
# 本例使用搜狗翻译，还有有道、百度、谷歌等选项
try:
    print(ts.sogou(data, 'auto', 'zh-CHS'))
except:
    print('Network Problem')
    sys.exit(2)

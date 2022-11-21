import os
def oss():
    os.system("find /home/www/qingyun/upload/vod/* -name '*\.jpg' > /data/shell/1.txt") 
    with open("/data/shell/1.txt") as f:
              for line in f:
                  result=line
    result=eval(result)
    return result

def imsplit_url(imgurl):
#获取文件名
    result=imgurl.split('/')
    fname=result[-1]
    print(fname.split('.')[-1])
    return result

              
if __name__ == '__main__':
imsplit_url(imgurl2)[-1]

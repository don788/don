import os
from zipfile import ZipFile
import datetime

# 遍历目录，得到该目录下所有的子目录和文件
def getAllFiles(dir):
    for root,dirs,files in os.walk(dir):
        for file in files:
            yield os.path.join(root, file)



# 以年月日作为zip文件名
def genZipfilename():
    today = datetime.date.today()
    basename = today.strftime('%Y%m%d')
    extname = "zip"
    return f"{basename}.{extname}"



def zipWithoutPassword(files,backupFilename):
    with ZipFile(backupFilename, 'w') as zf:
        for f in files:
            zf.write(f)

if __name__ == '__main__':
    # 要备份的目录
    backupDir = r"/usr/local/gacp/nginx/conf/vhosts.d"
    # 要备份的文件
    backupFiles = getAllFiles(backupDir)
    # zip文件的名字“年月日.zip”
    zipFilename = genZipfilename()
    # 自动将要备份的目录制作成zip文件
    zipWithoutPassword(backupFiles, zipFilename)

#!/usr/bin/python3.6
# -*- coding: UTF-8 -*-
from zipfile import ZipFile
import os
import datetime
import logging

LOG_FORMAT = "%(asctime)s %(name)s %(levelname)s %(pathname)s %(message)s "
DATE_FORMAT = '%Y-%m-%d  %H:%M:%S %a '
logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT, datefmt=DATE_FORMAT, filename=r"execute.log")


class Colored(object):
    def red(self, s):
        return Fore.RED + s + Fore.RESET

    def green(self, s):
        return Fore.GREEN + s + Fore.RESET

    def yellow(self, s):
        return Fore.YELLOW + s + Fore.RESET

    def blue(self, s):
        return Fore.BLUE + s + Fore.RESET

    def magenta(self, s):
        return Fore.MAGENTA + s + Fore.RESET

    def cyan(self, s):
        return Fore.CYAN + s + Fore.RESET

    def white(self, s):
        return Fore.WHITE + s + Fore.RESET

    def black(self, s):
        return Fore.BLACK

    def white_green(self, s):
        return Fore.WHITE + Back.GREEN + s + Fore.RESET + Back.RESET

# 以年月日作为zip文件名
def genZipfilename():
    today = datetime.date.today()
    basename = today.strftime('%Y%m%d')
    extname = "zip"
    return f"{basename}.{extname}"

# 遍历目录，得到该目录下所有的子目录和文件
def getAllFiles(dir):
    for root,dirs,files in os.walk(dir):
            for file in files:
                yield os.path.join(root, file)

# 无密码生成压缩文件
def zipWithoutPassword(files,backupFilename):
    with ZipFile(backupFilename, 'w') as zf:
        for f in files:
            zf.write(f)

def zipWithPassword(dir, backupFilename, password=None):
    cmd = f"zip -r -P{password} {backupFilename} {dir}"
    status = os.popen(cmd)
    return status

if __name__ == '__main__':
    ip = input("请输入需要远程的主机IP地址:")
    uname = input("请输入登录用户名:")
    pword = input("请输入登录密码:")
    paramiko_ssh(ip,uname,pword)
    # 要备份的目录
    backupDir = "/data"
    # 要备份的文件
    backupFiles = getAllFiles(backupDir)
    # zip文件的名字“年月日.zip”
    zipFilename = genZipfilename()
    # 自动将要备份的目录制作成zip文件
    zipWithoutPassword(backupFiles, zipFilename)
    # 使用密码进行备份
    zipWithPassword(backupDir, zipFilename, "password123")

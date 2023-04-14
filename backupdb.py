#!/usr/bin/python3
#auther:don 2023/02/03
# coding:utf-8
import os
import time
import subprocess
import logging
import datetime
from colorama import  init, Fore, Back, Style

#定义变量备份4个库
DB_HOST = 'localhost'
DB_USER = 'root'
DB_USER_PASSWD = 'mtDOuNNCLsL1P\$2yVAkL'
DB_NAME1 = 'video_center'
DB_NAME2 = 'app_center_private'
DB_NAME3 = 'app_center_public'
DB_NAME4 = 'video_centersss'
DB_SOCKET = '/home/mysql_6603/mysql.sock'
BACKUP_PATH = '/home/data/dbbackup/'

DATETIME = time.strftime('%Y%m%d-%H%M')
TODAYBACKUPPATH = BACKUP_PATH + DATETIME
#定义服务器，用户名、密码、数据库名称和备份的路径
LOG_FORMAT = "%(asctime)s %(name)s %(levelname)s %(pathname)s %(message)s "
DATE_FORMAT = '%Y-%m-%d  %H:%M:%S %a '
logging.basicConfig(level=logging.DEBUG,format=LOG_FORMAT,datefmt = DATE_FORMAT ,filename=r'/home/data/dbbackup/execute.log')
class Colored(object):
    def red(self,s):
        return Fore.RED + s + Fore.RESET
    def green(self,s):
        return Fore.GREEN + s + Fore.RESET
    def yellow(self,s):
        return Fore.YELLOW + s + Fore.RESET
    def blue(self,s):
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

c=Colored()
#判断文件是否存在  
def create_backup(): 
    print(c.red("开始创建备份文件夹,如果不存在就创建...."))
    #创建备份文件夹
    if not os.path.exists(TODAYBACKUPPATH):
            os.makedirs(TODAYBACKUPPATH)

# 创建备份函数
def run_backup():
    dumpcmd = "/home/mysql_6603/bin/mysqldump -u" + DB_USER + " -p" + DB_USER_PASSWD + " -S " +  DB_SOCKET + " --master-data=2" + " --single-transaction" +" --databases" + " " + DB_NAME1 +" " + DB_NAME2 + " " + DB_NAME3 + " " + DB_NAME4 + " > " + TODAYBACKUPPATH + "/" + "all" + ".sql"
    print(c.red("开始执行备份%s ")%TODAYBACKUPPATH)
    os.system(dumpcmd)
    logging.info(dumpcmd)

#执行压缩的函数
def run_tar():
        compress_file = TODAYBACKUPPATH + ".tar.gz"
        compress_cmd = "tar -czvf " +compress_file+" "+DATETIME
        os.chdir(BACKUP_PATH)
        os.system(compress_cmd)
        print(c.red("压缩已完成......"))
        #删除备份文件夹
        remove_cmd = "rm -rf "+TODAYBACKUPPATH
        os.system(remove_cmd)

#删除历史的备份
def cleanstore():
    command = "find %s -type f -name '*.gz' -mtime +5 |xargs rm -rf" %BACKUP_PATH
    subprocess.call(command, shell=True,stdout=open('{0}/execute.log'.format(BACKUP_PATH),'w'),stderr=subprocess.STDOUT)


## 开始备份数据库
if __name__ == '__main__':
    create_backup()
    run_backup()
    run_tar()
    cleanstore()

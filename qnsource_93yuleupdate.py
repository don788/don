#!/usr/bin/env python

from subprocess import Popen, PIPE
import logging
import time
import traceback
import argparse
import select
import cPickle
import tempfile
import sys
import re
import os
import warnings
from optparse import OptionParser
from datetime import datetime


warnings.filterwarnings("ignore")
reload(sys)
sys.setdefaultencoding('utf8')
logging.basicConfig(level=logging.INFO,
                    filename='/tmp/qnsource93yulemobile.log',
                    format='[%(asctime)s %(levelname)s %(lineno)d %(module)s] %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)


class OutColor():
    """customter colors on winows or linux (nt is winows,posix is linux)
    """

    def __init__(self):
        self.isatty = sys.stdin.isatty()
     # if self.isatty return tty color else return html color

    def htmlstyle(self, s, size='16', color='black'):
        return "<a style='color:%s;font-weight:bold;font-size:%spx' >%s</a>" % (color, size, s)
    if os.name == "nt":
        from colorama import init, Fore, Back, Style
        init(autoreset=True)

        def black(self, s, fontsize='15'):
            """黑色"""
            return Fore.LIGHTBLACK_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#000000')

        def red(self, s, fontsize='15'):
            """字体红色"""
            return Fore.LIGHTRED_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#FF0000')

        def green(self, s, fontsize='15'):
            """字体绿色"""
            return Fore.LIGHTGREEN_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#008000')

        def yellow(self, s, fontsize='15'):
            """字体黄色"""
            return Fore.LIGHTYELLOW + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#FFFF00')

        def blue(self, s, fontsize='15'):
            """字体蓝色"""
            return Fore.LIGHTBLUE_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#0000FF')

        def magenta(self, s, fontsize='15'):
            """字体洋红色"""
            return Fore.LIGHTMAGENTA_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#FF00FF')

        def cyan(self, s, fontsize='15'):
            """字体青色"""
            return Fore.LIGHTCYAN_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#0000CD')

        def white(self, s, fontsize='15'):
            """字体白色"""
            return Fore.LIGHTWHITE_EX + '%s' % s if self.isatty else self.htmlstyle(s, fontsize, '#FFFFFF')
    else:
        def black(self, s, fontsize='15'):
            """黑色"""
            return "%s\033[30m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#000000')

        def red(self, s, fontsize='15'):
            """字体红色"""
            return "%s\033[31m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#FF0000')

        def green(self, s, fontsize='15'):
            """字体绿色"""
            return "%s\033[32m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#008000')

        def yellow(self, s, fontsize='15'):
            """字体黄色"""
            return "%s\033[33m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#FFFF00')

        def blue(self, s, fontsize='15'):
            """字体蓝色"""
            return "%s\033[34m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#0000FF')

        def magenta(self, s, fontsize='15'):
            """字体洋红色"""
            return "%s\033[35m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#FF00FF')

        def cyan(self, s, fontsize='15'):
            """字体青色"""
            return "%s\033[36m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#0000CD')

        def white(self, s, fontsize='15'):
            """字体白色"""
            return "%s\033[37m%s%s[0m" % (chr(27), s, chr(27)) if self.isatty else self.htmlstyle(s, fontsize, '#FFFFFF')


class UpdateCode(OutColor):
    def __init__(self, domain="https://93mobile.iyongjia.com,https://93mobile.fldzxc.com,https://93mobile.webluleo.com,https://93mobile.zafc0431.com,https://93mobile.baohuawei.com"):
        self.gitdir = '/data/gitqn93yule/'
        self.qnbucket = "93mobile"
        self.defaultdomain = domain
        self.qshelllogfile = "/tmp/qnsource_93yulemobile__upload.log"
        self.qshell = "/data/qnsource/conf_93yulemobile/qshell"
        self.qiniuconfdir = "/data/qnsource/conf_93yulemobile/"
        # self.hissaveversf="/tmp/.qiniuversioninfo.pkl"
        self.qnuploadconf = "/tmp/qnupload%s.conf" % datetime.now().strftime("%Y%m%d%H%M%S")
        self.tmpdir = "/tmp/qiniuuploadtmp/%s/" % datetime.now().strftime("%Y%m%d%H%M%S")
        self.changefilelist = "/tmp/qinichangefile%s.txt" % datetime.now().strftime("%Y%m%d%H%M%S")
        self.qiniutmpfilelist = "/tmp/qshellfilelist%s.txt" % datetime.now().strftime("%Y%m%d%H%M%S")
        self.uploadsuccessfile = "/tmp/qnuploadsuccfile%s.txt" % datetime.now().strftime("%Y%m%d%H%M%S")
        self.freshdomainfile = "/tmp/qnfreshfile%s.txt" % datetime.now().strftime("%Y%m%d%H%M%S")
        if not os.path.exists("%s" % self.tmpdir):
            os.makedirs("%s" % self.tmpdir)
        self.lastversion = ''
        # try:
        #     self.lastversion=cPickle.load(open(self.hissaveversnf,"rb"))["lastversion"]
        # except:
        #     self.lastversion=''
        #     pass
        self.currversion = ''
        self.currcommitid = ''
        self.currentbranch = re.compile(r'\* (.*)')
        self.Cmd("git config --global core.quotepath false", cwd=self.gitdir, printmsgout=False, returnvalue=False)
        OutColor.__init__(self)

    def Cmd(self, cmd='', cwd='', printmsgout=True, returnvalue=False, cmdwait=False):
        # cmd=cmd.split()
        # cmd=shlex.split(cmd)
        # cmd=cmd.split()
        # cmd=shlex.split(cmd)
        #out_temp = tempfile.SpooledTemporaryFile(bufsize=10 * 10000)
        #fileno1 = out_temp.fileno()
        p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE, cwd=cwd, shell=True,)
        if cmdwait:
            p.wait()
        # if returnvalue:
        #    p.wait()
        #    resultcode=p.returncode
        #    data=p.stdout.read()+p.stderr.read()
        #    return {"status":resultcode,"resultvalue":data}
        time.sleep(0.9)
        STDOUT = []

        def is_end(p, typeout, typeerror):
            reads = [typeout.fileno(), typeerror.fileno()]
            ret = select.select(reads, [], [])
            msg = ''
            msgerr = ''
            # print ret[0]
            for fd in ret[0]:
                if fd == typeout.fileno():
                    msg = typeout.readline()
                    if msg:
                        if printmsgout:
                            sys.stdout.write("    "+msg)
                        if returnvalue:
                            STDOUT.append("    "+msg)
                        pass
                if fd == typeerror.fileno():
                    msgerr = typeerror.readline()
                    if msgerr:
                        if printmsgout:
                            sys.stderr.write("    "+self.red(msgerr))
                        if returnvalue:
                            STDOUT.append("    "+self.red(msgerr))
                        pass
            try:
                if (msg == '' and msgerr == "") and p.poll() is not None:
                    return True
            except Exception, e:
                logger.info(str(e))
                return True
            return False
        while True:
            if is_end(p, p.stdout, p.stderr):
                break
        if returnvalue:
            resultcode = p.returncode
            data = ''.join(STDOUT)
            return {"status": resultcode, "resultvalue": data}
        return p.returncode

    def SearchVersion(self, remotebranch=False, cwd="", searchbranch=""):
        if remotebranch:
            remotebranch = self.Cmd("git checkout .&& git pull && git branch -a", cwd=cwd, printmsgout=False, returnvalue=True)
            return remotebranch["resultvalue"]
        else:
            branch = self.Cmd("git branch|cat", cwd=cwd, printmsgout=False, returnvalue=True)["resultvalue"]
            if searchbranch:
                re_branch = re.compile(r'%s' % searchbranch)
                if re_branch.findall(branch):
                    return True
                else:
                    return False
            currentbranch = self.currentbranch.findall(branch)
            return currentbranch[0]

    def update_version(self, version=''):
        version = version.lower()
        self.currversion = self.SearchVersion(cwd=self.gitdir).lower()
        if version:
            if version == self.currversion:
                self.currcommitid = self.Cmd("git log -p -2|grep commit|awk '{ print  $2 }'",
                                             cwd=self.gitdir, printmsgout=False, returnvalue=True)["resultvalue"].split()
                # print self.currcommitid
                print self.blue("Getting the latest file...")
                print self.Cmd("git checkout .&& git fetch origin %s|cat" % version, cwd=self.gitdir, printmsgout=False, returnvalue=True, cmdwait=False)["resultvalue"].rstrip()
                # print self.Cmd("git rev-parse HEAD",cwd=self.gitdir,printmsgout=False,returnvalue=True)["resultvalue"].split()
                print self.Cmd("git merge FETCH_HEAD|cat", cwd=self.gitdir, printmsgout=False, returnvalue=True)["resultvalue"].strip("\r\n")
                print self.blue("Switching to the specified branch...")
                print self.red("    warning！请注意此次更新版本和上次相同，但仍然为您获取了远端%s分支的更新，并合并到本地%s分支！" % (version, version))
                return
            else:
                print self.blue("Getting the latest file...")
                # print self.Cmd("git checkout .&& git fetch origin %s" % version,cwd=self.gitdir,printmsgout=False,returnvalue=True,cmdwait=True)["resultvalue"].rstrip()
                resultdict = self.Cmd("git checkout .&& git fetch origin %s|cat" %
                                      version, cwd=self.gitdir, printmsgout=False, returnvalue=True, cmdwait=False)
                print ''.join(resultdict["resultvalue"].rsplit('\n', 1))
                if resultdict["status"] == 0:
                    print self.blue("Switching to the specified branch...")
                    if self.SearchVersion(cwd=self.gitdir, searchbranch="%s" % version):
                        result1 = self.Cmd("git checkout %s  && git merge FETCH_HEAD|cat &&git diff %s %s --stat|cat" %
                                           (version, version, self.currversion), cwd=self.gitdir, printmsgout=False, returnvalue=True)["resultvalue"]
                    else:
                        result1 = self.Cmd("git checkout -b %s origin/%s && git merge FETCH_HEAD|cat && git diff %s %s --stat|cat" %
                                           (version, version, version, self.currversion), cwd=self.gitdir, printmsgout=False, returnvalue=True)["resultvalue"]
                    print ''.join(result1.rsplit('\n', 1))
                print self.blue("Verifying update results...")
                re_mergefail = re.compile(r'Automatic merge failed|fatal')
                if version == self.SearchVersion(cwd=self.gitdir) and not re_mergefail.findall(result1):
                    print "    "+self.green("更新版本到 [%s] 成功！" % version)
                    # try:
                    #     cPickle.dump({"lastversion":"%s" % version},open(self.hissaveversf,"wb"))
                    # except Exception,e:
                    #     print e
                    #     pass
                    self.lastversion = version
                    # print self.yellow("本次更新以下文件存在变动:")
                    # self.Cmd(" git diff --name-only HEAD~ HEAD",cwd=self.gitdir)
                else:
                    print self.red("    "+"更新版本到 [%s] 失败！" % version)
                    self.Cmd("git reset --merge && git checkout %s && git brnach -d %s" %
                             (self.currversion, version), cwd=self.gitdir, printmsgout=False, returnvalue=True)
                    sys.exit(1)
        else:
            print self.Cmd("git branch", cwd=self.gitdir, returnvalue=True)["resultvalue"]

    def SyncChangeFileList(self):
        if (self.currversion != self.lastversion) and self.lastversion != '':
            self.Cmd("git diff --name-only %s %s > %s" % (self.currversion, self.lastversion,
                                                          self.changefilelist), cwd=self.gitdir, printmsgout=False, returnvalue=True)
        else:
            #commitid=self.Cmd("git rev-parse HEAD'",cwd=self.gitdir,printmsgout=False,returnvalue=True)["resultvalue"].split()
            commitid = self.Cmd("git rev-parse HEAD", cwd=self.gitdir, printmsgout=False, returnvalue=True)["resultvalue"].split()
            if not self.currcommitid:
                self.currcommitid = self.Cmd("git log -p -2|grep commit|awk '{ print  $2 }'",
                                             cwd=self.gitdir, printmsgout=False, returnvalue=True)["resultvalue"].split()
                self.currcommitid.remove(self.currcommitid[0])
            self.Cmd("git diff --name-only %s %s  > %s" % (self.currcommitid[0], commitid[0],
                                                           self.changefilelist), cwd=self.gitdir, printmsgout=False, returnvalue=True)
        # print changefilelist
        os.chdir(self.gitdir)
        if os.path.exists(self.changefilelist) and os.path.getsize(self.changefilelist):
            with open("%s" % self.changefilelist, 'rb') as filelist:
                for f in filelist:
                    f = f.strip(os.linesep)
                    if f and os.path.exists(f):
                        self.Cmd("/bin/cp -f  --parents %s %s" % (f, self.tmpdir), cwd=self.gitdir, printmsgout=False, returnvalue=True)
            self.Cmd("%s -m dircache %s %s" % (self.qshell, self.tmpdir, self.qiniutmpfilelist), cwd=self.gitdir, printmsgout=False, returnvalue=True)
            pro_upload_conf = """{
                "src_dir" : "%s",
                "ignore_dir" : false,
                 "file_list" : "%s",
                "bucket" : "%s",
                "overwrite": true,
                "check_exists":true,
                "check_hash":true,
                "rescan_local":true,
                "skip_path_prefixes":".git/",
                "log_level":"info",
                "log_file":"%s"
            }""" % (self.gitdir, self.qiniutmpfilelist, self.qnbucket, self.qshelllogfile)
            try:
                with open(self.qnuploadconf, 'w') as fconf:
                    fconf.write(pro_upload_conf)
                # self.Cmd("cat %s" % self.qnuploadconf,cwd=self.gitdir)
            except Exception, e:
                print logger.info(e)
                sys.exit(1)
            print self.blue("Start uploading files to Qi Niuyun...")
            self.Cmd("%s -m qupload -success-list %s 20 %s" % (self.qshell, self.uploadsuccessfile, self.qnuploadconf), cwd="%s" % self.qiniuconfdir)
            self.Cmd("tail -n 8 %s" % self.qshelllogfile, cwd=self.gitdir)
            self.FreshCdn(domain=self.defaultdomain, domainlistfile=self.uploadsuccessfile)
        else:
            print self.blue("Start uploading files to Qi Niuyun...")
            print self.red("    没有找到变更的文件无需同步,如果确实有变更您可以选择<全量扫描同步>!")

    def SyncSourceToQiNi(self):
        pro_upload_conf = """{
                "src_dir" : "%s",
                "ignore_dir" : false,
                "bucket" : "%s",
                "overwrite": true,
                "check_exists":true,
                "check_hash":true,
                "rescan_local":true,
                "skip_path_prefixes":".git/",
                "log_level":"info",
                "log_file":"%s"
            }""" % (self.gitdir, self.qnbucket, self.qshelllogfile)
        try:
            with open(self.qnuploadconf, 'w') as fconf:
                fconf.write(pro_upload_conf)
            # self.Cmd("cat %s" % self.qnuploadconf,cwd=self.gitdir)
        except Exception, e:
            print logger.info(e)
            sys.exit(1)
        print self.blue("Start rsync source station files to Qi Niuyun...")
        self.Cmd("%s -m qupload -success-list %s 20 %s" % (self.qshell, self.uploadsuccessfile, self.qnuploadconf), cwd="%s" % self.qiniuconfdir)
        self.Cmd("tail -n 8 %s" % self.qshelllogfile, cwd=self.gitdir)
        self.FreshCdn(domain=self.defaultdomain, domainlistfile=self.uploadsuccessfile)

    def FreshCdn(self, domain="", domainlistfile=''):
        if os.path.exists(domainlistfile) and os.path.getsize(domainlistfile):
            #f=open("%s" % self.freshdomainfile, "wb")
            print self.blue("Start refreshing the following url cache...")
            with open("%s" % domainlistfile, 'rb') as filelist:
                tag = 1
                for dm in set(domain.split(",")):
                    f = open("%s" % self.freshdomainfile, "wb")
                    print self.green("    开始刷新，第["), "%s" % self.blue(tag), self.green("]组域名...")
                    for i in filelist:
                        url = os.path.join(dm, i.split()[1]).strip(os.linesep)
                        print "        "+url
                        f.write(url+os.linesep)
                        time.sleep(0.5)
                    filelist.seek(0, 0)
                    f.close()
                    print
                    RESULT = self.Cmd("%s -m cdnrefresh %s" % (self.qshell, self.freshdomainfile), cwd=self.qiniuconfdir, printmsgout=False, returnvalue=True)
                    try:
                        if RESULT["resultvalue"].split(",")[0].split(":")[1].strip() == str(200):
                            print "        "+self.magenta("第[%s]组域名刷新成功！ " % tag)+self.magenta(RESULT["resultvalue"].strip())
                        else:
                            print "        "+self.red("sorry,第[%s]组域名刷新失败！ " % tag)+self.red(RESULT["resultvalue"].strip())
                    except Exception, e:
                        print "        "+self.magenta("sorry,第[%s]组域名刷新失败！ " % tag)+self.magenta(RESULT["resultvalue"].strip())
                    tag += 1
        # domain="https://scmobile.jpwjj.com",refreshflist=self.uploadsuccessfile

    def removefile(self):
        try:
            os.remove(self.qnuploadconf)
            os.remove(self.changefilelist)
            os.remove(self.qiniutmpfilelist)
            os.remove(self.uploadsuccessfile)
            os.remove(self.freshdomainfile)
        except:
            pass


def _main(options):
    if options.domainname:
        updatecode = UpdateCode(domain=options.domainname)
    else:
        updatecode = UpdateCode()
    # updateqn=UploadFileToQiNiu()
    gitdir = updatecode.gitdir
    if options.version:
        updatecode.update_version(version=options.version)
    if options.SearchVersion:
        print updatecode.SearchVersion(cwd=gitdir)
    if options.uploadchangefile:
        updatecode.SyncChangeFileList()
    if options.rsyncsourcetoqiniu:
        updatecode.SyncSourceToQiNi()
    updatecode.removefile()


def main():
    parser = argparse.ArgumentParser(add_help=False)
    group = parser.add_mutually_exclusive_group()
    parser.add_argument('-h', '--help', action='help', help='show this help message and exit')
    parser.add_argument('-C', '--checkout=v1.1.0', dest='version', default="",
                        help='checkout to branch version.'
                        )
    group.add_argument('-u', '--upload', dest="uploadchangefile", default="", action='store_true',
                       help="Synchronously changing files to Qi Niuyun"
                       )
    group.add_argument('-r', '--rsync', dest="rsyncsourcetoqiniu", default="", action='store_true',
                       help="Synchronize source station files to cattleQi Niuyun"
                       )
    parser.add_argument('-n', '--domainname', dest="domainname", default="",
                        help="""The domain name of the file to be refreshed\n
                        default(https://scmobile.zjxhhg.com)\n
                        Must be used with parameter -r/--rsync or -u/--upload"""
                        )
    parser.add_argument('-S', '--search', dest="SearchVersion", default="", action='store_true',
                        help="Serch current branch or serch remotebranch(True)"
                        )
    options = parser.parse_args()
    if len(sys.argv) <= 1:
        parser.print_help()
        parser.exit(1)
    if not options.uploadchangefile and not options.rsyncsourcetoqiniu and options.domainname:
        parser.error("-n/--domainname,Must be used with parameter -r/--rsync or -u/--upload")
        parser.exit()
    try:
        _main(options)
    except Exception, e:
        traceback.print_exc()
        logger.info(str(e))


if __name__ == '__main__':
    main()

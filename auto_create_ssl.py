#!/usr/bin/env python
#coding=utf-8

import os
import sys
import re
import time
import json
import shutil
import tempfile
import smtplib
from email.header import Header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import multiprocessing

import paramiko
import dns.resolver

ALL_ADMIN =   "admin@weststarinc.co"
PH_ADMIN = "ph.admin@weststarinc.co"
#这个证书是为了方便脚本执行shell命令，要求能够
KEY_FILE = "/root/.ssh/id_rsa"
RECORD_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)),"record_certbot.txt")
if not os.path.isfile(RECORD_FILE):
    with open(RECORD_FILE, "w") as fobj:
        fobj.write("")

class S_Host(object):
    def __init__(self,ip="127.0.0.1", user="root", pwd="", port=22, keyfile="", endTag=" ", *args):
        ssh = paramiko.SSHClient()
        ssh.load_system_host_keys()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if not keyfile:
            ssh.connect(ip, username=user, port=port, password=pwd)
        elif keyfile and not pwd:
            ssh.connect(ip, username=user, port=port, key_filename=keyfile)
        else:
            ssh.connect(ip, username=user, port=port, key_filename=keyfile, password=pwd)
        self.endTag = endTag
        self.Debug = False
        self.ssh = ssh

    def disconnect(self,isEnd=False):
        if hasattr(self, "channel"):
            self.channel.close()
        if isEnd:
            self.ssh.close()
        return True

    def exeCmds(self, cmds):
        retInfo = []
        try:
            self.channel = self.ssh.invoke_shell()
            self.channel.settimeout(3600)
            endTag = self.endTag
            ret = ""
            isGet = False
            isFirst = True
            for cmdinfo in cmds:
                endTag = cmdinfo.get("endTag", endTag)
                cmd =  cmdinfo.get("cmd", "")
                match = cmdinfo.get("match", [])
                isGet = cmdinfo.get("isGet", False)
                breakpoint = cmdinfo.get("breakpoint", [])
                if not cmd:
                    continue
                if isFirst:
                    ret = ""
                    while not ret.endswith(self.endTag):
                        recv = self.channel.recv(65535).decode("utf-8")
                        ret += recv
                self.channel.send("%s\n" % cmd)
                ret = ""
                format_ret = ""
                is_first = True
                while not ret.endswith(endTag):
                    recv = self.channel.recv(65535).decode("utf-8")
                    ret += recv
                    format_ret = re.sub("\s*\\r\\n\s*", " ", ret)
                    for index, (out_key, in_words, match_num) in enumerate(match):
                        if format_ret.endswith(out_key) and out_key == "Press Enter to Continue" and is_first:
                            match[index][2] = ret.count(
                                "dns-01 challenge for") - 1
                            is_first = False
                    for index, (out_key, in_words, match_num) in enumerate(match):
                        if format_ret.endswith(out_key) and match_num != 0:
                            self.channel.send("%s\n" % in_words)
                            if match_num > 0:
                                match[index][2] -= 1
                            time.sleep(0.1)
                            break
                        elif format_ret.endswith(out_key) and match_num == 0:
                            for key, bp in breakpoint:
                                if not callable(bp):
                                    continue
                                if key in ret:
                                    bp(ret)
                                    match[index][2] -= 1
                                    self.channel.send("%s\n" % in_words)
                                    break

                if self.Debug:
                    print("@"*32)
                    print(ret)
                    print("@"*32)
                if isGet:
                    ret = re.split("\n|\r\n", ret)[1:-1]
                    retInfo.append(ret)
                self.endTag = endTag
                if isFirst:
                    isFirst = False
        except Exception as e:
            if self.Debug:
                print("{0}ERROR{0}".format("@"*16))
                print(str(e))
                print("@"*37)
            else:
                pass
        self.disconnect()
        return retInfo

def dns_resolver(url,type='A'):
    address = []
    my_resolver = dns.resolver.Resolver()

    # 8.8.8.8 is Google's public DNS server
    my_resolver.nameservers = ['8.8.8.8']
    try:
        host_a = my_resolver.query(url, type)
        if type == 'A':
            for i in host_a.response.answer:
                for j in i.items:
                    if re.match("^[0-9.]*$",str(j)):
                        address.append(str(j))
        elif type == 'TXT':
            txt_info = str(host_a.response.to_text())
            for line in txt_info.split("\n"):
                if url in line:
                    line = line.split()[-1]
                    if line != "TXT":
                        line = re.sub("\"|\'", "", line)
                        address.append(line)

    except:
        pass
    return address

def recheck_record_file():
    out_date = time.strftime("%Y%m%d",time.localtime(time.time() - 3600*24*30))
    tmpfile = tempfile.mktemp()
    with open(RECORD_FILE) as fobj, open(tmpfile, "w") as tmpfobj:
        line = fobj.readline()
        while line:
            if not line.strip():
                line = fobj.readline()
                continue
            js = json.loads(line)
            if int(js[1]) > int(out_date):
                tmpfobj.write(line)
            line = fobj.readline()
    shutil.move(tmpfile, RECORD_FILE)
    return True

def analytics_info(infos):
    domain_uniq_list = {}
    sha_list = []
    new_infos = []
    exist_urls = []

    try:
        fjson = []
        with open(RECORD_FILE) as fobj:
            line = fobj.readline()
            while line:
                if not line.strip():
                    line = fobj.readline()
                    continue
                js = json.loads(line)
                fjson += js[0]
                line = fobj.readline()
        for info in infos:
            for url in info[3]:
                if url in fjson:
                    exist_urls.append([url, info[1]])
    except:
        with open(RECORD_FILE, "") as fobj:
            fobj.write("")

    re_notification(exist_urls)

    for info in infos:
        shaValue = info[0]
        address = info[1]
        urls = info[3]
        for url in urls:
            if url in [x[0] for x in exist_urls]:
                continue
            main_domain = ".".join(url.split(".")[-2:])
            if main_domain not in domain_uniq_list.keys():
                domain_uniq_list.update({main_domain:[[shaValue, url, address],]})
            else:
                domain_uniq_list[main_domain].append([shaValue,url, address])

    m, n = 0, 0
    while n < len(domain_uniq_list.keys()):
        tmp_domain = sorted(domain_uniq_list.keys())[n]
        infos = domain_uniq_list[tmp_domain]

        tmp_sha_list = []
        for info in infos:
            if info[0] not in sha_list:
                tmp_sha_list.append(info[0])
                sha_list.append(info[0])

        if not tmp_sha_list:
            n += 1
            continue
        new_array_list = []
        for _, tmp_infos in domain_uniq_list.items():
            for tmp_info in tmp_infos:
                if tmp_info[0] in tmp_sha_list:
                    m += (len(tmp_info) -1)
                    if m >= 100:
                        new_infos.append(new_array_list)
                        new_array_list = []
                        m = (len(tmp_info) -1)
                    new_array_list.append(tmp_info[1:])
        new_infos.append(new_array_list)
        n += 1

    list_count = zip(range(len(new_infos)),[len(x) for x in new_infos])
    list_count = sorted(list_count, key=lambda x:x[1])
    n = 0
    new_sort_list = [[]]
    for x,y in list_count:
        n += y
        if n >= 100:
            new_sort_list.append([])
            n = y
        new_sort_list[-1].append(x)

    new_domain_list = []
    for x in new_sort_list:
        new_domain_list.append([])
        for n in x:
            new_domain_list[-1] += new_infos[n]

    return new_domain_list

def exec_certbot_single(info):
    if not len(info):
        return True
    cmds = [
    {"cmd":"mkdir -p /data/shell", "isGet":True},
    {"cmd":"[ ! -f \"/data/shell/certbot-auto\" ] && wget https://dl.eff.org/certbot-auto -P /data/shell", "isGet":True},
    {"cmd":"[ ! -x \"/data/shell/certbot-auto\" ] && chmod a+x /data/shell/certbot-auto", "isGet":True},
    ]
    s = S_Host(keyfile=KEY_FILE, endTag="# ")
    s.exeCmds(cmds)
    cmd = "certbot --manual --preferred-challenges dns-01 certonly"
    for ele in info:
        cmd += " -d \"%s\"" % ele[0]
    print cmd

    url_num = 0
    checked_urls = []
    for ele in info:
        if re.match("^\*\..*$", ele[0]):
            checked_urls.append(ele[0])
        url_num += 1

    tmp_urls = [x[0] for x in info]
    for url in checked_urls:
        new_url = re.sub("^\*",".*",url)
        for tmp_url in tmp_urls:
            if re.match(new_url,tmp_url):
                url_num -= 1
        url_num += 1

    url_num -= 1
    cmd_info = {"cmd":cmd, "endTag":"# ", "isGet":True, "match":[["Is this ok [y/N]: ", "y", -1],["(E)xpand/(C)ancel: ", "E",-1],["(Y)es/(N)o: ", "y",-1],["Press Enter to Continue", "",url_num]], "breakpoint":[["verify the record is deployed", modify_txt_records],]}
    ret = s.exeCmds([cmd_info])
    s.disconnect(isEnd=True)

    n = -1
    cert_file = ""
    key_file = ""
    for line in ret[0]:
        if "Congratulations!" in line:
            n = 3
            continue

        if n < 0:
            continue
        elif n >= 0:
            n -= 1

        if n == 2:
            cert_file = line.strip()
        elif n == 0:
            key_file = line.strip()
    if not key_file or not cert_file:
        cert_file = ""
        key_file = ret[0]
    else:
        new_records(info, [cert_file, key_file])

    mail_result(info, [cert_file, key_file])
    return True

def modify_txt_records(ret):
    ret = deal_Info(ret.split("\n"))
    m, n = 0, 0
    is_done = False
    notice_infos = ret
    while True:
        if n == 0:
            mail_notice(notice_infos, m)
        notice_infos = query_txt(notice_infos)
        n += 1
        if n >= 60:
            m += 1
            n = 0
        if not len(notice_infos):
            is_done = True
            break
        if m >= 5:
            break
        time.sleep(60)

    return ret

def deal_Info(info):
    ret = []
    n = -2
    for ele in info:
        if re.match("^\s*Please deploy a DNS TXT record under the name\s*$", ele):
            n = 3

        if n == 2:
            domain = ele.split()[0]
        elif n == 0:
            value = ele.strip()

        if n > 0:
            n -= 1
        elif n == 0:
            ret.append([domain, value])
            domain = ""
            value = ""
            n = -2
    return ret

def exec_certbot(infos):
    #命令certbot_auto不支持多进程同时执行
    for info in infos:
        exec_certbot_single(info)

    return True

def mail_send(toname, subject, text, attachment=[], is_html=True):
    cmd = "python /root/don/mail.py \"{}\" \"{}\" \"{}\" ".format(toname, subject, text)
    if len(attachment):
        cmd += " %s" % " ".join(["\"%s\"" % x for x in attachment])
    os.system(cmd)
    return
    smtpserver = 'smtp.gmail.com'
    sender = 'don09957814172@gmail.com'
    password='hcazpecptdershpe'
    port=587

    # 创建一个带附件的实例
    message = MIMEMultipart()
    message['From'] = sender
    message['To'] = toname
    message['Subject'] = Header(subject, 'utf-8')

    # 邮件正文内容
    if is_html:
        text_type = "html"
    else:
        text_type = "plain"
    message.attach(MIMEText(text, text_type, 'utf-8'))

    # 构造附件1（附件为TXT格式的文本）
    for ele in attachment:
        fname = os.path.basename(ele)
        att = MIMEText(open(ele, 'rb').read(), 'base64', 'utf-8')
        att["Content-Type"] = 'application/octet-stream'
        att["Content-Disposition"] = 'attachment; filename="%s"' % fname
        message.attach(att)

    smtpObj = smtplib.SMTP_SSL()  # 注意：如果遇到发送失败的情况（提示远程主机拒接连接），这里要使用SMTP_SSL方法
    smtpObj.connect(smtpserver, port=port)
#    smtpObj.ehlo()
    smtpObj.starttls()
    smtpObj.login(sender, password)
    smtpObj.sendmail(sender, toname, message.as_string())
    smtpObj.quit()
    return True

def mail_notice(infos, num):
    text = """<pre>Dear 管理员：
      請幫忙添加一下TXT類型的解析記錄，詳情如下。
"""
    for domain,value in infos:
        text += """
 Add TXT record with the name/host
 {}
 with the value
 {}
 and a TTL (Time to Live) (in seconds) of
 1""".format(domain, value)
    text += "</pre>"
    subject = "請根据郵件內容添加TXT類型解析記錄"

    if num == 0:
        toname = ALL_ADMIN
    else:
        toname = PH_ADMIN
        text = "<pre><strong>请根据实际情况确定是否需要转发给台湾同事，并加以催促</strong>\n</pre>" + text

    mail_send(toname, subject, text)
    return True

def re_notification(urls):
    if not len(urls):
        return True

    results = []
    pool = multiprocessing.Pool(processes=5)
    exist_urls = []
    with open(RECORD_FILE) as fobj:
        line = fobj.readline()
        while line:
            if not line.strip():
                line = fobj.readline()
                continue
            tmp_urls = []
            js = json.loads(line)
            for url in urls:
                if url[0] in js[0] and url[0] not in exist_urls:
                    tmp_urls.append(url)
                    exist_urls.append(url[0])
            if not len(tmp_urls):
                line = fobj.readline()
                continue
            results.append(pool.apply_async(mail_result,(tmp_urls, js[2])))
            line = fobj.readline()
    pool.close()
    pool.join()
    return True

def mail_result(domainInfo, fileInfo):
    zipfile = ""
    cert_file, key_file = fileInfo
    ip_dict = {}

    toname = PH_ADMIN
    subject = "CA证书更新邮件-%s" % time.strftime("%Y-%m-%d")

    for ele in domainInfo:
        ele[1] = " ".join(ele[1])
        if ele[1] not in ip_dict.keys():
            ip_dict.setdefault(ele[1],[ele[0],])
        else:
            ip_dict[ele[1]].append(ele[0])

    if not key_file or not cert_file:
        text = """<pre>申请CA证书失败，详情如下：
        <code>
        {}
        </code>
        </pre>""".format("\n".join(key_file))
        mail_send(toname, subject, text)
    else:
        zipfile = compress_file([cert_file, key_file])
        if zipfile is None:
            attachment = []
            text = "<pre>已为以下域名更新证书，但是压缩文件并发送邮件失败，请登录服务器对脚本及证书文件进行检查。"
        else:
            attachment = [zipfile, ]
            text = "<pre>请为以下域名更新CA证书。证书请见附件。<strong>如果包含高防IP，请转发给台湾同事。</strong>"
        for ip,urls in ip_dict.items():
            text += "\n"
            for url in urls:
                text += "\t域名：%s" % url
            text += "\t解析地址：%s" % ip
        text += "</pre>"
        mail_send(toname, subject, text, attachment=attachment)

    if os.path.isfile(zipfile):
        os.remove(zipfile)
    return True

def new_records(info, files):
    timestamp = time.strftime("%Y%m%d")
    with open(RECORD_FILE, 'a') as fobj:
        urls = [x[0] for x in info]
        js = json.dumps([urls,timestamp,files])
        fobj.write("%s\n" % js)
    return True


def compress_file(files):
    timestamp = time.strftime("%Y%m%d%H%M%S")
    while True:
        filename = "/tmp/sslforfree_%s" % timestamp
        if os.path.isdir(filename):
            timestamp = str(int(timestamp) + 1)
            continue
        else:
            os.makedirs(filename)
            break

    cmds = []
    for f in files:
        tmp_cmd = {"cmd":"cp {} /tmp/sslforfree_{}".format(f, timestamp)}
        cmds.append(tmp_cmd)
    cmds += [
    {"cmd":"zip -qj /tmp/sslforfree_{0}.zip /tmp/sslforfree_{0}/*".format(timestamp)},
    {"cmd":"rm -rf /tmp/sslforfree_%s" % timestamp}
    ]
    s = S_Host(keyfile=KEY_FILE, endTag="# ")
    ret = s.exeCmds(cmds)
    s.disconnect(isEnd=True)

    filename = "/tmp/sslforfree_%s.zip" % timestamp
    if os.path.isfile(filename):
        return "/tmp/sslforfree_%s.zip" % timestamp
    else:
        return None

def query_txt(infos):
    ret = []
    for info in infos:
        url = info[0]
        expect_value = info[1]
        req_value = dns_resolver(url, type='TXT')
        if expect_value not in req_value:
            ret.append([url, expect_value])
    return ret

def main(infos):
    try:
        recheck_record_file()
    except:
        with open(RECORD_FILE, "w") as fobj:
            fobj.write("")
    new_infos = analytics_info(infos)
    exec_certbot(new_infos)
    return True

if __name__ == "__main__":
    #infos = [['51:40:C1:46:1B:50:2F:56:E3:77:68:12:E0:CC:7E:F3:BC:4A:B7:36', ['47.57.148.148', '61.4.115.159'], (False, '\xe8\xaf\x81\xe4\xb9\xa6\xe6\x9c\xaa\xe8\xbf\x87\xe6\x9c\x9f\xef\xbc\x8c\xe5\x88\xb0\xe6\x9c\x9f\xe6\x97\xb6\xe9\x97\xb4\xe4\xb8\xba 2020\xe5\xb9\xb407\xe6\x9c\x8806\xe6\x97\xa517\xe6\x97\xb624\xe5\x88\x8655\xe7\xa7\x92'), ['www.hengx1.com', 'www.hengx6.com', 'www.hengx7.com', 'www.hengx10.com', 'www.hengxuan8888.com', 'www.hengx4.com'], ['88888heng.com', 'ajadc.com', 'dlxszc.com', 'hengcai8best.com', 'hengx1.com', 'hengx10.com', 'hengx2.com', 'hengx3.com', 'hengx4.com', 'hengx5.com', 'hengx6.com', 'hengx7.com', 'hengx8.com', 'hengx9.com', 'hengxuan16888.com', 'hengxuan6688.com', 'hengxuan8888.com', 'hxuan168.com', 'hxuan88.com', 'www.88888heng.com', 'www.dlxszc.com', 'www.hengcai8best.com', 'www.hengx1.com', 'www.hengx10.com', 'www.hengx2.com', 'www.hengx3.com', 'www.hengx4.com', 'www.hengx5.com', 'www.hengx6.com', 'www.hengx7.com', 'www.hengx8.com', 'www.hengx9.com', 'www.hengxuan16888.com', 'www.hengxuan6688.com', 'www.hengxuan8888.com', 'www.hxuan168.com', 'www.hxuan88.com']], ['51:40:C1:46:1B:50:2F:56:E3:77:68:12:E0:CC:7E:F3:BC:4A:B7:36', ['47.57.125.211'], (False, '\xe8\xaf\x81\xe4\xb9\xa6\xe6\x9c\xaa\xe8\xbf\x87\xe6\x9c\x9f\xef\xbc\x8c\xe5\x88\xb0\xe6\x9c\x9f\xe6\x97\xb6\xe9\x97\xb4\xe4\xb8\xba 2020\xe5\xb9\xb407\xe6\x9c\x8806\xe6\x97\xa517\xe6\x97\xb624\xe5\x88\x8655\xe7\xa7\x92'), ['hengx7.com', 'hengx10.com', 'hengxuan16888.com', 'hengx1.com', 'hengx3.com', 'hxuan168.com', 'hengx8.com', 'hengx9.com', 'hengx5.com', 'hxuan88.com', 'hengx2.com', 'hengxuan8888.com', 'hengx4.com', 'hengx6.com', 'hengxuan6688.com'], ['88888heng.com', 'ajadc.com', 'dlxszc.com', 'hengcai8best.com', 'hengx1.com', 'hengx10.com', 'hengx2.com', 'hengx3.com', 'hengx4.com', 'hengx5.com', 'hengx6.com', 'hengx7.com', 'hengx8.com', 'hengx9.com', 'hengxuan16888.com', 'hengxuan6688.com', 'hengxuan8888.com', 'hxuan168.com', 'hxuan88.com', 'www.88888heng.com', 'www.dlxszc.com', 'www.hengcai8best.com', 'www.hengx1.com', 'www.hengx10.com', 'www.hengx2.com', 'www.hengx3.com', 'www.hengx4.com', 'www.hengx5.com', 'www.hengx6.com', 'www.hengx7.com', 'www.hengx8.com', 'www.hengx9.com', 'www.hengxuan16888.com', 'www.hengxuan6688.com', 'www.hengxuan8888.com', 'www.hxuan168.com', 'www.hxuan88.com']], ['51:40:C1:46:1B:50:2F:56:E3:77:68:12:E0:CC:7E:F3:BC:4A:B7:36', ['61.4.115.159', '47.57.148.148'], (False, '\xe8\xaf\x81\xe4\xb9\xa6\xe6\x9c\xaa\xe8\xbf\x87\xe6\x9c\x9f\xef\xbc\x8c\xe5\x88\xb0\xe6\x9c\x9f\xe6\x97\xb6\xe9\x97\xb4\xe4\xb8\xba 2020\xe5\xb9\xb407\xe6\x9c\x8806\xe6\x97\xa517\xe6\x97\xb624\xe5\x88\x8655\xe7\xa7\x92'), ['www.hengxuan.com']]
    infos = [['51:40:C1:46:1B:50:2F:56:E3:77:68:12:E0:CC:7E:F3:BC:4A:B7:36', ['61.4.115.159', '47.57.148.148'], (False, '\xe8\xaf\x81\xe4\xb9\xa6\xe6\x9c\xaa\xe8\xbf\x87\xe6\x9c\x9f\xef\xbc\x8c\xe5\x88\xb0\xe6\x9c\x9f\xe6\x97\xb6\xe9\x97\xb4\xe4\xb8\xba 2020\xe5\xb9\xb407\xe6\x9c\x8806\xe6\x97\xa517\xe6\x97\xb624\xe5\x88\x8655\xe7\xa7\x92'), ["oisjrgiks.com","wap.oisjrgiks.com","www.oisjrgiks.com","laksjfl.com","www.laksjfl.com","wap.laksjfl.com","oaihdk.com","www.oaihdk.com","wap.oaihdk.com","oaiwehfj.com","www.oaiwehfj.com","wap.oaiwehfj.com","sexy121.com","wap.sexy121.com","www.sexy121.com","sexy556.com","www.sexy556.com","wap.sexy556.com","sexy668.com","www.sexy668.com","wap.sexy668.com","sexyabc.com","www.sexyabc.com","wap.sexyabc.com","usdhnfu.com","www.usdhnfu.com","wap.usdhnfu.com"]]]
    RET = main(infos)
    sys.exit(0) if RET else sys.exit(1)


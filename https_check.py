#!/usr/bin/env python
#coding=utf-8

from __future__ import print_function
import time
import ssl
import os
import sys
import re
import socket
import getopt
import multiprocessing

from OpenSSL import crypto
import dns.resolver

from auto_create_ssl import main as auto_create_ssl

def getCrt(url):
    try:
        context = ssl.SSLContext(ssl.PROTOCOL_TLS)
        sock = socket.socket(socket.AF_INET)
        sock.settimeout(10)
        wrappedSocket = context.wrap_socket(socket.socket(socket.AF_INET), server_hostname=url)
        wrappedSocket.settimeout(30)
        wrappedSocket.connect((url, 443))
        pem_cert = ssl.DER_cert_to_PEM_cert(wrappedSocket.getpeercert(True))
        wrappedSocket.close()
        return pem_cert
    except :
        return False


def singleCheck(url, dNum):
    dnsList = []
    shaValue = ""
    retInfo = False, ""
    tryNum = 3

    address = []
    try:
        host_a = dns.resolver.query(url, 'A')
        for i in host_a.response.answer:
            for j in i.items:
                if re.match("^[0-9.]*$",str(j)):
                    address.append(str(j))
    except:
        pass

    try:
        n = 0
        while True:
            pem_cert = getCrt(url)
            if not pem_cert:
                raise IOError("Failed to get cert file from %s." % url)
            io_cert = crypto.load_certificate(crypto.FILETYPE_PEM, pem_cert)

            for i in range(io_cert.get_extension_count()):
                tmp_info = str(io_cert.get_extension(i))
                if re.match("^[0-9A-F:]*$", tmp_info.strip()):
                    shaValue = tmp_info
                elif "DNS:" in tmp_info:
                    dnsList = [x.replace("DNS:","").strip() for x in tmp_info.split(",")]
            if not dnsList:
                retInfo = False, "脚本检查证书失败。"
                return shaValue, address, retInfo, [url, ],[url, ]
            else:
                is_match = False
                for ele in dnsList:
                    ele = re.sub("\.","\.", ele)
                    ele = re.sub("\*",".*", ele)
                    if re.match(ele, url):
                        is_match = True
                        break
                if not is_match:
                    retInfo = True, "证书非法，证书内未包含该域名。"
                    return shaValue, address, retInfo, [url,], [url, ]

            if url not in dnsList:
                dnsList.append(url)
            ssl_time = io_cert.get_notAfter().decode()[:-1]
            current_time = time.strftime("%Y%m%d%H%M%S")
            ssl_not_after = '{}年{}月{}日{}时{}分{}秒'.format(ssl_time[:4],ssl_time[4:6],ssl_time[6:8],ssl_time[8:10],ssl_time[10:12],ssl_time[12:14])
            if int(current_time) > int(ssl_time):
                if n < tryNum:
                    n += 1
                    continue
                retInfo = False, "证书已过期，过期时间为 %s" % (ssl_not_after)
                return shaValue, address, retInfo, [url, ], dnsList
            if int(time.strftime("%Y%m%d%H%M%S", time.localtime(time.time() + 24*3600*dNum))) > int(ssl_time):
                if n < tryNum:
                    n += 1
                    continue
                retInfo = False, "证书未过期，到期时间为 %s" % (ssl_not_after)
            else:
                retInfo = True, "证书未过期，到期时间为 %s" % (ssl_not_after)
            return shaValue, address, retInfo, [url, ], dnsList
    except Exception as e:
        retInfo = True, "未发现 ssl 证书"
        return shaValue, address, retInfo, [url, ], [url, ]

def multiCheck(urls, dNum):
    retList = []
    pool = multiprocessing.Pool(processes=10)

    obj_l = []
    tmp_urls = []
    generic_urls = []
    as_generic_urls = []
    for url in urls:
        if re.match("^\*\..*",url):
            generic_urls.append(url)
            new_url = re.sub("^\*\.","",url)
            tmp_urls.append(new_url)
            if new_url not in urls:
                as_generic_urls.append(new_url)
        else:
            tmp_urls.append(url)
    urls = list(set(tmp_urls))

    results = []
    for url in urls:
        url = url.strip()
        results.append(pool.apply_async(singleCheck,(url, dNum)))
    pool.close()
    pool.join()
    shaValue = ""
    address = []
    retInfo = ""

    for res in results:
        shaValue, address, retInfo = "", [], ""
        shaValue, address, retInfo, url, ssl_url = res.get()
        isNew = True
        for ele in retList:
            if shaValue == ele[0] and retInfo == ele[2] and address == ele[1]:
                urlList = list(set(url).union(set(ele[3])))
                ele[3] = urlList
                isNew = False
        if isNew:
            retList.append([shaValue, address, retInfo, url, ssl_url])

    tmp_generic_urls = []
    for url in generic_urls:
        if url in tmp_generic_urls:
            continue
        new_url = re.sub("\*",".*",url)
        new_url2 = re.sub("^\*\.", "", url)
        for i,ele in enumerate(retList):
            new_checked_urls = []
            checked_urls = ele[3]
            for checked_url in checked_urls:
                if re.match(new_url,checked_url) or checked_url == new_url2:
                    new_checked_urls.append(url)
                    tmp_generic_urls.append(url)
                    break
            retList[i][3] += new_checked_urls
            if url in tmp_generic_urls:
                break

    for i,ele in enumerate(retList):
        checked_urls = ele[3]
        tmp_urls = []
        for checked_url in checked_urls:
            if checked_url not in as_generic_urls:
                tmp_urls.append(checked_url)
        retList[i][3] = tmp_urls
    return retList

def opetion_check(args):
    ret_dict = {}
    try:
        opts, args = getopt.getopt(args, "sq",["issave","onlyquery"])
    except:
        opts, args = (("",""),),["",]
    ret_dict.setdefault("issave", True)
    ret_dict.setdefault("onlyquery", False)
    ret_dict.setdefault("urls",args)
    for k,v in opts:
        if k in ("-s", "--save"):
            ret_dict["issave"] = True
        elif k in ("-q", "--onlyquery"):
            ret_dict["onlyquery"] = True

    return ret_dict

def main(issave=True, onlyquery=False, urls=[]):
    expireNum = 7
    if not len(urls):
        with open("/data/shell/4.txt") as fobj:
            urls = fobj.readlines()
    else:
        urls = [x.strip() for x in urls]
    retList = multiCheck(urls, expireNum)
    new_retList = []
    for ele in retList:
        if ele[2][0]:
            continue
        new_retList.append(ele)

    today = time.strftime("%Y%m%d")
    toname = 'bill.li@networkws.com,ph.admin@weststarinc.co'
    toname = 'bill.li@networkws.com,ph.admin@weststarinc.co'
    subject = 'https证书过期检测%s' % today
    mailInfo = []
    for ele in new_retList:
        mailInfo.append("-"*64)
        mailInfo.append("域名列表如下：")
        mailInfo.append(" ".join(ele[-2]))
        mailInfo.append("证书包含域名列表如下：")
        mailInfo.append(" ".join(ele[-1]))
        mailInfo.append("解析地址为：%s" % " ".join(ele[1]))
        mailInfo.append("证书信息：%s" % ele[2][1])
        mailInfo.append("-"*64)
    if not len(mailInfo):
        mailInfo.insert(0,"没有需要处理的域名")
    else:
        mailInfo.insert(0,"需要处理的https证书的域名列表，列表为空表示没有即将过期（%d天）、或已过期的域名" % expireNum)
    p = "\n".join(mailInfo)

    os.system('python /data/shell/mail.py %s %s "<pre><h3><font face="SimSun"> %s </font></h3></pre>" ' %(toname, subject, p))

#    print(p)
    if not onlyquery:
        auto_create_ssl(retList)
    return

if __name__ == "__main__":
    args = sys.argv[1:]
    args_dict = opetion_check(args)
    main(**args_dict)

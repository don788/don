#!/usr/bin/python 
#coding:utf-8 
 
import smtplib,os,time 
from email.mime.text import MIMEText 
from email.mime.multipart import MIMEMultipart
from sys import argv,exit
############################
'''
smtp 1 首先使用此smtp,如有问题则使用smtp2
'''
gmail1_smtpserver='smtp.gmail.com'
gmail1_username= 'don09957814172@gmail.com'
gmail1_password='hcazpecptdershpe'
gmail1_port=587
gmail1_disname="TD运维处<don09957814172@gmail.com>"
#######################################
'''
如果smtp1出问题则使用此smtp，如果此smtp有问题则使用备用smtp
'''
gmail2_smtpserver='smtp.gmail.com'
gmail2_username= 'don09957814172@gmail.com'
gmail2_password='hcazpecptdershpe'
gmail2_port=587
gmail2_disname="TD运维处<don09957814172@gmail.com>"

########################################
'''
如果smtp2出问题则使用此smtp，如果此smtp有问题则使用备用smtp3
'''
gmail3_smtpserver='smtp.gmail.com'
gmail3_username= 'don09957814172@gmail.com'
gmail3_password='hcazpecptdershpe'
gmail3_port=587 
gmail3_disname="TD运维处<don09957814172@gmail.com>"
###########################################
'''
#如果smtp3出问题则使用此smtp，如果此smtp有问题则使用备用smtp
'''
gmail4_smtpserver='smtp.gmail.com'
gmail4_username= 'don09957814172@gmail.com'
gmail4_password='hcazpecptdershpe'
gmail4_port=587
gmail4_disname="TD运维处<don09957814172@gmail.com>"

##############################################################
'''
备用smtp
'''
#mail_server = "119.9.94.87"
#mail_user = 'replmonitor'
#mail_postfix='s8-mail.com'
#mail_server_port=25
#mail_disname="cp 运维事业部"
gmail3_smtpserver='smtp.gmail.com'
gmail3_username= 'don09957814172@gmail.com'
gmail3_password='hcazpecptdershpe'
gmail3_port=587
gmail3_disname="TD运维处<don09957814172@gmail.com>"


try:
    script,to_list,subject,mail_content=argv[0],argv[1],argv[2],argv[3]
except Exception,e:
    print "Usage: %s <exam1@126.com,exam2@126.com,..> <subject> <content> [<attachment filename1 filename2 ...>]" % argv[0]
    exit()
    
if len(argv)<=4:
    filename=''
else:
    filename=argv[4:]
   
sendto_list=to_list.split(',')[0].split()
cc_list=to_list.split(',')[1:]
COMESPACE=','
msg = MIMEMultipart()
try:
    fo=open(mail_content,"rb")
    mailcontent=MIMEText(fo.read(),'html','utf-8')
    #mailcontent=MIMEText(fo.read())
except:
     mailcontent=MIMEText(mail_content,'html','utf-8')

'''
添加要发送的附件部分
'''
if filename:
    for i in filename:
        mail_dis_filename=os.path.basename(i)
        try:
            att1 = MIMEText(open(i,'rb').read(), 'base64', 'utf-8')
        except Exception,e:
            print time.strftime('%Y-%m-%d %H:%m:%d errorinfo ')+str(e)
            mail_content=MIMEText(mail_content+e,'html','utf-8')
            continue
        att1["Content-Type"] = 'application/octet-stream'
        att1["Content-Disposition"] = 'attachment; filename=%s' % mail_dis_filename
        msg.attach(att1)
msg.attach(mailcontent)
   
def mail_heard():
    msg['Subject']=subject
    msg['From']=gmail_from
    msg['to'] =COMESPACE.join(sendto_list)
    if cc_list:
        msg['Cc']=COMESPACE.join(cc_list)
def conn_protocol():
    server.ehlo()
    server.starttls()
    server.ehlo()
  
for i in 4,4,5:
    try:
        if i == 5:
            gmail_from=mail_disname+"<"+mail_user+"@"+mail_postfix+">"
            server.ehlo()
            server=smtplib.SMTP(mail_server,mail_server_port,timeout=60)
            server.ehlo()
            break
        exec('gmail_from'+'=gmail%s_disname' % i)
        exec('gmail_smtp'+'=gmail%s_smtpserver'% i)
        exec('gmail_port'+'=gmail%s_port' % i)
        exec('gmail_username'+'=gmail%s_username' % i)
        exec('gmail_password'+'=gmail%s_password' % i)
        server=smtplib.SMTP(gmail_smtp,port=gmail_port,timeout=5)
        conn_protocol()
        server.login(gmail_username,gmail_password)
        break
    except Exception,e:
        print time.strftime('%Y-%m-%d %H:%m:%d errorinfo ' )+"gmail%s" % i+str(e)
        continue
def send():
    try:
        mail_heard()
        server.sendmail(gmail_from,sendto_list+cc_list,msg.as_string())
        print time.strftime('[%Y-%m-%d %H:%m:%d]')+"Congratulations,Send mail OK!"
        time.sleep(5)
        server.quit()
    except Exception, e:
        print "send error: "+time.strftime('%Y-%m-%d %H:%m:%d errorinfo ')+str(e)
if __name__ == "__main__":
    send()

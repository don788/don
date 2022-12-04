
import paramiko
def paramiko_ssh(ip,uname,pword):
    # 建立一个sshclient对象
    ssh = paramiko.SSHClient()
    # 允许将信任的主机自动加入到host_allow 列表，此方法必须放在connect方法的前面
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    # 调用connect方法连接服务器
    ssh.connect(hostname=ip,port=30000,username=uname,password=pword)
    # 手动输入待执行命令
    mycmd = input("请输入需要执行的命令:")
    stdin,stdout,stderr = ssh.exec_command(mycmd)
    # 直接执行指定命令
    #ssh.exec_command('cd /tmp/ && touch paramiko.txt && ech > paramiko.txt')
    # 结果放到stdout中，如果有错误将放到stderr中
    print(stdout.read().decode())
    print(stderr.read().decode())
    # 关闭连接

    
if __name__ == '__main__':
    ip = input("请输入需要远程的主机IP地址:")
    uname = input("请输入登录用户名:")
    pword = input("请输入登录密码:")
    paramiko_ssh(ip,uname,pword)

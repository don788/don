#!/usr/bin/python3
import socket
import requests


def get_cname(domain):
    try:
        cname = socket.gethostbyname_ex(domain)
        return cname[0] if cname else None
    except socket.gaierror:
        return None


def check_cname_and_alert(domain):
    cname_value = get_cname(domain)
    if cname_value:
        print(f"The CNAME value for {domain} is: {cname_value}")
    else:
        message_text="域名{0} no resolution record, delete the certificate".format(domain)
        token = "5436217478:AAGmKbs77Jwgz5ALP5MEj-NeMq3yIr1t_Bg"
        chat_id="@don98765432"
        url = f"https://api.telegram.org/bot{token}/sendMessage"
        params = {
        'chat_id': chat_id,
        'text': message_text,
        'token': token
        }
        # 在这里触发报警，这里简单打印一个警告信息
        requests.post(url, params=params)

def check_cnames_from_file(file_path):
    try:
        with open(file_path, 'r') as file:
            domains = file.readlines()
            domains = [domain.strip() for domain in domains]

            for domain in domains:
                check_cname_and_alert(domain)
    except FileNotFoundError:
        print(f"Error: File {file_path} not found.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


# 替换为你的文件路径
file_path = "/root/domains.txt"

# 检查文件中的域名CNAME值
check_cnames_from_file(file_path)


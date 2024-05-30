#!/usr/bin/python3
# coding:utf-8
# auther: don 2024/05/08
import os
import requests
import shutil
import multiprocessing
from urllib.parse import urlparse
from tqdm import tqdm
from functools import partial

def read_urls_from_file(file_path):
    with open(file_path, 'r') as file:
        for line in file:
            yield line.strip()

# 创建父目录和子目录
def create_parent_and_sub_dirs(url, destination_base_dir):
    url_path = urlparse(url).path
    parent_dir = os.path.join(destination_base_dir, os.path.dirname(url_path))
    os.makedirs(parent_dir, exist_ok=True)
    return parent_dir

# 下载文件并移动到目录
def download_and_move(url, destination_base_dir, output_file):
    try:
        response = requests.get(url, stream=True)
        file_name = os.path.basename(urlparse(url).path)
        parent_dir = create_parent_and_sub_dirs(url, destination_base_dir)
        file_path = os.path.join(parent_dir, file_name)
        with open(file_path, 'wb') as file:
            total_size = int(response.headers.get('content-length', 0))
            with tqdm(total=total_size, unit='B', unit_scale=True, desc=file_name, ascii=True) as progress_bar:
                for data in response.iter_content(chunk_size=1024):
                    file.write(data)
                    progress_bar.update(len(data))
        with open(output_file, 'a') as f:
            f.write(f"Downloaded: {url}\n")
        return True, f"File already have been downloaded: {file_path}"
    except Exception as e:
        with open(output_file, 'a') as f:
            f.write(f"Failed to download {url}: {str(e)}\n")
        return False, f"Failed to download {url}: {str(e)}"

# 主函数
def main():
    # 目标目录
    destination_base_dir = "/data/"
    output_file = "202405_16_downloadlogs.txt"

    # 获取当前目录下所有的txt文件
    txt_files = [file for file in os.listdir() if file.endswith('.txt')]

    # 读取URL列表
    urls = []
    for file_path in txt_files:
        urls.extend(read_urls_from_file(file_path))

    # 设置并发下载的数量
    concurrency = 60

    # 使用进程池并发下载
    with multiprocessing.Pool(processes=concurrency) as pool:
        download_func = partial(download_and_move, destination_base_dir=destination_base_dir, output_file=output_file)
        for result in pool.imap_unordered(download_func, urls):
            print(result)

if __name__ == "__main__":
    main()


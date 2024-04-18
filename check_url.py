import re
import threading
import requests

def extract_urls_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
        urls = re.findall(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', content)
        return urls

def check_urls_status(urls):
    non_200_urls = []
    for url in urls:
        try:
            response = requests.head(url)
            if response.status_code != 200:
                non_200_urls.append(url)
        except requests.RequestException:
            non_200_urls.append(url)
    return non_200_urls

def write_to_file(urls, output_file_path):
    with open(output_file_path, 'w', encoding='utf-8') as output_file:
        for url in urls:
            output_file.write(url + '\n')

def main(input_file_path, output_file_path):
    urls = extract_urls_from_file(input_file_path)
    non_200_urls = check_urls_status(urls)

    if non_200_urls:
        write_to_file(non_200_urls, output_file_path)
        print(f"URLs not 200 status to {output_file_path}")
    else:
        print("All URLs returned a 200 status code.")

if __name__ == "__main__":
    input_file_path = "/root/m3u8.txt"  
    output_file_path = "/root/non_200_urls.txt" 
    main(input_file_path, output_file_path)





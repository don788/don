import os
import requests
from concurrent.futures import ThreadPoolExecutor
class FileManager:
    def __init__(self):
        self.session = requests.Session()

    def download_image(self, url, destination, headers=None):
        try:
            response = self.session.get(url, stream=True, headers=headers)
            with open(destination, 'wb') as f:
                for chunk in response.iter_content(chunk_size=1024):
                    if chunk:
                        f.write(chunk)
            print(f"Downloaded {destination}")
        except Exception as e:
            print(f"Failed to download {url}: {str(e)}")

    def download_images(self, image_file, download_dir, headers=None):
        os.makedirs(download_dir, exist_ok=True)
        try:
            with open(image_file, 'r') as file:
                image_list = [line.strip() for line in file if line.strip()]
        except Exception as e:
            print(f"Failed to read image file {image_file}: {str(e)}")
            return

        with ThreadPoolExecutor(max_workers=10) as executor:
            for url in image_list:
                if not url:
                    print("Empty URL detected, skipping.")
                    continue
                filename = url.split('/')[-1]
                destination = os.path.join(download_dir, filename)
                executor.submit(self.download_image, url, destination, headers=headers)

# Example usage
file_manager = FileManager()

# File containing image URLs
image_file = 'english.txt'
download_dir = 'image_downloads'
custom_headers = {'User-Agent': 'Mozilla/5.0'}
file_manager.download_images(image_file, download_dir, headers=custom_headers)


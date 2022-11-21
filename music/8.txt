import os
# 定义文件类型和它的扩展名
file_type = {
    "music": ("mp3", "wav"),
    "movie": ("mp4", "rmvb", "rm", "avi"),
    "execute": ("exe", "bat")
}

source_dir = "/root/don"

def make_new_dir(dir, type_dir):
    for td in type_dir:
        new_td = os.path.join(dir, td)
        if not os.path.isdir(new_td):
            os.makedirs(new_td)

# 建立新的文件夹
make_new_dir(source_dir, file_type)

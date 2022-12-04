import subprocess
def jarList():
    command = "powershell'"
    p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    port_list = p.stdout.read().split('\n')

jarList()

system_check() {
  yum -y install the_silver_searcher
  #登陆用户
  echo -e "\e[00;31m[+]登陆用户\e[00m"
  who 
  #CPU占用TOP 15
  cpu=$(ps aux | grep -v ^'USER' | sort -rn -k3 | head -15) 2>/dev/null
  echo -e "\e[00;31m[+]CPU TOP15:  \e[00m\n${cpu}\n" 
  #内存占用TOP 15
  mem=$(ps aux | grep -v ^'USER' | sort -rn -k4 | head -15) 2>/dev/null
  echo -e "\e[00;31m[+]内存占用 TOP15:  \e[00m\n${mem}\n" 
  #内存占用
  echo -e "\e[00;31m[+]内存占用\e[00m"
  free -mh 
  ag -v "#" </etc/fstab | awk '{print $1,$2,$3}'
  echo -e "\e[00;31m[+]CPU使用率:\e[00m" | tee -a "$filename"
  awk '$0 ~/cpu[0-9]/' /proc/stat 2>/dev/null | while read line; do
  echo "$line" | awk '{total=$2+$3+$4+$5+$6+$7+$8;free=$5;\
        print$1" Free "free/total*100"%",\
        "Used " (total-free)/total*100"%"}'
  done
  #端口监听
  echo -e "\e[00;31m[+]端口监听\e[00m" 
  netstat -tulpen | ag 'tcp|udp.*' --nocolor
  #对外开放端口
  echo -e "\e[00;31m[+]对外开放端口\e[00m" 
  netstat -tulpen | awk '{print $1,$4}' | ag -o '.*0.0.0.0:(\d+)|:::\d+' --nocolor
  #网络连接
  netstat -antop | ag ESTAB --nocolor
  #连接状态
  echo -e "\e[00;31m[+]TCP连接状态\e[00m"
  netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
  cat /etc/passwd | ag -v 'nologin$|false$'
  echo -e "\e[00;31m[+]passwd文件修改日期: \e[00m" $(stat /etc/passwd | ag -o '(?<=Modify: ).*' --nocolor) 
  echo -e "\e[00;31m[+]sudoers(请注意NOPASSWD)\e[00m"
  cat /etc/sudoers | ag -v '#' | sed -e '/^$/d' | ag ALL --nocolor
  last 
  lastlog
  echo "登陆ip: $(ag -a accepted /var/log/secure /var/log/auth.* 2>/dev/null | ag -o '\d+\.\d+\.\d+\.\d+' | sort | uniq)"
  #近7天改动
  echo -e "\e[00;31m[+]近七天文件改动 mtime \e[00m"
  find /etc /bin /lib /sbin /dev /root/ /home /tmp /var /usr ! -path "/var/log*" ! -path "/var/spool/exim4*" ! -path "/var/backups*" -mtime -7 -type f | ag -v '\.log|cache|vim|/share/|/lib/|.zsh|.gem|\.git|LICENSE|README|/_\w+\.\w+|\blogs\b|elasticsearch|nohup|i18n' | xargs -i{} ls -alh {} 
  echo -e "\n" 
  #近7天改动
  echo -e "\e[00;31m[+]近七天文件改动 ctime \e[00m"
  find /etc /bin /lib /sbin /dev /root/ /home /tmp /var /usr ! -path "/var/log*" ! -path "/var/spool/exim4*" ! -path "/var/backups*" -ctime -7 -type f | ag -v '\.log|cache|vim|/share/|/lib/|.zsh|.gem|\.git|LICENSE|README|/_\w+\.\w+|\blogs\b|elasticsearch|nohup|i18n' | xargs -i{} ls -alh {} 
  echo -e "\n" 
  find / ! -path "/lib/modules*" ! -path "/usr/src*" ! -path "/snap*" ! -path "/usr/include/*" -regextype posix-extended -regex '.*sqlmap|.*msfconsole|.*\bncat|.*\bnmap|.*nikto|.*ettercap|.*tunnel\.(php|jsp|asp|py)|.*/nc\b|.*socks.(php|jsp|asp|py)|.*proxy.(php|jsp|asp|py)|.*brook.*|.*frps|.*frpc|.*aircrack|.*hydra|.*miner|.*/ew$' -type f | ag -v '/lib/python' | xargs -i{} ls -alh {}
  find /root /home /opt /tmp /var/ /dev -regextype posix-extended -regex '.*wget|.*curl|.*openssl|.*mysql' -type f 2>/dev/null | xargs -i{} ls -alh {} | ag -v '/pkgs/|/envs/'
  echo -e "\e[00;31m[+]lsmod 可疑模块\e[00m"
  lsmod | ag -v "ablk_helper|ac97_bus|acpi_power_meter|aesni_intel|ahci|ata_generic|ata_piix|auth_rpcgss|binfmt_misc|bluetooth|bnep|bnx2|bridge|cdrom|cirrus|coretemp|crc_t10dif|crc32_pclmul|crc32c_intel|crct10dif_common|crct10dif_generic|crct10dif_pclmul|cryptd|dca|dcdbas|dm_log|dm_mirror|dm_mod|dm_region_hash|drm|drm_kms_helper|drm_panel_orientation_quirks|e1000|ebtable_broute|ebtable_filter|ebtable_nat|ebtables|edac_core|ext4|fb_sys_fops|floppy|fuse|gf128mul|ghash_clmulni_intel|glue_helper|grace|i2c_algo_bit|i2c_core|i2c_piix4|i7core_edac|intel_powerclamp|ioatdma|ip_set|ip_tables|ip6_tables|ip6t_REJECT|ip6t_rpfilter|ip6table_filter|ip6table_mangle|ip6table_nat|ip6ta ble_raw|ip6table_security|ipmi_devintf|ipmi_msghandler|ipmi_si|ipmi_ssif|ipt_MASQUERADE|ipt_REJECT|iptable_filter|iptable_mangle|iptable_nat|iptable_raw|iptable_security|iTCO_vendor_support|iTCO_wdt|jbd2|joydev|kvm|kvm_intel|libahci|libata|libcrc32c|llc|lockd|lpc_ich|lrw|mbcache|megaraid_sas|mfd_core|mgag200|Module|mptbase|mptscsih|mptspi|nf_conntrack|nf_conntrack_ipv4|nf_conntrack_ipv6|nf_defrag_ipv4|nf_defrag_ipv6|nf_nat|nf_nat_ipv4|nf_nat_ipv6|nf_nat_masquerade_ipv4|nfnetlink|nfnetlink_log|nfnetlink_queue|nfs_acl|nfsd|parport|parport_pc|pata_acpi|pcspkr|ppdev|rfkill|sch_fq_codel|scsi_transport_spi|sd_mod|serio_raw|sg|shpchp|snd|snd_ac97_codec|snd_ens1371|snd_page_alloc|snd_pcm|snd_rawmidi|snd_seq|snd_seq_device|snd_seq_midi|snd_seq_midi_event|snd_timer|soundcore|sr_mod|stp|sunrpc|syscopyarea|sysfillrect|sysimgblt|tcp_lp|ttm|tun|uvcvideo|videobuf2_core|videobuf2_memops|videobuf2_vmalloc|videodev|virtio|virtio_balloon|virtio_console|virtio_net|virtio_pci|virtio_ring|virtio_scsi|vmhgfs|vmw_balloon|vmw_vmci|vmw_vsock_vmci_transport|vmware_balloon|vmwgfx|vsock|xfs|xt_CHECKSUM|xt_conntrack|xt_state|raid*|tcpbbr|btrfs|.*diag|psmouse|ufs|linear|msdos|cpuid|veth|xt_tcpudp|xfrm_user|xfrm_algo|xt_addrtype|br_netfilter|input_leds|sch_fq|ib_iser|rdma_cm|iw_cm|ib_cm|ib_core|.*scsi.*|tcp_bbr|pcbc|autofs4|multipath|hfs.*|minix|ntfs|vfat|jfs|usbcore|usb_common|ehci_hcd|uhci_hcd|ecb|crc32c_generic|button|hid|usbhid|evdev|hid_generic|overlay|xt_nat|qnx4|sb_edac|acpi_cpufreq|ixgbe|pf_ring|tcp_htcp|cfg80211|x86_pkg_temp_thermal|mei_me|mei|processor|thermal_sys|lp|enclosure|ses|ehci_pci|igb|i2c_i801|pps_core|isofs|nls_utf8|xt_REDIRECT|xt_multiport|iosf_mbi|qxl|cdc_ether|usbnet|ip6table_raw|skx_edac|intel_rapl|wmi|acpi_pad|ast|i40e|ptp|nfit|libnvdimm|bpfilter|failover" 
}
file_check() {
  echo -e "############ 文件检查 ############\n"
  echo -e "\e[00;31m[+]系统文件修改时间 \e[00m"
  cmdline=(
    "/sbin/ifconfig"
    "/bin/ls"
    "/bin/login"
    "/bin/netstat"
    "/bin/top"
    "/bin/ps"
    "/bin/find"
    "/bin/grep"
    "/etc/passwd"
    "/etc/shadow"
    "/usr/bin/curl"
    "/usr/bin/wget"
    "/root/.ssh/authorized_keys"
  )
for soft in "${cmdline[@]}"; do
    echo -e "文件:$soft\t\t\t修改日期：$(stat $soft | ag -o '(?<=Modify: )[\d-\s:]+')"
  done
}
crontab_check() {
  echo -e "############ 任务计划检查 ############\n"
  crontab -u root -l | grep -v '#' --color
  ls -alht /etc/cron.*/* 
  #crontab可疑命令
  echo -e "\e[00;31m[+]Crontab Backdoor \e[00m" 
  grep -r '((?:useradd|groupadd|chattr)|(?:wget\s|curl\s|tftp\s\-i|scp\s|sftp\s)|(?:bash\s\-i|fsockopen|nc\s\-e|sh\s\-i|\"/bin/sh\"|\"/bin/bash\"))' /etc/cron* /var/spool/cron/* --color
}

ssh_check() {
  echo -e "############ SSH检查 ############\n"
OS='None'

if [ -e "/etc/os-release" ]; then
  source /etc/os-release
  case ${ID} in
  "debian" | "ubuntu" | "devuan")
    OS='Debian'
    ;;
  "centos" | "rhel fedora" | "rhel")
    OS='Centos'
    ;;
  *) ;;
  esac
fi

  if [ $OS = 'Centos' ]; then
    grep -a 'authentication failure' /var/log/secure* | awk '{print $14}' | awk -F '=' '{print $2}' | grep '\d+\.\d+\.\d+\.\d+' | sort | uniq -c | sort -nr | head -n 25
  else
    grep -a 'authentication failure' /var/log/auth.* | awk '{print $14}' | awk -F '=' '{print $2}' | grep '\d+\.\d+\.\d+\.\d+' | sort | uniq -c | sort -nr | head -n 25
  fi
  #SSHD
  echo -e "/usr/sbin/sshd"
  stat /usr/sbin/sshd | grep 'Access|Modify|Change' --color 

 if ps -ef | grep '\s+\-oport=\d+' >/dev/null 2>&1; then

    ps -ef | grep '\s+\-oport=\d+'
  else
    echo "未检测到SSH软连接后门" 

  fi
  echo -e "\e[00;31m[+]SSH inetd后门检查 \e[00m"
  if [ -e "/etc/inetd.conf" ]; then
    grep -E '(bash -i)' </etc/inetd.conf 
  fi
  echo -e "\e[00;31m[+]SSH key\e[00m" 
  sshkey=${HOME}/.ssh/authorized_keys
  if [ -e "${sshkey}" ]; then
    # shellcheck disable=SC2002
    cat ${sshkey} 
  else
    echo -e "SSH key文件不存在\n"
  fi
}

miner_check() {
  echo -e "############ 挖矿木马检查 ############\n" 
  echo -e "\e[00;31m[+]常规挖矿进程检测\e[00m" 
  ps aux | grep "systemctI|kworkerds|init10.cfg|wl.conf|crond64|watchbog|sustse|donate|proxkekman|test.conf|/var/tmp/apple|/var/tmp/big|/var/tmp/small|/var/tmp/cat|/var/tmp/dog|/var/tmp/mysql|/var/tmp/sishen|ubyx|cpu.c|tes.conf|psping|/var/tmp/java-c|pscf|cryptonight|sustes|xmrig|xmr-stak|suppoie|ririg|/var/tmp/ntpd|/var/tmp/ntp|/var/tmp/qq|/tmp/qq|/var/tmp/aa|gg1.conf|hh1.conf|apaqi|dajiba|/var/tmp/look|/var/tmp/nginx|dd1.conf|kkk1.conf|ttt1.conf|ooo1.conf|ppp1.conf|lll1.conf|yyy1.conf|1111.conf|2221.conf|dk1.conf|kd1.conf|mao1.conf|YB1.conf|2Ri1.conf|3Gu1.conf|crant|nicehash|linuxs|linuxl|Linux|crawler.weibo|stratum|gpg-daemon|jobs.flu.cc|cranberry|start.sh|watch.sh|krun.sh|killTop.sh|cpuminer|/60009|ssh_deny.sh|clean.sh|\./over|mrx1|redisscan|ebscan|barad_agent|\.sr0|clay|udevs|\.sshd|/tmp/init|xmr|xig|ddgs|minerd|hashvault|geqn|\.kthreadd|httpdz|pastebin.com|sobot.com|kerbero|2t3ik|ddgs|qW3xt|ztctb" | grep -v 'grep'
  find / ! -path "/proc/*" ! -path "/sys/*" ! -path "/run/*" ! -path "/boot/*" -regextype posix-extended -regex '.*systemctI|.*kworkerds|.*init10.cfg|.*wl.conf|.*crond64|.*watchbog|.*sustse|.*donate|.*proxkekman|.*cryptonight|.*sustes|.*xmrig|.*xmr-stak|.*suppoie|.*ririg|gg1.conf|.*cpuminer|.*xmr|.*xig|.*ddgs|.*minerd|.*hashvault|\.kthreadd|.*httpdz|.*kerbero|.*2t3ik|.*qW3xt|.*ztctb|.*miner.sh' -type f 
  echo -e "\e[00;31m[+]Ntpclient 挖矿木马检测\e[00m" 
  find / ! -path "/proc/*" ! -path "/sys/*" ! -path "/boot/*" -regextype posix-extended -regex 'ntpclient|Mozz'
  ls -alh /tmp/.a /var/tmp/.a /run/shm/a /dev/.a /dev/shm/.a 2>/dev/null
  echo -e "\e[00;31m[+]WorkMiner 挖矿木马检测\e[00m" 
  ps aux | grep "work32|work64|/tmp/secure.sh|/tmp/auth.sh" | grep -v 'grep'
  ls -alh /tmp/xmr /tmp/config.json /tmp/secure.sh /tmp/auth.sh /usr/.work/work64 2>/dev/null
}
main_check(){
miner_check
ssh_check
crontab_check
file_check
system_check
}
main_check | tee /home/check_process-$(date +\%Y-\%m-\%d).log


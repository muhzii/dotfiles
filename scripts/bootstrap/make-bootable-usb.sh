#!/bin/bash -xue

if [[ $# -ne 2 ]]; then
    echo "usage: ${0} <iso_path> <device>" && exit 1
fi

iso_path=$1
dev=$2

ls $iso_path >/dev/null
ls $dev >/dev/null

if ! echo "$(basename $iso_path)"|grep archlinux-|grep .iso >/dev/null; then
    echo "Invalid file name for ArchLinux ISO image." && exit 1
fi

iso_sz=$(ls -al --block-size=M "$iso_path" 2>/dev/null|awk '{print $5}')
iso_sz=${iso_sz%M}

function find_free_space () {
    while IFS= read -r line; do
        size=$(echo $line|awk '{print $3}')
        size=${size%MiB}
        threshold=$((iso_sz+128))
        if (( $(echo "$size > $threshold"|bc -l) )); then
            _start=$(echo $line|awk '{print $1}')
            _start=${_start%MiB}
            _start=${_start%.*}
            _start=$((_start+1))
            echo $_start
            return
        fi
    done <<< $(sudo parted $dev unit MiB print free|grep "Free Space")
}

if ! sudo parted $dev print|grep "Partition Table:"|grep gpt >/dev/null; then
    read -p "Device must have a GPT partition table. Format? (WARNING: this will destroy all present data). " yn
    case $yn in
        [Yy]*)
            sudo parted $dev -s mklabel gpt
            ;;
        [Nn]*)
            echo "Terminating.."
            exit 0
            ;;
        *)
            echo "Invalid choice" && exit 1
    esac
fi

esp=$(sudo parted $dev unit MB print|grep esp || true)
if [ "$esp" != "" ]; then
    esp_ptnum=$(echo $esp|awk '{print $1}')
    sudo parted $dev rm $esp_ptnum
fi

free_start=$(find_free_space)
if [ "$free_start" == "" ]; then
    echo "No free space available on disk." && exit 1
fi
free_end=$((${free_start}+${iso_sz}+128))
sudo parted $dev -s mkpart primary fat32 ${free_start}MiB ${free_end}MiB || true

ptnum=$(sudo parted $dev unit MiB print|sed 's/\.00//g'|grep ${free_start}MiB)
ptnum=$(echo $ptnum|awk '{print $1 " " $2}'|grep ${free_start}MiB|awk '{print $1}')
sudo parted $dev set $ptnum esp on
sudo parted $dev set $ptnum boot on

ptdev=${dev}${ptnum}
sudo mkfs.fat -F32 $ptdev
sudo umount /mnt >/dev/null || true
sudo mount $ptdev /mnt
sudo bsdtar -x --exclude=syslinux/ -f $iso_path -C /mnt
sudo umount /mnt

yymm=$(basename $iso_path)
yymm=${yymm#archlinux-}
yymm=${yymm%.iso}
yymm=${yymm%.*}
yymm=$(echo $yymm|tr -d .)
sudo fatlabel $ptdev ARCH_${yymm}

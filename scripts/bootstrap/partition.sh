#!/bin/bash -ue

function num_pts() {
    ret=$(parted $dev print|tail -2|awk '{print $1}')
    if [ $ret == "Number" ]; then
        echo 0
    else
        echo $ret
    fi
}

function cleanup() {
    # Cleanup mounts, logical partitions, LUKS partition..
    umount -l /mnt/home &>/dev/null || true
    umount -l /mnt &>/dev/null || true
    swapoff /dev/main_vol_grp/swap &>/dev/null || true
    lvm vgremove -y main_vol_grp &>/dev/null || true
    pvremove /dev/mapper/cryptlvm &>/dev/null || true
    cryptsetup close cryptlvm &>/dev/null || true
}

read -p "Specify disk name to be partitioned: " dev
if ! fdisk -l|grep "^Disk /dev/.*"|grep "$dev:" >/dev/null; then
    echo "Invalid disk device name" && exit 1
fi

parted $dev print free
read -p "Remove all existing partitions?" yn
case $yn in
    [Yy]*)
        cleanup
        n=$(num_pts)
        test $n -ge 1 && for i in $(seq 1 $n); do
            parted $dev rm $i &>/dev/null
        done
        ;;
    [Nn]*)
        ;;
    *)
        echo "Invalid choice" && exit 1
esac

if ! parted $dev print|grep "EFI system"; then
    # TODO: support EFI/ boot partition resizing
    parted $dev mkpart primary fat32 1MiB 1025MiB &>/dev/null
    n=$(num_pts)
    parted $dev set $n esp on &>/dev/null
    parted $dev name $n '"EFI system partition"' &>/dev/null
fi

install_pt_num=None
i=$(num_pts)
while true; do
    parted $dev unit MiB print free
    read -p "Create a new raw partition?" yn
    case $yn in
        [Yy]*)
            ;;
        [Nn]*)
            break
            ;;
        *)
            echo "Invalid choice"
            continue
    esac
    i=$((i+1))
    read -p "Use as the installation partition?" yn
    case $yn in
        [Yy]*)
            install_pt_num=$i
            ;;
        [Nn]*)
            ;;
        *)
            i=$((i-1))
            echo "Invalid choice"
            continue
    esac
    read -p "Enter partition size (in MiB or percentage): " size
    end=''
    last_end=$(parted $dev unit MiB print|tail -2|awk '{print $3}')
    case "$size" in
        *%*)
            end=$size
            ;;
        ''|*[!0-9]+)
            echo "Invalid size"
            continue
            ;;
        *)
            end=$((last_end+size))MiB
            ;;
    esac
    if ! parted $dev mkpart primary ${last_end}MiB ${end} &>/dev/null; then
        echo "Failed to create partition"
        continue
    fi
done

if [ $install_pt_num == "None" ]; then
    parted $dev print free
    read -p "Select installation partition: " install_pt_num
fi

echo "Setting up LUKS on selected partition.."
crypt_dev=${dev}p${install_pt_num}
cryptsetup luksFormat ${crypt_dev}
cryptsetup open ${crypt_dev} cryptlvm

echo "Setting up LVM on LUKS partition..."
pvcreate /dev/mapper/cryptlvm
vgcreate main_vol_grp /dev/mapper/cryptlvm

swap_sz=$(free -h|grep Mem:|awk '{print $2}'|rev|cut -c3-|rev)
swap_sz=$(echo $swap_sz|awk '{print sqrt($1)}'|xargs -I {} printf "%.0f\n" {})
lvcreate -L ${swap_sz}G main_vol_grp -n swap

# TODO: impose limits
read -p "Specify Root partition Size (in G): " root_sz
lvcreate -L ${root_sz}G main_vol_grp -n root
lvcreate -l 100%FREE main_vol_grp -n home

mkfs.ext4 /dev/main_vol_grp/root
mkfs.ext4 /dev/main_vol_grp/home
mkswap /dev/main_vol_grp/swap
mkfs.fat -F32 ${dev}p1

mount /dev/main_vol_grp/root /mnt
mount --mkdir /dev/main_vol_grp/home /mnt/home
mount --mkdir ${dev}p1 /mnt/boot
swapon /dev/main_vol_grp/swap


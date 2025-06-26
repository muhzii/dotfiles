#!/bin/bash -ue

is_intel=0
if lscpu|grep Vendor|grep Intel >/dev/null; then
    is_intel=1
fi

# Update fstab entries.
genfstab -U /mnt > /mnt/etc/fstab

echo "Configuring timezone and locale settings..."
ln -sf /usr/share/zoneinfo/Egypt /mnt/etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

echo "Setting root user password..."
arch-chroot /mnt passwd

# Configuring hostname.
read -p "Enter hostname: " hostname
echo $hostname > /mnt/etc/hostname

echo "Setting up main system user..."
read -p "Enter username: " username
arch-chroot /mnt useradd -m $username || true
arch-chroot /mnt passwd $username

arch-chroot /mnt usermod -aG wheel,audio,video,storage $username || true

user_sudo_allow="$username ALL=(ALL) ALL"
if ! cat /mnt/etc/sudoers|grep "$user_sudo_allow" &>/dev/null; then
    echo $user_sudo_allow >> /mnt/etc/sudoers
fi

echo "Generating initramfs..."
initramfs_modules=""
function add_initramfs_module() {
    if [ ! -z "$initramfs_modules" ]; then
        initramfs_modules+=" "
    fi
    initramfs_modules+="$1"
}

is_surface_pro=0
if dmesg|grep "Surface Pro" >/dev/null; then
    is_surface_pro=1
fi

if [ $is_surface_pro -eq 1 ]; then
    add_initramfs_module 8250_dw
    add_initramfs_module i915
    add_initramfs_module surface_aggregator
    add_initramfs_module surface_aggregator_registry
    add_initramfs_module surface_aggregator_hub
    add_initramfs_module surface_hid_core
    add_initramfs_module surface_hid
    if [ $is_intel -eq 1 ]; then
        add_initramfs_module intel_lpss
        add_initramfs_module intel_lpss_pci
    else
        add_initramfs_module pinctrl_amd
    fi
fi
sed -i "s/^MODULES=.*/MODULES=($initramfs_modules)/g" /mnt/etc/mkinitcpio.conf

initramfs_hooks=""
function add_initramfs_hook() {
    if [ ! -z "$initramfs_hooks" ]; then
        initramfs_hooks+=" "
    fi
    initramfs_hooks+="$1"
}

add_initramfs_hook base
add_initramfs_hook udev
add_initramfs_hook keyboard
add_initramfs_hook keymap
add_initramfs_hook autodetect
add_initramfs_hook modconf
add_initramfs_hook block
add_initramfs_hook filesystems
add_initramfs_hook encrypt
add_initramfs_hook lvm2
add_initramfs_hook fsck
sed -i "s/^HOOKS=.*/HOOKS=($initramfs_hooks)/g" /mnt/etc/mkinitcpio.conf

arch-chroot /mnt mkinitcpio -P

# Generate EFI bundle.
echo "Generating EFI bundle..."

pacman -Sy --noconfirm sbctl

crypt_dev=$(cryptsetup status cryptlvm|grep device|awk '{print $2}')
crypt_uuid=$(blkid|grep $crypt_dev|awk '{print $2}'|tr -d '"')
echo "BOOT_IMAGE=/vmlinuz-linux rw loglevel=3 quiet cryptdevice=$crypt_uuid:cryptlvm root=/dev/mapper/main_vol_grp-root" \
    > /etc/kernel/cmdline
cp /etc/kernel/cmdline /mnt/etc/kernel/cmdline

# Dirty hack we resort to as sbctl cannot be run in arch-chroot env.
if [ $(head -c 11 /usr/bin/lsblk|tr -d '\0') != "#!/bin/bash" ]; then
    mv /usr/bin/lsblk /usr/bin/lsblk-real
    echo "#!/bin/bash" > /usr/bin/lsblk
    echo '/usr/bin/lsblk-real $@|sed "s/\/mnt//g"' >> /usr/bin/lsblk
    chmod +x /usr/bin/lsblk
fi

ucode_name="amd-ucode"
if [ $is_intel -eq 1 ]; then
    ucode_name="intel-ucode"
fi

mkdir -p /mnt/var/tmp && mount --bind /mnt/var/tmp /var/tmp
mkdir -p /mnt/boot/EFI/ArchLinux

if [ $is_surface_pro -eq 1 ]; then
    sbctl bundle -s -i /mnt/boot/$ucode_name.img \
        -l /mnt/usr/share/systemd/bootctl/splash-arch.bmp \
        -k /mnt/boot/vmlinuz-linux-surface \
        -f /mnt/boot/initramfs-linux-surface.img \
        /mnt/boot/EFI/ArchLinux/arch-linux.efi
else
    sbctl bundle -s -i /mnt/boot/$ucode_name.img \
        -l /mnt/usr/share/systemd/bootctl/splash-arch.bmp \
        -k /mnt/boot/vmlinuz-linux \
        -f /mnt/boot/initramfs-linux.img \
        /mnt/boot/EFI/ArchLinux/arch-linux.efi
fi

umount /var/tmp
sed -i 's/\/mnt//g' /usr/share/secureboot/bundles.db
mkdir -p /mnt/user/share/secureboot
mv /usr/share/secureboot/bundles.db /mnt/usr/share/secureboot

while true; do
    if efibootmgr -v|grep ArchLinux >/dev/null; then
        bootnum=$(efibootmgr -v|grep ArchLinux|tail -1|awk '{print $1}')
        bootnum=${bootnum%\*}
        bootnum=${bootnum#Boot}
        efibootmgr -B -b $bootnum
    else
        break
    fi
done

echo "Adding entry to EFI boot manager..."
read -p "Enter device name to use for UEFI boot entry: " dev
esp_dev=$(fdisk -l $dev|grep 'EFI System'|awk '{print $1}')
esp_part=${esp_dev#/dev/}
esp_disk=$(readlink /sys/class/block/$esp_part)
esp_disk=${esp_disk%/*}
esp_disk=/dev/${esp_disk##*/}
efibootmgr -c -d $esp_disk -p ${esp_part##*p} -L ArchLinux -l EFI/ArchLinux/arch-linux.efi

if efibootmgr -v|grep Windows >/dev/null; then
    read -p "Delete Windows EFI entry?" yn
    case $yn in
        [Nn]*)
            ;;
        [Yy]*)
            bootnum=$(efibootmgr -v|grep Windows|tail -1|awk '{print $1}')
            bootnum=${bootnum%\*}
            bootnum=${bootnum#Boot}
            efibootmgr -B -b $bootnum
            ;;
        *)
            echo "Invalid choice" && exit 1
    esac
fi

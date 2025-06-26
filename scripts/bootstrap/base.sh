#!/bin/bash -ue

pacman -Sy --noconfirm archlinux-keyring

ucode_name="amd-ucode"
if lscpu|grep Vendor|grep Intel >/dev/null; then
    ucode_name="intel-ucode"
fi

pacstrap /mnt base linux-firmware xorg plasma curl lvm2 \
    kde-applications $ucode_name vim fakeroot make git sbctl

# Enable services
arch-chroot /mnt systemctl enable sddm.service
arch-chroot /mnt systemctl enable NetworkManager.service

if dmesg|grep "Surface Pro" >/dev/null; then
    arch-chroot /mnt bash -c "curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc|pacman-key --add -"

    arch-chroot /mnt pacman-key --finger 56C464BAAC421453
    arch-chroot /mnt pacman-key --lsign-key 56C464BAAC421453

    cat >> /mnt/etc/pacman.conf <<EOF
[linux-surface]
Server = https://pkg.surfacelinux.com/arch/
EOF

    arch-chroot /mnt pacman -Syu --noconfirm
    arch-chroot /mnt pacman -Sy --noconfirm linux-surface linux-surface-headers
else
    arch-chroot /mnt pacman -Sy --nconfirm linux linux-headers
fi

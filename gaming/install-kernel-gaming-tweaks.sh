#!/usr/bin/env bash
set -e
if grep -q "vsyscall=emulate" /etc/default/grub; then
    echo "GRUB vsyscall fix already present."
else
    sudo sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"|GRUB_CMDLINE_LINUX_DEFAULT="\1 vsyscall=emulate split_lock_detect=off"|g' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

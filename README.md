# chroot_rootfs
a bash script to chroot to a rootfs/*img with Network setup, make it easy to use APT and modifiy rootfs.



# usage
## same architecture
```
sudo ./chroot_rootfs.sh rootfs
sudo ./chroot_rootfs.sh rootfs.img
```

## foreign architecture
if you want to chroot to a foreign filesystem, install qemu-user-static. 
For Ubuntu/Debian, you can use:  `apt-get install qemu qemu-user-static binfmt-support`

```
sudo ./chroot_rootfs.sh arm_rootfs arm
sudo ./chroot_rootfs.sh aarch64_rootfs.img aarch64
```

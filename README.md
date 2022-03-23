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


In case running out of space for the partition on the disk image. We may need to add space to the disk image and expand the rootfs partition. 

### Resizing partition
`qemu-img resize rootfs.img +1024M`

or

`sudo dd if=/dev/zero bs=1M count=1024 >> rootfs.img`
### Expand the filesystem
use Ubuntu Disk Utility, GParted, or parted to expand the filesystem

[RaspberryPi qemu-user-static](https://wiki.debian.org/RaspberryPi/qemu-user-static)

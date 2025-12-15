# Setup postmarketos as homeserver

### for making the smartphone batterless checkout [batterless docs](./BATTERYLESS.md)

### install some esssential pacakages:
```
apk add --no-cache networkmanager netavark iptables iw ntfs-3g psutil pip py3-psutil openssh podman-compose du coreutils mediainfo openssh nfs-utils rsync curl libstdc++ py3-pip vips-tools vips vips-dev python3-dev build-base mesa-utils transmission-daemon
```

```
curl -LO https://github.com/tribhuwan-kumar/pmos/archive/refs/heads/main.zip
unzip main.zip
cd main
```

> [!NOTE]
> remember to modify service files as you need, before running

### setup udiskie for automounting of drive:
```bash
# run as your preferred user
apk add --no-cache udiskie
cp ./systemd/system/aria2.service /etc/systemd/system/aria2.service
systemctl enable --now udiskie.service
systemctl start udiskie.service
```


### disable wifi powersave:
```bash
# run as your preferred user
apk add --no-cache netavark iptables iw
cp ./pmos/systemd/system/wifi-nosave.service /etc/systemd/system/wifi-nosave.service
systemctl enable --now wifi-nosave.service
systemctl start wifi-nosave.service
```

### setup aria2:
```bash
# download frontend for aria2
curl -LO https://github.com/mayswind/AriaNg/releases/download/1.3.12/AriaNg-1.3.12-AllInOne.zip
curl -LO https://github.com/sigoden/dufs/releases/download/v0.45.0/dufs-v0.45.0-aarch64-unknown-linux-musl.tar.gz
mkdir /usr/local/bin
tar -xvf dufs-v0.45.0-aarch64-unknown-linux-musl.tar.gz -C /usr/local/bin
unzip AriaNg-1.3.12-AllInOne.zip -d /usr/local/bin
apk add --no-cache aria2
cp ./systemd/system/aria2.service /etc/systemd/system/aria2.service
systemctl start aria2.service
```

### setup transmission bittorent client with flood ui:
```bash
apk add transmission-daemon
curl -Lo /usr/local/bin/flood-linux-arm64 https://github.com/jesec/flood/releases/download/v4.11.0/flood-linux-arm64
cp ./systemd/system/transmission.service /etc/systemd/system/transmission.service
systemctl start transmission.service
```

### unlock cryptomator vault:
```bash
# first check if the /dev/fuse exists
ls -lah /dev/fuse
apk add podman podman-compose podman-compose-pyc
cp ./systemd/system/cryptomator.service /etc/systemd/system/cryptomator.service
systemctl start cryptomator.service
# check if the cryptomator conatiner is running
podman ps -a
# list mounters
podman exec -it cryptomator cryptomator-cli list-mounters
# select the desired mounter then mount it
read -s -p "Pass: " P && echo "$P" | sudo podman exec -i -d cryptomator cryptomator-cli unlock /vault --mountPoint=/mount --mounter=org.cryptomator.frontend.fuse.mount.LinuxFuseMountProvider --password:stdin && unset P
```

### setup copyparty
```bash
curl -LO https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py /usr/local/bin
# for thumbnails preview
python3 -m pip install pyvips --break-system-packages
cp ./systemd/system/copyparty.service /etc/systemd/system/copyparty.service
systemctl start copyparty.service
```

### setup jackett indexer
```bash
cp ./systemd/system/jackett.service /etc/systemd/system/jackett.service
systemctl start copyparty.service
```

### setup radarr
```bash
cp ./systemd/system/radarr.service /etc/systemd/system/radarr.service
systemctl start radarr.service
```

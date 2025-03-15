# CarOps
Repository containing scripts that runs on the car controller - Raspberry Pi

## Prerequisities
- Raspberry Pi 4 is required
- Ubuntu 22.04 is currently only supported version
- ROS2 Humble is currently only supported version

## Base setup

### System setup
- Update the system using `sudo apt update && sudo apt upgrade`
```bash
sudo mkdir /reco
sudo mkdir /reco/run
sudo mkdir /reco/log
sudo chown -R ubuntu:ubuntu /reco
```

### SSH Setup (GitHub)
- Copy the SSH key pair to the Raspberry Pi /home/ubuntu/.ssh/
- Add the SSH key to the ssh-agent

```bash
eval "$(ssh-agent -s)"
~/.ssh/id_ed25519
```

- Setup git credentials

```bash
git config --global user.email "recoteamfiit@gmail.com"
git config --global user.name "ReCo"
```

- Setup permissions
```bash
sudo chmod 600 ~/.ssh/id_ed25519
sudo chmod 600 ~/.ssh/id_ed25519.pub
```

### Repository Clone
- Go to home directory using `cd ~`
- Clone this repository using `git clone git@github.com:ReCoFIIT/car-ops.git`


### User Setup

```bash
sudo groupadd usbmount
sudo usermod -aG usbmount $USER
sudo usermod -aG dialout $USER
sudo usermod -aG tty $USER
```

- Add following lines to `/etc/sudoers` file

```bash
%usbmount ALL=(ALL) NOPASSWD: /usr/bin/systemd-mount
%usbmount ALL=(ALL) NOPASSWD: /usr/bin/systemd-umount
```

- Reboot the system


### Sentry Setup
- Use script `init_sentry,sh`, setting up permissions for execute might be required.

```bash
sudo chmod +x ~/car-ops/init_sentry.sh
sudo ~/car-ops/init_sentry.sh 
```

### Config Scripts

Scripts should be located in `/usr/local/bin`

`mount_reco_config.sh` - contains script to automount flash_drive RECO_CONFIG
`logger.sh` - contains logging script

```bash
sudo cp ~/car-ops/mount_reco_config.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/mount_reco_config.sh 
```

```bash
sudo cp ~/car-ops/logger.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/logger.sh
```

### UDEV Rules

Udev rules should be located in `/etc/udev/rules.d`

- `99-reco-config.rules` - contains udev rules to automount flash_drive 

```bash
sudo cp ~/car-ops/99-reco-config.rules /etc/udev/rules.d/
```

- `99-reco-config-unmount.rules` - contains udev rules to unmount flash_drive RECO_CONFIG

```bash
sudo cp ~/car-ops/99-reco-config-unmount.rules /etc/udev/rules.d/
```

- `99-serial.rules` - contains udev rules to set permissions for serial devices

```bash
sudo cp ~/car-ops/99-serial.rules /etc/udev/rules.d/
```

#### UDEV Rules Installation

- Copy the udev rules to /etc/udev/rules.d/
- Reload the rules 

```bash
 sudo udevadm control --reload-rules && sudo udevadm trigger
```

### Python Setup

- Install pip3
- Install pypyr and sentry-sdk

```bash
sudo apt install python3-pip -y
sudo pip3 install pypyr
sudo pip3 install sentry-sdk
```

### Systemd setup

Copy the service files to `/etc/systemd/system/`

```bash
sudo cp ~/car-ops/systemd/* /etc/systemd/system
```

Restart the systemd daemon

```bash
sudo systemctl daemon-reload
```

Enable the services

```bash
sudo systemctl enable reco-run.service
sudo systemctl enable reco_config_monitor.path
sudo systemctl enable reco_config_monitor.service
```

### Setup ROS2

[Installation Guide](https://github.com/ReCoFIIT/ros2_ws/blob/master/README.md)

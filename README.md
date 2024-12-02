# CarOps
Repository containing scripts that runs on the car controller - Raspberry Pi

### SSH Setup (GitHub)
- Copy the SSH key pair to the Raspberry Pi /home/ubuntu/.ssh/
- Add the SSH key to the ssh-agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

### Config Scripts

`mount_reco_config.sh` - contains script to automount flash_drive RECO_CONFIG

### UDEV Rules

`99-reco-config.rules` - contains udev rules to automount flash_drive RECO_CONFIG
`99-reco-config-unmount.rules` - contains udev rules to unmount flash_drive RECO_CONFIG

#### UDEV Rules Installation

- Copy the udev rules to /etc/udev/rules.d/
- Reload the rules 

```bash
 sudo udevadm control --reload-rules && udevadm trigger
```
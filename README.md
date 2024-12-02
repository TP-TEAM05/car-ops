# CarOps
Repository containing scripts that runs on the car controller - Raspberry Pi

## Base setup

### SSH Setup (GitHub)
- Copy the SSH key pair to the Raspberry Pi /home/ubuntu/.ssh/
- Add the SSH key to the ssh-agent

```bash
eval "$(ssh-agent -s)"
~/.ssh/id_ed25519
```

- Setup permissions
```bash
sudo chmod 600 ~/.ssh/id_ed25519
sudo chmod 600 ~/.ssh/id_ed25519.pub
```

### Repository Clone
- Go to home directory using `cd ~`
- Clone this repository using `git clone git@github.com:ReCoFIIT/car-ops.git`


### Sentry Setup
- Use script `init_sentry,sh`, setting up permissions for execute might be required

### Config Scripts

Scripts should be located in `/usr/local/bin`

`mount_reco_config.sh` - contains script to automount flash_drive RECO_CONFIG
`logger.sh` - contains logging script - 

### UDEV Rules

- `99-reco-config.rules` - contains udev rules to automount flash_drive 

- `99-reco-config-unmount.rules` - contains udev rules to unmount flash_drive RECO_CONFIG

#### UDEV Rules Installation

- Copy the udev rules to /etc/udev/rules.d/
- Reload the rules 

```bash
 sudo udevadm control --reload-rules && udevadm trigger
```

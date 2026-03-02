# Installation with disko

### Preparation

```sh
sudo -i
# add 'nix.settings.experimental-features = [ "nix-command" "flakes" ];'
vi /etc/nixos/configuration.nix
nixos-rebuild test
nix shell nixpkgs#git
git clone https://github.com/f0rdprefect/nixos-config
cd nixos-config
```
### Nixos Anywhere Install

nix run github:nix-community/nixos-anywhere -- --flake .#<output> --target-host root@nixos -i <sshkey> --generate-hardware-config nixos-facter <path-to-in-config>/facter.json

### Semi Manual Install

#### Partitioning

```sh
nix run github:nix-community/disko -- -m disko modules/disko/btrfs-luks.nix --arg disk '"/dev/nvme0n1"'
mount | grep /mnt
```

#### Install

```sh
nixos-generate-config --show-hardware-config > <your hardware.nix>
# edit mount starting with /mnt and remove /mnt.
# All other mount points can be removed
nixos-install --flake .#<host>
```

### Post-install

#### rbw

```
rbw config set email <email>
rbw config set base_url <url>
rbw login
```

#### ydotool

Hopefully merged soon...

#### fido keys (u2f)

see comments in  `fido.nix`

# Lessons learnt

Packages added to users in system section precede the ones added by homemanger.

This can lead to really hard to understand error messages during runtime.

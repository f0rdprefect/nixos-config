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

#### dotool

Hopefully merged soon...

#### fido keys

```
nix shell nixpkgs#pam_u2f
pamu2fcfg >> config/home/files/u2f_keys
```
to add a new one.

add new Products to `fido.nix`

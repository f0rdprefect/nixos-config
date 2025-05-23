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

### Partitioning

```sh
nix run github:nix-community/disko -- -m disko modules/disko/btrfs-luks.nix --arg disk '"/dev/nvme0n1"'
mount | grep /mnt
```

### Install

```sh
nixos-generate-config --show-hardware-config > <your hardware.nix>
# edit mount starting with /mnt and remove /mnt. 
# All other mount points can be removed
nixos-install --flake .#<host>
```

### Post-install

TBD

```sh
nixos-enter
mkdir /persist/secrets
mkpasswordfile /persist/secrets/root
mkpasswordfile /persist/secrets/katexochen
```

# Remaining follow-up tasks

## High priority
- [ ] Align baseline module stack across active hosts (`stylix`, `sops-nix`, `home-manager`, `nix-index`, overlays) and document intentional differences.
- [ ] Decide and enforce one hardware file naming convention (`hardware.nix` vs `hardware-configuration.nix`) for active hosts.
- [ ] Resolve the `pix` recursion evaluation issue so full `nix flake check` can pass again.

## Mid-term architecture work
- [ ] Move Home Manager to standalone `homeConfigurations` flow for independent home/system evaluations.
- [ ] Add and test a guarded PoC for `fzakaria/nixpkgs-multiverse`.

## Validation cadence
- [ ] Keep checkpoint log while continuing migration:
  - run `nix flake check --no-build` at milestone boundaries
  - run targeted active-host eval loop after each migration step

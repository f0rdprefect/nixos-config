{
  lib,
  pkgs,
  config,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.theKernel == "zfs-compatible-latest") (
  let
    isUnstableZfs = config.boot.zfs.package == pkgs.zfs_unstable;
    zfsPackageAttr = if isUnstableZfs then "zfs_unstable" else "zfs";
    zfsCompatibleKernelPackages = lib.filterAttrs (
      name: kernelPackages:
      (builtins.match "linux_[0-9]+_[0-9]+" name) != null
      && (builtins.tryEval kernelPackages).success
      && (builtins.hasAttr zfsPackageAttr kernelPackages)
      && (builtins.tryEval kernelPackages.${zfsPackageAttr}.meta.broken).success
      && !kernelPackages.${zfsPackageAttr}.meta.broken
    ) pkgs.linuxKernel.packages;
    compatibleKernelPackages = builtins.attrValues zfsCompatibleKernelPackages;
    latestKernelPackage =
      if compatibleKernelPackages == [ ] then
        throw "No ZFS-compatible linux_* kernel package found for boot.zfs.package."
      else
        lib.last (lib.sort (a: b: lib.versionOlder a.kernel.version b.kernel.version) compatibleKernelPackages);
  in
  {
    # Note: this can move forward and backward as package availability changes.
    boot.kernelPackages = latestKernelPackage;
  }
)

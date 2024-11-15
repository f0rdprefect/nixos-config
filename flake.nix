{
  description = "My NixOS config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    hyprland = {
      url = "https://github.com/hyprwm/Hyprland";
      type = "git";
      submodules = true;
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-conf = {
      #url = "github:f0rdprefect/nixvim-config";
      url = "git+file:///home/matt/src/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    stylix = {
      url = "github:danth/stylix";
    };
    espanso-fix = {
      url = "github:pitkling/nixpkgs/espanso-fix-capabilities-export";
    };
  };
  #inputs@ or {} @ inputs names the set only way to access parameters inside the function
  # https://mhwombat.codeberg.page/nix-book/#at-patterns
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      impermanence,
      nixos-hardware,
      disko,
      stylix,
      espanso-fix,
      nixvim-conf,
      nix-colors,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      host = "xin";
      inherit (import ./hosts/${host}/options.nix) username hostname;

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit hostname;
            inherit host;
            inherit nix-colors;
          };
          modules = [
            ./system.nix
            espanso-fix.nixosModules.espanso-capdacoverride
            # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga
            stylix.nixosModules.stylix
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
                inherit nixvim-conf;
                inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./users/default/home.nix;
            }
          ];
        };
      };
    };
}

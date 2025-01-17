{
  description = "My NixOS config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/release-24.11";
    };
    nixpkgs-master = {
      url = "github:nixos/nixpkgs/master";
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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-conf = {
      url = "github:f0rdprefect/nixvim-config";
      #url = "git+file:///home/matt/src/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #    disko = {
    #      url = "github:nix-community/disko";
    #      inputs.nixpkgs.follows = "nixpkgs";
    #    };
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
      nixpkgs,
      nixpkgs-master,
      nixpkgs-stable,
      home-manager,
      impermanence,
      nixos-hardware,
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
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      pkgs-master = import nixpkgs-master {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      # Make stable  packages available in the unstable configuration
      overlay-stable = final: prev: {
        stable = pkgs-stable;
      };
      # Make master packages available in the unstable configuration
      overlay-master = final: prev: {
        master = pkgs-master;
      };
    in
    {
      nixosConfigurations = {
        xin = nixpkgs.lib.nixosSystem {
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
            # Apply the overlays
            {
              nixpkgs.overlays = [
                overlay-master
                overlay-stable
              ];
            }
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
        yakari = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit hostname;
            inherit host;
            inherit nix-colors;
          };
          modules = [
            ./hosts/yakari/configuration.nix
            # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
            stylix.nixosModules.stylix
            # Apply the overlays
            {
              nixpkgs.overlays = [
                overlay-master
                overlay-stable
              ];
            }
          ];

        };
      };
    };
}

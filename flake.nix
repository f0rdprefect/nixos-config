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
    nixos-facter-modules = {
      url = "github:nix-community/nixos-facter-modules";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix/v0.4.1";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  #inputs@ or {} @ inputs gives a name to the set; only way to access parameters inside the function
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
      sops-nix,
      nix-index-database,
      raspberry-pi-nix,
      nixgl,
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
        overlays = [
          nixgl.overlay
        ];
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
            inputs.nixos-facter-modules.nixosModules.facter
            { config.facter.reportPath = ./hosts/xin/facter.json; }
            ./system.nix
            espanso-fix.nixosModules.espanso-capdacoverride
            # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga
            stylix.nixosModules.stylix
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            nix-index-database.nixosModules.nix-index
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
            inputs.nixos-facter-modules.nixosModules.facter
            { config.facter.reportPath = ./hosts/yakari/facter.json; }
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
        nix = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit hostname;
            inherit host;
            inherit nix-colors;
          };
          modules = [
            ./hosts/nix/configuration.nix
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
        pix = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            ./hosts/pix/pi4.nix
          ];
        };
      };

      homeConfigurations."matt" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit nixvim-conf;
          inherit nixgl;
          inherit inputs;
          inherit system;
        };
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          stylix.homeManagerModules.stylix
          ./users/matt/home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}

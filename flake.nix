{
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    {
      nixosModules.default = import ./module.nix;
      overlays.default = import ./overlay.nix;

      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          { config.programs.emacs-and-tools.enable = true; }
          # The iso-image module is just to get some sort of minimal
          # buildable configuration. Without it we'd have to specify
          # more parameters in the nixos config.
          (
            { modulesPath, ... }:
            {
              imports = [ "${modulesPath}/installer/cd-dvd/iso-image.nix" ];
            }
          )
        ];
      };

    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
        };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = {
          inherit (pkgs) emacs-and-tools emacs-and-tools-nox;
        };

      }
    );
}

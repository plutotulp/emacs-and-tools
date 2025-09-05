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
      inherit nixpkgs;
      
      nixosModules = {
        emacs-and-tools = import ./module.nix;
      };
      overlays = {
        emacs-and-tools = final: prev: {
          emacs-and-tools = import ./pkgs/emacs-and-tools {
            nixpkgs = prev;
          };
          emacs-and-tools-nox = import ./pkgs/emacs-and-tools {
            nixpkgs = prev;
            nox = true;
          };
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false;
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

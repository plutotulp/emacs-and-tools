{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.emacs-and-tools;
  emacs-and-tools-overlay = import ./overlay.nix;
in
{
  options.programs.emacs-and-tools = {
    enable = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Include my personal big fat emacs setup and run emacs
        as a user service.
      '';
    };
    nox = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Terminal-only (non-GUI) veriant of emacs.
      '';
    };
  };

  config = {
    nixpkgs.overlays = lib.mkIf cfg.enable [
      emacs-and-tools-overlay
    ];
    environment.systemPackages = lib.mkIf cfg.enable [
      pkgs.emacs-and-tools
    ];
    services.emacs = {
      enable = cfg.enable;
      package = pkgs.emacs-and-tools;
    };
  };
}

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
      overlays.default = import ./overlay.nix;
      nixosModules.default = import ./module.nix;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { };
          overlays = builtins.attrValues self.overlays;
        };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        apps.default =
          let
            debug-emacs = pkgs.writeShellScript "debug-emacs" ''
              ${pkgs.emacs-and-tools}/bin/emacs --debug-init
            '';
          in
          {
            type = "app";
            program = "${debug-emacs}";
            meta.description = "fat emacs (for testing with `nix run`)";
          };

        packages = {
          inherit (pkgs) emacs-and-tools emacs-and-tools-nox;
        };

        # Test that the systemd user service emacs.service starts
        # successfully on login. We're happy when we can get the emacs
        # version by running elisp in emacsclient.
        checks.emacs-user-service-starts =
          let
            user = "alice";
            uid = 1000;
          in
          pkgs.nixosTest {

            name = "emacs-user-service-starts";

            interactive.sshBackdoor.enable = true;

            nodes = {
              machine =
                { config, pkgs, ... }:
                {
                  imports = [ self.nixosModules.default ];
                  config = {
                    programs.emacs-and-tools.enable = true;
                    users.users."${user}" = {
                      isNormalUser = true;
                      inherit uid;
                    };
                    services.getty.autologinUser = "${user}";
                  };
                };
            };

            testScript = ''
              start_all()
              machine.wait_for_unit("multi-user.target")
              machine.wait_for_unit("user@${builtins.toString uid}.service")
              machine.wait_for_unit("emacs.service", user="${user}")
              machine.succeed("su --login ${user} --command 'emacsclient --socket /run/user/${builtins.toString uid}/emacs/server --eval \"(emacs-version)\"'")
            '';

          };

      }
    ); # end flake-utils.lib.eachDefaultSystem
}

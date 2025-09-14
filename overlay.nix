final: prev: {

  # These two are emacs with a collection of emacs packages and a base
  # configuration.

  emacs-and-packages = prev.callPackage ./pkgs/emacs-and-tools/emacs.nix {
    emacsWithPackages = (prev.emacsPackagesFor prev.emacs).emacsWithPackages;
  };
  emacs-and-packages-nox = prev.callPackage ./pkgs/emacs-and-tools/emacs.nix {
    emacsWithPackages = (prev.emacsPackagesFor prev.emacs-nox).emacsWithPackages;
  };

  # These two are the above emacs-and-packages and in addition a
  # collection of nixpkgs packages.

  emacs-and-tools = import ./pkgs/emacs-and-tools {
    pkgs = prev;
    inherit (prev) lib buildEnv;
    inherit (final) emacs-and-packages;
  };
  emacs-and-tools-nox = import ./pkgs/emacs-and-tools {
    pkgs = prev;
    inherit (prev) lib buildEnv;
    emacs-and-packages = final.emacs-and-packages-nox;
  };
}

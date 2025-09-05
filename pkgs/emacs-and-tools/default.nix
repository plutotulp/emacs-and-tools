# Create environment wih emacs and (hopefully) all utilities and
# compilers referenced by my emacs packages list (in ./emacs.nix) and
# configuration (in ./default.el).

{
  nixpkgs,
  nox ? false,
}:

let

  name = "emacs-and-tools-${version}";

  lib = nixpkgs.lib;

  # FIXME: Only descriptive, does not actually set the version of
  # emacs used in ./emacs.nix.
  version = emacsPaths.emacs.version;

  emacsPaths = import ./emacs.nix { inherit nixpkgs nox; };

  pkgs = with nixpkgs; [
    aspell
    aspellDicts.br
    aspellDicts.en
    aspellDicts.nb

    # dart-mode
    dart

    # dhall
    dhall
    dhall-json
    #dhall-lsp-server # 2023-09-23 marked as broken in unstable

    # elm-mode
    elmPackages.elm
    elmPackages.elm-format

    # godot game engine # 2024-12-12 gone
    #gdtoolkit

    # go-mode (w/lsp)
    go
    gopls

    # haskell-mode, though usually using some nix-shell version
    # instead
    cabal-install
    (ghc.withPackages (
      p: with p; [
        # Note that you still need SuperCollider with sc3-plugins and
        # SuperDirt in order to make music with tidal.
        tidal
      ]
    ))
    haskell-language-server
    cabal2nix
    ghcid
    hlint

    # Emacs uses its "convert" program internally for e.g. creating
    # thumbnails for image-dired.
    imagemagick

    # magit
    git

    # rust-mode, flycheck-rust, cargo
    cargo
    rustc
    rustfmt
    rust-analyzer
    clippy

    # Schemes
    racket
    # chez # 2024-06-11 marked as broken
    # chez-matchable
    # chez-scmutils

    # R-lang. Mostly for plotting with ggplot2.
    R

    # gleam
    erlang
    rebar3
    gleam

    # shell / bash
    shellcheck

    # tex / latex. Mostly for org-mode exports.
    (texlive.combine {
      inherit (texlive) scheme-full;
    })

    # helm-rg
    ripgrep

    # For org-roam (currently not enabled) and code blocks in
    # org-mode.
    sqlite

    # For Openoffice (Libreoffice) exports
    zip

    # System commands
    coreutils-full
    dool
    findutils
    gawk
    gdb
    gnugrep
    gnuplot
    gnused
    less
    # nix
    openssh
    procps
    # sudo
    unzip
  ];

  env = nixpkgs.buildEnv {
    name = name;
    paths = lib.singleton emacsPaths ++ pkgs;
  };

in
env

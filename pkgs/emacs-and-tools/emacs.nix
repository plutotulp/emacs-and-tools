{ nixpkgs, nox }:

# Builds emacs with some packages. Uses the companion file default.el
# as the init file for emacs.

let
  emacs = if nox then nixpkgs.emacs-nox else nixpkgs.emacs;
  emacsWithPackages = (nixpkgs.emacsPackagesFor emacs).emacsWithPackages;
  mkPkgs = (
    epkgs:
    let
      defaultEl = ./default.el;
      writeDefaultEl = nixpkgs.runCommand "default.el" { } ''
        mkdir -p $out/share/emacs/site-lisp
        cp ${defaultEl} $out/share/emacs/site-lisp/default.el
      '';
      melpaStablePackages = (
        with epkgs.melpaStablePackages;
        [
        ]
      );
      melpaPackages = (
        with epkgs.melpaPackages;
        [
          alchemist # Elixir tooling
          auto-complete
          cargo
          dart-mode
          dash # A modern list library for Emacs
          dhall-mode
          diminish
          docker
          dumb-jump
          elm-mode
          ess
          erlang
          evil
          flycheck
          flycheck-rust
          gdscript-mode # godot game engine
          gleam-ts-mode
          gnuplot-mode
          go-mode
          haskell-mode
          lsp-haskell
          lsp-mode
          lsp-treemacs
          lsp-ui
          magit
          markdown-mode
          modus-themes
          multi-vterm
          nix-mode
          nov # nov.el is an epub viewer
          org-download
          org-roam
          org-super-agenda
          paredit
          projectile
          racket-mode
          rust-mode
          rustic # extension of rust-mode, relevant for rust-analyzer and lsp
          solarized-theme
          terraform-mode
          tidal
          treemacs
          vterm
          window-number
          which-key
          writegood-mode
          writeroom-mode
          yaml-mode
          yasnippet
          yasnippet-snippets
          zenburn-theme
        ]
      );
      elpaPackages = (
        with epkgs.elpaPackages;
        [
          consult
          marginalia
          orderless
          org
          use-package
          vertico
        ]
      );
    in
    [ writeDefaultEl ] ++ melpaStablePackages ++ melpaPackages ++ elpaPackages
  );
in
emacsWithPackages mkPkgs

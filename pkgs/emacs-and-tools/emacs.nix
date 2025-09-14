{ emacsWithPackages, runCommand }:

# Builds emacs with some packages. Uses the companion file default.el
# as the init file for emacs.

emacsWithPackages (
  epkgs:
  [
    (runCommand "default.el" { } ''
      mkdir -p $out/share/emacs/site-lisp
      cp ${./default.el} $out/share/emacs/site-lisp/default.el
    '')
  ]
  ++ (with epkgs; [
    alchemist # Elixir tooling
    auto-complete
    cargo
    consult
    dart-mode
    dash # A modern list library for Emacs
    dhall-mode
    diminish
    docker
    dumb-jump
    elm-mode
    erlang
    ess
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
    marginalia
    markdown-mode
    meow # modal editing
    modus-themes
    multi-vterm
    nix-mode
    nov # nov.el is an epub viewer
    orderless
    org
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
    use-package
    vertico
    vterm
    which-key
    window-number
    writegood-mode
    writeroom-mode
    yaml-mode
    yasnippet
    yasnippet-snippets
    zenburn-theme

    org-present
    epresent
    dslide

  ])
)

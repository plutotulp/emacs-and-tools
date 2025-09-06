final: prev: {
  emacs-and-tools = import ./pkgs/emacs-and-tools {
    nixpkgs = prev;
  };
  emacs-and-tools-nox = import ./pkgs/emacs-and-tools {
    nixpkgs = prev;
    nox = true;
  };
}

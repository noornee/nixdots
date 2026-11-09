{ pkgs, inputs, ... }:
{
  imports = [
    ./lf
    ./zellij
    ./font.nix
    ./git.nix
    ./fastfetch.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [
    # neovim nightly (0.13-dev); stable `neovim` stays in hosts/*/configuration.nix as a fallback
    inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default

    #utils
    inetutils
    jq
    eza
    tree
    bat
    tmux
    yt-dlp
    mergiraf
    gh
    htop
    btop
    ripgrep
    ffmpeg
    p7zip
    fzf
    clipse
    tree-sitter
    lsof
    gnupg
    apacheHttpd

    # lua
    lua5_1
    lua5_1.pkgs.luarocks
    lua-language-server
    stylua

    #go
    go
    gopls
    gofumpt
    golangci-lint
    govulncheck
    gosec
    gitleaks
    gotools # includes goimports
    gomodifytags

    #nix
    nixfmt # official nix formatter
    # nix-init
    nixd
    nil
    nh

    #python
    python3
    basedpyright
    # python3.pkgs.pip

    nodejs
    pnpm
    yarn

    rustup

    typescript

    #other
    # bruno
    postman
    slack
    gnumake
    zrok
    # terraform
    witr
    aria2
    tailscale

    #ollama
    k6

    # unfree
    mongodb-compass
    ngrok
  ];
}

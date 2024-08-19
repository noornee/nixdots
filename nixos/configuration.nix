{ config, lib, pkgs, userSettings, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings = {
    # Enable Flakes and the new command-line tool
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-users = [ userSettings.username ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    # re-evaluate on every rebuild instead of "cached failure of attribute" error
    eval-cache = false;
    # warn-dirty = false;
  };

  boot.supportedFilesystems = [ "ntfs" ];
  boot.tmp.cleanOnBoot = true;
  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
    efiSupport = true;
    configurationLimit = 20;
    # useOSProber = true;
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  time.timeZone = "Africa/Lagos"; # Set your time zone.

  # rtkit is optional but recommended
  # sound.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;
  users.users.${userSettings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" ];
    shell = pkgs.zsh;
  };

  services.tumbler.enable = true; # Thumbnail support for images
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-volman ];
  };

  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System programs
  environment.systemPackages = with pkgs; [
    wget
    neovim
    git
    gcc
    file
    zip
    unzip
    unrar
    networkmanagerapplet
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];

  environment.variables = { EDITOR = "nvim"; };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # added this to be able to run pip binaries
  programs.nix-ld.enable = true;
  # Sets up all the libraries to load
  programs.nix-ld.libraries = with pkgs;
    [
      stdenv.cc.cc
      # ...
    ];

  # List services that you want to enable:
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gvfs.enable = true;
  services.openssh.enable = true;
  services.vnstat.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11";

}

{ pkgs, userSettings, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ./virt.nix ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-users = [ userSettings.username ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    eval-cache = false;
  };

  nixpkgs.config.allowUnfree = true;

  boot.supportedFilesystems = [ "ntfs" ];
  boot.tmp.cleanOnBoot = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub = {
  #   enable = true;
  #   devices = [ "nodev" ];
  #   efiSupport = true;
  #   configurationLimit = 20;
  #   useOSProber = true;
  # };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
    alsa.enable = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-volman ];
  };

  services.tumbler.enable = true; # Thumbnail support for images
  services.gvfs.enable = true;
  services.openssh.enable = true;
  services.vnstat.enable = true;

  services.tlp = {
    enable = true;
    settings = { DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth"; };
  };

  programs.zsh.enable = true;
  users.users.${userSettings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    gcc
    networkmanagerapplet
    unzip
    unrar
    zip
    file
    home-manager
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  environment.variables = { EDITOR = "nvim"; };

  #hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.nix-ld.enable = true;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11";
}

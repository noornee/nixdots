{
  lib,
  pkgs,
  userSettings,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-users = [ userSettings.username ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    eval-cache = false;
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    supportedFilesystems = [ "ntfs" ];
    tmp.cleanOnBoot = true;

    loader = {
      # lanzaboote replaces systemd-boot (it still uses systemd-boot, signed with our keys)
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    # secure boot. keys live in /var/lib/sbctl (create once with `sudo sbctl create-keys`)
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      settings.editor = false; # no editing the kernel cmdline at the boot menu (e.g. init=/bin/sh)
    };

    initrd = {
      # unlocked by the TPM (sealed to secure boot state, PCR 7); falls back to the
      # passphrase / recovery key prompt if the TPM refuses
      luks.devices."crypt-home" = {
        device = "/dev/disk/by-label/crypt-home";
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    };
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/HOME";
    fsType = "ext4";
    options = [ "discard" ];
  };

  networking = {
    hostName = "thinkpad";
    networkmanager.enable = true;
    wireguard.enable = true;
  };

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
  services.tailscale.enable = true;

  services.tlp = {
    enable = true;
    settings = {

      # sudo tlp setcharge 0 100
      # to temporarily override

      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 90;

      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    };
  };

  programs.zsh.enable = true;
  users.users.${userSettings.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    createHome = true;
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
    wg-netmanager
    sbctl # manage/check secure boot keys (`sudo sbctl verify`)

    git
    neovim
    wget
    gcc
    networkmanagerapplet
    networkmanager-openvpn
    unzip
    unrar
    zip
    file
    home-manager
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  #hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  programs.hyprlock.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.nix-ld.enable = true;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11";
}

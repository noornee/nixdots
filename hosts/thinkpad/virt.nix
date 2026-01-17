{ pkgs, userSettings, ... }: {

  environment.systemPackages = with pkgs; [ virt-manager virt-viewer ];

  virtualisation = {
    docker = { enable = true; };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    # spiceUSBRedirection.enable = true;
  };

  users.users.${userSettings.username}.extraGroups = [ "docker" "libvirtd" ];
  # users.users.${userSettings.username}.extraGroups = [ "docker" ];
}

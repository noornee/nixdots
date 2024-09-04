{ pkgs, userSettings, home-manager, ... }: {

  environment.systemPackages = with pkgs; [ virt-manager virt-viewer ];

  virtualisation = {
    docker = { enable = true; };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  users.users.${userSettings.username}.extraGroups = [ "docker" "libvirtd" ];
}

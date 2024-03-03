{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neofetch
  ];
  home.file.".config/neofetch/config.conf".text = ''
    print_info() {
    	info title
    	info underline

    	info "$(color 12)  OS" distro
    	info "$(color 2)  VER" kernel
    	info "$(color 3)  UP " uptime
    	info "$(color 4)  PKG" packages
    	prin " "
    	info "$(color 4)  WM " de
    	info "$(color 9)  TER" term
    	info "$(color 10)󱆃 SH " shell
    	prin " "
    	info "$(color 5)  CPU" cpu
    	info "$(color 6)  GPU" gpu
    	info "$(color 7)  RAM" memory

    	info cols
    }
    memory_unit="gib"
    distro_shorthand="on"
  '';
}

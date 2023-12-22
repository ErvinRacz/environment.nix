{ inputs, config, pkgs, lib, ... }:
let
  inTestingVm = config.invm.enable && config.testmode.enable;
in
{
  options.hyprland.enable = lib.mkEnableOption "Hyprland.";
  options.testmode.enable = lib.mkEnableOption "Testmode.";
  options.invm.enable = lib.mkEnableOption "In Virtual Machine";

  config = lib.mkIf config.hyprland.enable {
      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true;
      };

      environment.sessionVariables = lib.mkIf inTestingVm {
        # do not forget to turn on accelerated 3d rendering in vm
        WLR_NO_HARDWARE_CURSORS = "1"; # might be needed in simple vm, not sure
        WLR_RENDERER_ALLOW_SOFTWARE = "1"; # needed in simple vm, not sure
        NIXOS_OZONE_WL = "1"; # hints the electron app to use wayland - important for nvidia drivers and others maybe
      };

      hardware = lib.mkIf inTestingVm {
        opengl.enable = true;
      };

      environment.systemPackages = [
        pkgs.waybar
        pkgs.dunst
        libnotify
      ];
  };
}

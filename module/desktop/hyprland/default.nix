{ inputs, config, pkgs, lib, ... }:
{
  options.hyprland.enable = lib.mkEnableOption "Hyprland.";
  options.testmode.enable = lib.mkEnableOption "Testmode.";

  config = lib.mkIf config.hyprland.enable let
    inTestingVm = lib.virtualisation.isInVM && config.testmode.enable;
  in {
      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      } // (if inTestingVm then {
        xwayland.enable = true;
      } else {});

      environment.sessionVariables = lib.mkIf inTestingVm {
        WLR_NO_HARDWARE_CURSORS = "1";
        WLR_RENDERER_ALLOW_SOFTWARE = "1";
        NIXOS_OZONE_WL = "1";
      };

      hardware = lib.mkIf inTestingVm {
        opengl.enable = true;
      };
  };
}

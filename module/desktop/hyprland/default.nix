{ inputs, config, pkgs, lib, ... }:
{
  options.hyprland.enable = lib.mkEnableOption "Hyprland.";

  config = lib.mkIf config.hyprland.enable {
      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
  };
}

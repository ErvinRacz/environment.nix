{ inputs, config, pkgs, lib, ... }:
{
  options.hyperland.enable = lib.mkEnableOption "Hyperland.";

  config = lib.mkIf config.hyperland.enable {
      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      };
  };
}

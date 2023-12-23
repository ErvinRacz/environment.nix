{ config, pkgs, ... }:
{
  config = {
      environment.systemPackages = with pkgs; [
        alacritty
        kitty
        zellij
      ];
  };
}

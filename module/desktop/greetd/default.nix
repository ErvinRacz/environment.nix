{ userConfig, config, pkgs, lib, ... }:
{
  # greetd session manager
  services.greetd = let
    session = {
      # command = "${lib.getExe config.programs.hyprland.package}";
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
      user = "${userConfig.username}" ;
    };
  in {
    enable = true;
    settings = {
      default_session = session;
      initial_session = session;
    };
  };

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
  ];

  # unlock GPG keyring, which sotres SSH keys, stored credentials, etc on login
  # security.pam.services.greetd.enableGnomeKeyring = true;
}

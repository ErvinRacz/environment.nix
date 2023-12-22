{ userConfig, inputs, config, pkgs, lib, ... }:
{
  # greetd session manager
  services.greetd = let
    session = {
      command = "${lib.getExe config.programs.hyprland.package}";
      user = "${userConfig.username}" ;
    };
  in {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = session;
      initial_session = session;
    };
  };

  # unlock GPG keyring, which sotres SSH keys, stored credentials, etc on login
  security.pam.services.greetd.enableGnomeKeyring = true;
}

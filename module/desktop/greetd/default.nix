{ userConfig, config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    greetd.tuigreet
  ];

  # greetd session manager
  services.greetd = let
    session = {
      # command = "${lib.getExe config.programs.hyprland.package}";
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --user-menu --asterisks --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
      user = "${userConfig.username}" ;
    };
  in {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = session;
      initial_session = session;

      extraConfig = ''
        $mainMod = SUPER
        bind = $mainMod, T, exec, alacritty
      '';
    };
  };

  # unlock GPG keyring, which sotres SSH keys, stored credentials, etc on login
  # security.pam.services.greetd.enableGnomeKeyring = true;
}

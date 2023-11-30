{ inputs, userConfig }:

system:

let
  hardware-configuration = import ./nixos-hardware-configuration.nix;
  configuration = import ../module/configuration.nix;
  home-manager-config = import ../module/home-manager.nix;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  # modules: allows for reusable code
  modules = [
    {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/vda";
      boot.loader.grub.useOSProber = true;
      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = false;
      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;
      services.openssh.settings.PermitRootLogin = "no";
      users.mutableUsers = false;
      users.users."${userConfig.username}" = {
        extraGroups = [ "wheel" ];
        home = "/home/${userConfig.username}";
        isNormalUser = true;
        password = "password";
      };
      system.stateVersion = "23.05";

      hyprland.enable = true;
    }
    hardware-configuration
    configuration
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${userConfig.username}" = home-manager-config;
    }
    # add more nix modules here
  ];
}

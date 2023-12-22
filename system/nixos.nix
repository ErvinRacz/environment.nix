{ inputs, userConfig }:

system:

let
  hardware-configuration = import ./nixos-hardware-configuration.nix;
  configuration = import ../module/configuration.nix { inherit userConfig; };
  home-manager-config = import ../module/home-manager.nix;
in
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  inherit system;
  modules = [
    {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";
      boot.loader.grub.useOSProber = true;
      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = false;
      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;
      services.openssh.settings.PermitRootLogin = "no";
      users = {
          mutableUsers = false;
          allowNoPasswordLogin = true;
          users."${userConfig.username}" = {
              extraGroups = [ "wheel" "networkmanager" ];
              home = "/home/${userConfig.username}";
              isNormalUser = true;
              password = "password";
          };
      };
      system.stateVersion = "23.11";
    }
    hardware-configuration
    configuration
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${userConfig.username}" = home-manager-config;
    }
    {
        # programs and services
        hyprland.enable = true;
        testmode.enable = true;
        invm.enable = true;
    }
    # add more nix modules here
  ];
}

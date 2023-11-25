{ inputs, username }:

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
      users.users."${username}" = {
        extraGroups = [ "wheel" ];
        home = "/home/${username}";
        isNormalUser = true;
        password = "password";
      };
      system.stateVersion = "23.05";
    }
    hardware-configuration
    configuration
    # add more nix modules here
  ];
}

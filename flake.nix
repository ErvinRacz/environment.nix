{
  description = "Example kickstart Nix development setup.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin = {
    	url = "github:lnl7/nix-darwin/master";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, ... }:
    let
      ### START OPTIONS ###
      userConfig = {
        username = "ervin";
        fullName = "Ervin Racz";
      };
      ### END OPTIONS ###

      ### START SYSTEMS ###
      darwin-system = import ./system/darwin.nix { inherit inputs userConfig; };
      nixos-system = import ./system/nixos.nix { inherit inputs userConfig; };
      ### END SYSTEMS ###
    in
    {
      darwinConfigurations = {
        darwin-aarch64 = darwin-system "aarch64-darwin";
        darwin-x86_64 = darwin-system "x86_64-darwin";
      };
      nixosConfigurations = {
        nixos-aarch64 = nixos-system "aarch64-linux";
        nixos-x86_64 = nixos-system "x86_64-linux";
      };
    };
}

{
  description = "My Python application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        customOverrides = self: super: {
          # Overrides go here
        };

        app = pkgs.poetry2nix.mkPoetryApplication {
          projectDir = ./.;
          overrides =
            [ pkgs.poetry2nix.defaultPoetryOverrides customOverrides ];
        };

        # DON'T FORGET TO PUT YOUR PACKAGE NAME HERE, REMOVING `throw`
        packageName = "poetry test";
      in {
        packages.${packageName} = app;

        defaultPackage =
          # Notice the reference to nixpkgs here.
          with import nixpkgs { system = "x86_64-linux"; };
          stdenv.mkDerivation {
            name = "lol";
          };

        devShells.${system}.default = pkgs.myAppEnv.env.overrideAttrs (oldAttrs: {
          buildInputs = with pkgs; [ poetry jq ];
          inputsFrom = builtins.attrValues self.packages.${system};
        });
      });
}

{
  description = "An open-source bootstrapper for Sober, similar to Bloxstrap.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
      in
      {
        packages = rec {
          lucem = pkgs.buildNimPackage {
            pname = "lucem";
            version = "2.1.2";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              wrapGAppsHook4
              pkg-config
            ];

            buildInputs = with pkgs; [
              gtk4.dev
              libadwaita.dev
              openssl.dev
              curl.dev
              libGL.dev
              xorg.libX11
              xorg.libXcursor.dev
              xorg.libXrender
              xorg.libXext
              libxkbcommon
              wayland.dev
              wayland-protocols
              wayland-scanner.dev
            ];

            nimbleFile = ./lucem.nimble;
            lockFile = ./nix/lock.json;

            nimFlags = [
              "--define:ssl"
              "--define:adwMinor=4"
              "--define:nvgGLES3"
              "--deepCopy:on"
              "--panics:on"
            ];
          };
          default = lucem;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nim
            nimble
            pkg-config
            gtk4.dev
            libadwaita.dev
            openssl.dev
            curl.dev
            libGL.dev
            xorg.libX11
            xorg.libXcursor.dev
            xorg.libXrender
            xorg.libXext
            libxkbcommon
            wayland.dev
            wayland-protocols
            wayland-scanner.dev
          ];

          LD_LIBRARY_PATH = lib.makeLibraryPath (
            with pkgs;
            [
              gtk4.dev
              libadwaita.dev
              pkg-config
              curl.dev
              openssl.dev
              wayland.dev
            ]
          );
        };
      }
    );
}

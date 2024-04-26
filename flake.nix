{
  description = "Boiler plate nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [  rust-overlay.overlays.default ]; };
      in
      rec {
        devShell = pkgs.callPackage ./shell.nix {
          inherit pkgs;
        };
        formatter = pkgs.nixpkgs-fmt;
      });
}

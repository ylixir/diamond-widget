{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "diagonal-widget";
  buildInputs = import ./default.nix;
}

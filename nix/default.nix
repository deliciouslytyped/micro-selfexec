let
  o = self: super: {
    micro = super.micro.overrideAttrs (old: {
      patches = [ ./add-syscall.patch ];
      }); 
    };
  p = import (import ./sources.nix).nixpkgs { overlays = [ o ]; };
in {
  shell = p.mkShell {
    name = "tooling-shell";
    buildInputs = [ p.micro ]; 
    };
  inherit p;
  inherit (p) micro;
  }

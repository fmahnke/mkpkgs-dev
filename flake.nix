{
  outputs = { self, nixpkgs, ... }@inputs:
    with inputs;
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in with pkgs;
    let
      c = { nativeBuildInputs = [ pkg-config ]; };

      opengl = {
        lib = [ libGL xorg.libX11 systemdLibs ];

        nativeBuildInputs = c.nativeBuildInputs ++ opengl.lib;
      };
    in {
      hydraJobs = { inherit (self) packages; };

      devShells.${system} = {
        default = devShells.${system}.c;

        c = pkgs.mkShell { packages = c.nativeBuildInputs; };

        opengl = pkgs.mkShell {
          packages = opengl.nativeBuildInputs;

          shellHook = ''
            LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath opengl.lib}
          '';
        };
      };
    };
}


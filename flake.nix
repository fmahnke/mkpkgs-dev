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

      python-tools = [
        (pkgs.python3.withPackages (python-pkgs:
          with python-pkgs; [
            autopep8
            coverage
            python-lsp-server
            flake8
            jedi
            mypy
            nox
            pylsp-mypy
            pytest
            rope
          ]))
      ];
    in {
      devShells.${system} = {
        default = devShells.${system}.c;

        c = mkShell { packages = c.nativeBuildInputs; };

        opengl = mkShell {
          packages = opengl.nativeBuildInputs;

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath opengl.lib}
          '';
        };

        python = mkShell { packages = python-tools; };
      };
    };
}


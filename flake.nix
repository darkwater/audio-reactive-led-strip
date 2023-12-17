{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          numpy
          scipy
          pyaudio
          pyqtgraph
        ]);
      in
      {
        devShell = pythonEnv;
        packages.default = pkgs.runCommandNoCC "visualization" { 
          buildInputs = [ pythonEnv ];
        } ''
          mkdir -p $out/bin
          echo "#!${pkgs.runtimeShell}" > $out/bin/visualization
          echo "exec ${pythonEnv}/bin/python ${./python}/visualization.py" >> $out/bin/visualization
          chmod +x $out/bin/visualization
        '';
        defaultPackage = self.packages.${system}.default;
      }
    );
}

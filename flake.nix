{
  description = "Habits - iOS Habit Tracker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            xcodegen
          ];

          shellHook = ''
            echo "Habits dev environment loaded"
            echo "xcodegen version: $(xcodegen --version)"
          '';
        };
      }
    );
}

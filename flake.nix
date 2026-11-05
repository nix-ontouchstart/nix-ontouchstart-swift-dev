{
  description = "A minimal native macOS GUI .app bundle built with modern Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "nix-native-gui";
        version = "0.1.0";

        src = ./.;

        # Only require the compiler toolchain. 
        # Apple framework headers are seamlessly linked by stdenv's default SDK setup.
        nativeBuildInputs = [ pkgs.swift ];
        buildInputs = [ ];

        buildPhase = ''
          swiftc ./main.swift -o nix-native-gui
        '';

        installPhase = ''
          APP_DIR="$out/Applications/NixNativeGUI.app/Contents"
          mkdir -p "$APP_DIR/MacOS"
          mkdir -p "$APP_DIR/Resources"

          cp nix-native-gui "$APP_DIR/MacOS/"
          cp Info.plist "$APP_DIR/"
        '';
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/Applications/NixNativeGUI.app/Contents/MacOS/nix-native-gui";
      };
    };
}


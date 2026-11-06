{
  description = "Nix wrapper for swift development";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/master";

  outputs = { self, nixpkgs }: 
    let 
      aarch64-darwin = import nixpkgs { system = "aarch64-darwin"; };
      default = { pkgs } :
        pkgs.stdenv.mkDerivation {
          pname = "nix-ontouchstart-swift-dev";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.swift ];
          buildInputs = [ ];

          buildPhase = ''
            swiftc ./main.swift -o nix-ontouchstart-swift-dev
          '';

          installPhase = ''
            APP_DIR="$out/Applications/NixNativeGUI.app/Contents"
            mkdir -p "$APP_DIR/MacOS"
            mkdir -p "$APP_DIR/Resources"

            cp nix-ontouchstart-swift-dev "$APP_DIR/MacOS/"
            cp Info.plist "$APP_DIR/"
          '';
        };
    in {
      packages.aarch64-darwin.default = default { pkgs = aarch64-darwin; };
      apps.aarch64-darwin.default = {
        type = "app";
        program = "${self.packages.aarch64-darwin.default}/Applications/NixNativeGUI.app/Contents/MacOS/nix-ontouchstart-swift-dev";};
   };
}

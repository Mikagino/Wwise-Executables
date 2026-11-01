{
  description = "An audio authoring application for the development of interactive media (upstream binaries).";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      # icoutils = pkgs.icoutils;
      #wwisePath = "/Authoring/x64/Release/bin/Wwise.exe";

      mkWwise = { pname, version, src }:
        with pkgs;

        stdenv.mkDerivation rec {
          inherit pname version src;

          # 1. Extract icon
          # 2. Move .desktop
          installPhase =
            ''

            '';
              # mkdir -p $out/share/icons/hicolor/scalable/apps
              # wrestool -xt14 $out/Authoring/x64/Release/bin/Wwise.exe -o $out/share/icons/hicolor/scalable/apps/wwise.svg 
              # mkdir -p $out/share/applications
              # mv ./${pname}.${version}.desktop $out/share/applications/${pname}.${version}.desktop

          #   meta = {
          #   description = "An audio authoring application for the development of interactive media (upstream binaries).";
          #   homepage = "https://www.audiokinetic.com/en/wwise/overview/";
          #   #maintainers = [];
          #   #platforms = [ pkgs.stdenv.hostPlatform.system ];
          # };
        };

    in {

      overlays.default = final: prev: {
        wwise_2026_1_3_9276 = mkWwise {
          pname = "wwise-bin";
          version = "2026.1.3.9276";
          src = import pkgs.fetchurl {
            url = "https://github.com/Mikagino/Wwise-Executables/releases/download/Wwise2026.1.3.9276/Wwise2026.1.3.9276.tar.xz";
            hash = "sha256:e981161831b322f4d3edee3d245720fd44f4aba7282217be457bd43778acffae";
          };
        };
      };

      lib.mkWwise = mkWwise;

      packages.x86_64-linux = rec {
        inherit (pkgs)
          wwise_2026_1_3_9276;
        default = wwise_2026_1_3_9276;
      };
    };
}
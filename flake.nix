{
  description = "An audio authoring application for the development of interactive media (upstream binaries).";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      #wwisePath = "/Authoring/x64/Release/bin/Wwise.exe";

      mkWwise = { pname, version, src }:
        with pkgs;

        stdenv.mkDerivation rec {
          inherit pname version src;

          buildInputs = [
            pkgs.icoutils
          ];

          # 1. Extract icon from .exe
          # 2. Move .desktop to store
          # 3. Move rest to bin
          installPhase =
            ''
              runHook preInstall

              mkdir -p $out/share/icons/hicolor/scalable/apps
              wrestool -xt14 ./Authoring/x64/Release/bin/Wwise.exe -o $out/share/icons/hicolor/scalable/apps/Wwise.svg 
              
              mkdir -p $out/share/applications
              mv ./*.desktop $out/share/applications/

              mkdir $out/bin
              mv ./* $out/bin

              runHook postInstall
            '';

          meta = {
            description = "An audio authoring application for the development of interactive media (upstream binaries).";
            homepage = "https://www.audiokinetic.com/en/wwise/overview/";
            maintainers = [];
            platforms = [ pkgs.stdenv.hostPlatform.system ];
          };
        };

    in {

      overlays.default = final: prev: {
        wwise_2026_1_3_9276 = mkWwise {
          pname = "wwise-bin";
          version = "2026.1.3.9276";
          src = pkgs.fetchurl {
            url = "https://github.com/Mikagino/Wwise-Executables/releases/download/Wwise2026.1.3.9276/Wwise2026.1.3.9276.tar.xz";
            hash = "sha256:ec97fd96b8039cc180f3da9384da87f16cd9c21383e4ed1f24aa53ec69161e2c";
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
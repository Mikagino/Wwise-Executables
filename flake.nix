# Wwise Authoring binary flake.nix derivation based on:
# https://github.com/edolstra/nix-warez/blob/master/blender/flake.nix
# https://github.com/emmanuelrosa/sumatrapdf-nix/blob/master/sumatrapdf.nix

{
  description = "An audio authoring application for the development of interactive media (upstream binaries)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    erosanix.url = "github:emmanuelrosa/erosanix";
  };

  outputs = { self,
              nixpkgs,
              mkWindowsApp,
              ... }:

    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      mkWwise = { pname, version, src }:
        with pkgs;
        mkWindowsApp rec {
          inherit pname version src wine;

          dontUnpack = false;
          wineArch = "win64";
          enableInstallNotification = true; # notification when installing (necessary?)
          persistRuntimeLayer = false;
          inputHashMethod = "store-path";
          enableVulkan = false;
          graphicsDriver = "auto";
          inhibitIdle = false; # enable sleep-blocking

          winAppInstall = ''
            d="$WINEPREFIX/drive_c/${pname}"
            mkdir -p "$d"
            tar xf ${src} --directory "$d"
          '';
          
          winAppRun = ''
            wine "$WINEPREFIX/drive_c/${pname}/Authoring/x64/Release/bin/Wwise.exe" "$ARGS"
          '';

          installPhase = ''
            runHook preInstall
            ln -s $out/bin/.launcher $out/bin/${pname}
            runHook postInstall
          '';

          meta = with lib; {
            description = "An audio authoring application for the development of interactive media.";
            homepage = "https://www.audiokinetic.com/en/wwise/";
            platforms = [ "x86_64-linux" ];
          };
        };

    in {

      # ----- Defines all the available versions for download as overlays -----
      overlays.default = final: prev: {
        wwise_2026_1_3_9276 = mkWwise {
          pname = "wwise-bin";
          version = "2026.1.3.9276";
          src = pkgs.fetchurl {
            url = "https://github.com/Mikagino/Wwise-Executables/releases/download/Wwise2026.1.3.9276/Wwise2026.1.3.9276.tar.xz";
            hash = "sha256:e981161831b322f4d3edee3d245720fd44f4aba7282217be457bd43778acffae";
          };
        };
      };

      lib.mkWwise= mkWwise;

      packages.x86_64-linux = rec {
        inherit (pkgs)
          wwise_2026_1_3_9276;
        default = wwise_2026_1_3_9276;
      };
    };
}

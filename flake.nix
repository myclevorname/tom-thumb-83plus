{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = rec {
          default = pkgs.stdenv.mkDerivation {
            name = "tom-thumb";
            src = self;
            inherit fasmg-z80;
            INCLUDE = fasmg-z80;
            nativeBuildInputs = with pkgs; [ fasmg ];
            installPhase = ''
              mkdir -p $out
              cp *.8x* LICENSE $out
            '';
          };
          fasmg-z80 = pkgs.stdenv.mkDerivation {
            name = "fasmg-z80";
            src = pkgs.fetchFromGitHub {
              owner = "jacobly0";
              repo = "fasmg-z80";
              rev = "bfc0f7f04dee0aed5e77990626f1c2199a458d5c";
              hash = "sha256-sEy5Z27elq9Hv0k3o/gWM+t/wIFGusf6miC+HpZGTJA=";
            };
            patchPhase = ''
              patchShebangs ti83plus.sed
            '';
            installPhase = ''
              mkdir -p $out
              cp ${ti83plus-inc} ti83plus.inc
              ./ti83plus.sed
              cp *.inc *.alm $out/
            '';
          };
          ti83plus-inc = pkgs.stdenv.mkDerivation {
            name = "ti83plus.inc";
            src = pkgs.fetchurl {
              url = "https://wikiti.brandonw.net/index.php?title=83Plus:OS:ti83plus.inc&oldid=10413&action=raw";
              hash = "sha256-YQsE9ANqbAioMrxbzTKEK8wKX99wqhom0xm6bWF5HSw=";
            };
            dontUnpack = true;
            installPhase = "cat $src | sed -E '1,/^== Content ==$/d;s,^ *</?(pre|nowiki)>,,' > $out";
          };
        };
      }
    );
}

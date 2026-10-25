{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  pname = "lxgw-zhisong";
  version = "1.002";

  classicSrc = fetchurl {
    hash = "sha256-YiOPJTq21Ys4CCpcdbYJQJ0FwU9XNyB8lO0uTMAjgSs=";
    url = "https://github.com/lxgw/LxgwZhiSong/releases/download/v${version}/LXGWZhiSongCL.ttf";
  };

  modernSrc = fetchurl {
    hash = "sha256-lNnlobL3tD343WLfdy406YTGz8npR6IW44G0dyus0oM=";
    url = "https://github.com/lxgw/LxgwZhiSong/releases/download/v${version}/LXGWZhiSongMN.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-GOY54dXVdcuSaUx5sq7ReBojTrW+QgDBR5psJ+Ef3cw=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhiSong/v${version}/LICENSE.md";
  };

  readmeSrc = fetchurl {
    hash = "sha256-5kpDkxSHL6psOhMt8RB5BNtAupDmIFj7Znoy96wF1KE=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhiSong/v${version}/README.md";
  };

  meta = {
    description = "LXGW ZhiSong Traditional Chinese serif fonts";
    homepage = "https://github.com/lxgw/LxgwZhiSong";
    license = licenses.ipa;

    longDescription = ''
      Provides the Classic and Modern variants of LXGW ZhiSong, a
      Traditional Chinese serif family derived from IPAex Mincho.
      Classic follows traditional printed forms and merges selected
      source-separated characters; Modern balances printed forms with
      contemporary component conventions and preserves those characters.

      The IPA Font License 1.0 permits commercial use. Redistribution
      must preserve the license and provide a way to replace the font
      with the original IPA font; modified versions must use the same
      license.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    version
    ;

  dontUnpack = true;

  srcs = [
    classicSrc
    modernSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${classicSrc} $fontDir/LXGWZhiSongCL.ttf
    install -Dm444 ${modernSrc} $fontDir/LXGWZhiSongMN.ttf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md
    install -Dm444 ${readmeSrc} $docDir/README.md

    runHook postInstall
  '';
}

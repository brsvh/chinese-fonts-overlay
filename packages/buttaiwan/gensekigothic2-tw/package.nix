{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "2.100";

  src = fetchurl {
    hash = "sha256-4NfF0UvchRvycu+LkBgxW+x5eBtTK00pmpVlP6uIvjg=";
    url = "https://github.com/ButTaiwan/genseki-font/releases/download/v${version}/GenSekiGothic2TW-otf.zip";
  };

  meta = {
    description = "GenSekiGothic2 TW Traditional Chinese Gothic font family";
    homepage = "https://github.com/ButTaiwan/genseki-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenSekiGothic2 TW, the Traditional Chinese modern-use
      Gothic variant of ButTaiwan's GenSekiGothic2 Source Han Sans
      derivative, in Light, Regular, Medium, Bold, and Heavy weights.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "buttaiwan-gensekigothic2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenSekiGothic2TW-L.otf \
      GenSekiGothic2TW-R.otf \
      GenSekiGothic2TW-M.otf \
      GenSekiGothic2TW-B.otf \
      GenSekiGothic2TW-H.otf

    runHook postInstall
  '';
}

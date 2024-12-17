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

  version = "0.108";

  src = fetchurl {
    url = "https://github.com/TrionesType/zhuque/releases/download/v${version}/ZhuqueFangsong-v${version}.zip";
    hash = "sha256-/3url2S4jVjw9LGP4Zf9Gz6sOmfBADCiQFVtqNygxgo=";
  };

  meta = {
    description = "An open-source Fangsong typeface project";
    homepage = "http://trionestype.github.io/";
    license = licenses.ofl;
    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "trionestype-ZhuqueFangsong";

  buildInputs = [
    unzip
  ];

  nativeBuildInputs = [
    unzip
  ];

  phases = [
    "unpackPhase"
  ];

  unpackPhase = ''
    runHook preUnpack

    mkdir -p $out/share/fonts/truetype/
    unzip $src -d $out/share/fonts/truetype/

    runHook postUnpack
  '';
}

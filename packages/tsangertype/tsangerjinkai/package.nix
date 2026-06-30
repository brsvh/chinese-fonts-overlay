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

  version = "1.000-unstable-2024-12-22";

  fetchFont =
    variant: weight: hash:
    fetchurl {
      inherit
        hash
        ;

      name = "TsangerJinKai${variant}-W${weight}.ttf";
      url = "https://tsanger.cn/download/仓耳今楷${variant}-W${weight}.ttf";
    };

  v01w01Src =
    fetchFont "01" "01"
      "sha256-7AkZDKieiwa2Ts1LwSsaKA67o5Cfa7ngFndVyQydb3Q=";
  v01w02Src =
    fetchFont "01" "02"
      "sha256-QXCTVgR86zm2uXyWU3zTkHN5IA1EFkJPW2Q66ByA0d8=";
  v01w03Src =
    fetchFont "01" "03"
      "sha256-Xy2iz6mrIOdIJU4YQTusxOfFcu6+/vCAWmYkYBz9FZo=";
  v01w04Src =
    fetchFont "01" "04"
      "sha256-QPEO1TENaSB7AI6zaI/ipa50g1hJmMY37jIHlIqqeDY=";
  v01w05Src =
    fetchFont "01" "05"
      "sha256-1eIi16SA/5AHQKZc1Ajhchjk+nnrMxWk0siU4twFjKA=";
  v02w01Src =
    fetchFont "02" "01"
      "sha256-NIuEIm5UJxF9WFA8M714ERERPmqXOffixIJqDu1oqn0=";
  v02w02Src =
    fetchFont "02" "02"
      "sha256-M5eW+91mZofFs2hnIadvgqD1PPi4PsFkK61mxR6Rapk=";
  v02w03Src =
    fetchFont "02" "03"
      "sha256-tPpR1M2D5Km43b8MP0WlL8eyuwsizgTdLBU9n1kVIpY=";
  v02w04Src =
    fetchFont "02" "04"
      "sha256-R6m0FsJ61UNnlMiAzj9majE1qGLtHiyRqn20iRSmpIc=";
  v02w05Src =
    fetchFont "02" "05"
      "sha256-l0TcloAeyMkaM5C+0kyZPUci+0BuHYeRd9ND1A6YWm4=";
  v03w01Src =
    fetchFont "03" "01"
      "sha256-kBqtt7LTmH/5uhZaU4jlNHjm45+VPz6su1MzIZpn7CU=";
  v03w02Src =
    fetchFont "03" "02"
      "sha256-IYbEQrjWvE4AVdvh9NtuunZGWDDUpiPS2oCWL8QsnHA=";
  v03w03Src =
    fetchFont "03" "03"
      "sha256-fLKnQJA7lDtbQpwHXKkiLZHUEYC8N0WA7XKpeZI9wC8=";
  v03w04Src =
    fetchFont "03" "04"
      "sha256-ELZq4FrQUemH+t1Kb6Y9NwJLHcU58LADqZuBDp5G1JU=";
  v03w05Src =
    fetchFont "03" "05"
      "sha256-0G92qB9UHMy+DwGmOuWuLXr0Rh9QrKWpdvQRA55S3d4=";
  v04w01Src =
    fetchFont "04" "01"
      "sha256-mAb5Idoi1s01PnGYAe+Z+WwyGUoD/7WhCKGvSr1ncv4=";
  v04w02Src =
    fetchFont "04" "02"
      "sha256-fPGGaz+LzIolGS5Gzk1npwKSIlx9cwzOhE+ftsb6xdY=";
  v04w03Src =
    fetchFont "04" "03"
      "sha256-G93GjWkkCwkWqGKqScIgQ6mjWbXhr47jJjVHcaMlNe8=";
  v04w04Src =
    fetchFont "04" "04"
      "sha256-fV54WSeWYkymkMxHo771YjJ3pRN9Ut+HsTnwPRAiyfo=";
  v04w05Src =
    fetchFont "04" "05"
      "sha256-M61cysNUtq/5u9RPeKTMmYvsBgTFeTtjW8IXGKL+X60=";
  v05w01Src =
    fetchFont "05" "01"
      "sha256-B0KuXIoDcObg6eQ0tCu174lDulG58FBbYZuQp0uBHco=";
  v05w02Src =
    fetchFont "05" "02"
      "sha256-t/BRrBccYvTgg9g9cXRs+E77U0JQ2unKdAFCncF+zOc=";
  v05w03Src =
    fetchFont "05" "03"
      "sha256-CB5iJFQ3qVm17zG9iZpdVaFyrrM/ks1cicPY4VWtfIk=";
  v05w04Src =
    fetchFont "05" "04"
      "sha256-7zRySTe6+Tj7NaB507f48XXPVgcIcOYLkOAqlqYz0n8=";
  v05w05Src =
    fetchFont "05" "05"
      "sha256-VYDqYXg30VXcJOv/EKhdATWs4OsT5QcMUzMNshkbP2Q=";

  meta = {
    description = "TsangerJinKai font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerJinKai font family.

      TsangerType states that these fonts are free for personal,
      non-commercial use. Do not use them commercially, redistribute
      the font files, or publish them through a binary cache unless
      TsangerType permits it.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    version
    ;

  pname = "tsangertype-tsangerjinkai";

  dontUnpack = true;

  srcs = [
    v01w01Src
    v01w02Src
    v01w03Src
    v01w04Src
    v01w05Src
    v02w01Src
    v02w02Src
    v02w03Src
    v02w04Src
    v02w05Src
    v03w01Src
    v03w02Src
    v03w03Src
    v03w04Src
    v03w05Src
    v04w01Src
    v04w02Src
    v04w03Src
    v04w04Src
    v04w05Src
    v05w01Src
    v05w02Src
    v05w03Src
    v05w04Src
    v05w05Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${v01w01Src} $fontDir/TsangerJinKai01-W01.ttf
    install -Dm444 ${v01w02Src} $fontDir/TsangerJinKai01-W02.ttf
    install -Dm444 ${v01w03Src} $fontDir/TsangerJinKai01-W03.ttf
    install -Dm444 ${v01w04Src} $fontDir/TsangerJinKai01-W04.ttf
    install -Dm444 ${v01w05Src} $fontDir/TsangerJinKai01-W05.ttf
    install -Dm444 ${v02w01Src} $fontDir/TsangerJinKai02-W01.ttf
    install -Dm444 ${v02w02Src} $fontDir/TsangerJinKai02-W02.ttf
    install -Dm444 ${v02w03Src} $fontDir/TsangerJinKai02-W03.ttf
    install -Dm444 ${v02w04Src} $fontDir/TsangerJinKai02-W04.ttf
    install -Dm444 ${v02w05Src} $fontDir/TsangerJinKai02-W05.ttf
    install -Dm444 ${v03w01Src} $fontDir/TsangerJinKai03-W01.ttf
    install -Dm444 ${v03w02Src} $fontDir/TsangerJinKai03-W02.ttf
    install -Dm444 ${v03w03Src} $fontDir/TsangerJinKai03-W03.ttf
    install -Dm444 ${v03w04Src} $fontDir/TsangerJinKai03-W04.ttf
    install -Dm444 ${v03w05Src} $fontDir/TsangerJinKai03-W05.ttf
    install -Dm444 ${v04w01Src} $fontDir/TsangerJinKai04-W01.ttf
    install -Dm444 ${v04w02Src} $fontDir/TsangerJinKai04-W02.ttf
    install -Dm444 ${v04w03Src} $fontDir/TsangerJinKai04-W03.ttf
    install -Dm444 ${v04w04Src} $fontDir/TsangerJinKai04-W04.ttf
    install -Dm444 ${v04w05Src} $fontDir/TsangerJinKai04-W05.ttf
    install -Dm444 ${v05w01Src} $fontDir/TsangerJinKai05-W01.ttf
    install -Dm444 ${v05w02Src} $fontDir/TsangerJinKai05-W02.ttf
    install -Dm444 ${v05w03Src} $fontDir/TsangerJinKai05-W03.ttf
    install -Dm444 ${v05w04Src} $fontDir/TsangerJinKai05-W04.ttf
    install -Dm444 ${v05w05Src} $fontDir/TsangerJinKai05-W05.ttf

    runHook postInstall
  '';
}

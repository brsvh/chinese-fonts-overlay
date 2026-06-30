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

  version = "1.000-unstable-2024-05-24";

  fetchFont =
    variant: weight: name: hash:
    fetchurl {
      inherit
        hash
        name
        ;

      url = "https://tsanger.cn/download/仓耳玄三${variant}-W${weight}.ttf";
    };

  v01w01Src =
    fetchFont "01" "01" "TsangerXuanSan01JF-W01.ttf"
      "sha256-OCN7+TmNM317QBawr+JGd9puv024S5Tk+X+7cEDB4r8=";
  v01w02Src =
    fetchFont "01" "02" "TsangerXuanSan01JF-W02.ttf"
      "sha256-wEd0d9GcKGjwQ3v3nJ50FfBE/iW9O8Q5wmkF1I7cYrg=";
  v01w03Src =
    fetchFont "01" "03" "TsangerXuanSan01JF-W03.ttf"
      "sha256-X1AOirvTKEkIsvDjx6vp9zWsG+qOAqFuvqsVLnBZkWU=";
  v01w04Src =
    fetchFont "01" "04" "TsangerXuanSan01JF-W04.ttf"
      "sha256-8WgEgfOsuhBlIC/5vGVrS7R6Ze3Hck0IZ4OqUE53Unw=";
  v01w05Src =
    fetchFont "01" "05" "TsangerXuanSan01JF-W05.ttf"
      "sha256-E1XfqKbzUz2PmZ54k7HByPcCLYrUnrfMaFw+xOEg4a0=";
  v02w01Src =
    fetchFont "02" "01" "TsangerXuanSan02-W01.ttf"
      "sha256-4eEzh2b1UplZOSnOxRsEVaf11tIIPVEKCGcENTdGZtI=";
  v02w02Src =
    fetchFont "02" "02" "TsangerXuanSan02-W02.ttf"
      "sha256-OFw90SU5ZpEjDhvfyoFeBxRe3oHPYo0pb38CoJKu62c=";
  v02w03Src =
    fetchFont "02" "03" "TsangerXuanSan02-W03.ttf"
      "sha256-S3ZBtNthjp8OHjvDNecWgndDYdkimNTvsN9nWY9Pm0k=";
  v02w04Src =
    fetchFont "02" "04" "TsangerXuanSan02-W04.ttf"
      "sha256-sD1w7Q4y46oymKipKG56BEkk8y/sQpzMnkgqn2nUzvo=";
  v02w05Src =
    fetchFont "02" "05" "TsangerXuanSan02-W05.ttf"
      "sha256-eovy7HRd1jedfBS6gcG1N2zYOS65Vdy/49+KAcRRZuM=";
  v03w01Src =
    fetchFont "03" "01" "TsangerXuanSan03-W01.ttf"
      "sha256-pS6CMyF+1MlQcJSmJxVxDuv4bWT6AqpJjWHJ343ySEo=";
  v03w02Src =
    fetchFont "03" "02" "TsangerXuanSan03-W02.ttf"
      "sha256-41xvUV9Lfbb9I3nPMdlbOHiGBRoPCdEI1f0a9XkG1nI=";
  v03w03Src =
    fetchFont "03" "03" "TsangerXuanSan03-W03.ttf"
      "sha256-iRR1LqLRie8HtFqr4EN3wl7hgsGYOvo/g7OEn++vptU=";
  v03w04Src =
    fetchFont "03" "04" "TsangerXuanSan03-W04.ttf"
      "sha256-NXUMFmeUCTVMx/EuMD4RYCvvddI+++xMw4ZcCL6RZko=";
  v03w05Src =
    fetchFont "03" "05" "TsangerXuanSan03-W05.ttf"
      "sha256-5OlnKtmK66iX21JcqKSDeZhC52ab4Pz9TUg2tC/NbIE=";
  v04w01Src =
    fetchFont "04" "01" "TsangerXuanSan04-W01.ttf"
      "sha256-k9pWjz9uD3bYSxLZwI1qTGRmfByeI86qRR5Qcje5QPA=";
  v04w02Src =
    fetchFont "04" "02" "TsangerXuanSan04-W02.ttf"
      "sha256-V3HD1Vai3TyOml+6aR5M3g6kdjIlvWbxm4lY2auIrYo=";
  v04w03Src =
    fetchFont "04" "03" "TsangerXuanSan04-W03.ttf"
      "sha256-O/fgoULAyjPSlNl8t4i1aR9tp4xJb41xampLpQOU5oA=";
  v04w04Src =
    fetchFont "04" "04" "TsangerXuanSan04-W04.ttf"
      "sha256-fkEkm3Hn60Nc/U7lmS0mDB/TJnTavdhOzEiizNoYPCg=";
  v04w05Src =
    fetchFont "04" "05" "TsangerXuanSan04-W05.ttf"
      "sha256-ly88bz4ZR0xnw6Q3lF55upCNQ9BXGTGu/C7YxQAfOD8=";
  vMw01Src =
    fetchFont "M" "01" "TsangerXuanSanM-W01.ttf"
      "sha256-syKwoENt6KBOoXhB3sg1MNz+Ec3LX6Yk2l3TU1v4N5o=";
  vMw02Src =
    fetchFont "M" "02" "TsangerXuanSanM-W02.ttf"
      "sha256-HdUIQLZuL9M4ec7GugtgBPk7xRlVbpwfV98qE9EDsO8=";
  vMw03Src =
    fetchFont "M" "03" "TsangerXuanSanM-W03.ttf"
      "sha256-knGH4AFBePaPY2WUZ8tY5Or3tvYHZzVqrfGB5SZn5QU=";
  vMw04Src =
    fetchFont "M" "04" "TsangerXuanSanM-W04.ttf"
      "sha256-dc84dndB49zw9WJyVE76c3CLqziFKKshk5WR4L9O17w=";
  vMw05Src =
    fetchFont "M" "05" "TsangerXuanSanM-W05.ttf"
      "sha256-5qE8M+iLnP87yi48imvW9L1PHIQMSOz8yHf7p4EeYJE=";

  meta = {
    description = "TsangerXuanSan font family";
    homepage = "https://tsanger.cn";
    license = licenses.tsangertype-font-license;

    longDescription = ''
      Provides the TsangerXuanSan font family.

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

  pname = "tsangertype-tsangerxuansan";

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
    vMw01Src
    vMw02Src
    vMw03Src
    vMw04Src
    vMw05Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/tsangertype
    install -Dm444 ${v01w01Src} $fontDir/TsangerXuanSan01JF-W01.ttf
    install -Dm444 ${v01w02Src} $fontDir/TsangerXuanSan01JF-W02.ttf
    install -Dm444 ${v01w03Src} $fontDir/TsangerXuanSan01JF-W03.ttf
    install -Dm444 ${v01w04Src} $fontDir/TsangerXuanSan01JF-W04.ttf
    install -Dm444 ${v01w05Src} $fontDir/TsangerXuanSan01JF-W05.ttf
    install -Dm444 ${v02w01Src} $fontDir/TsangerXuanSan02-W01.ttf
    install -Dm444 ${v02w02Src} $fontDir/TsangerXuanSan02-W02.ttf
    install -Dm444 ${v02w03Src} $fontDir/TsangerXuanSan02-W03.ttf
    install -Dm444 ${v02w04Src} $fontDir/TsangerXuanSan02-W04.ttf
    install -Dm444 ${v02w05Src} $fontDir/TsangerXuanSan02-W05.ttf
    install -Dm444 ${v03w01Src} $fontDir/TsangerXuanSan03-W01.ttf
    install -Dm444 ${v03w02Src} $fontDir/TsangerXuanSan03-W02.ttf
    install -Dm444 ${v03w03Src} $fontDir/TsangerXuanSan03-W03.ttf
    install -Dm444 ${v03w04Src} $fontDir/TsangerXuanSan03-W04.ttf
    install -Dm444 ${v03w05Src} $fontDir/TsangerXuanSan03-W05.ttf
    install -Dm444 ${v04w01Src} $fontDir/TsangerXuanSan04-W01.ttf
    install -Dm444 ${v04w02Src} $fontDir/TsangerXuanSan04-W02.ttf
    install -Dm444 ${v04w03Src} $fontDir/TsangerXuanSan04-W03.ttf
    install -Dm444 ${v04w04Src} $fontDir/TsangerXuanSan04-W04.ttf
    install -Dm444 ${v04w05Src} $fontDir/TsangerXuanSan04-W05.ttf
    install -Dm444 ${vMw01Src} $fontDir/TsangerXuanSanM-W01.ttf
    install -Dm444 ${vMw02Src} $fontDir/TsangerXuanSanM-W02.ttf
    install -Dm444 ${vMw03Src} $fontDir/TsangerXuanSanM-W03.ttf
    install -Dm444 ${vMw04Src} $fontDir/TsangerXuanSanM-W04.ttf
    install -Dm444 ${vMw05Src} $fontDir/TsangerXuanSanM-W05.ttf

    runHook postInstall
  '';
}

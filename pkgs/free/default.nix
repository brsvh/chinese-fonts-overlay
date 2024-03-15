final: prev:
let
  inherit (prev) callPackage;
in
{
  tsangertype-font-feibai-w01 = callPackage ./feibai-w01.nix { };

  tsangertype-font-feibai-w02 = callPackage ./feibai-w02.nix { };

  tsangertype-font-feibai-w03 = callPackage ./feibai-w03.nix { };

  tsangertype-font-feibai-w04 = callPackage ./feibai-w04.nix { };

  tsangertype-font-feibai-w05 = callPackage ./feibai-w05.nix { };

  tsangertype-font-shuyuan-w01 = callPackage ./shuyuan-w01.nix { };

  tsangertype-font-shuyuan-w02 = callPackage ./shuyuan-w02.nix { };

  tsangertype-font-shuyuan-w03 = callPackage ./shuyuan-w03.nix { };

  tsangertype-font-shuyuan-w04 = callPackage ./shuyuan-w04.nix { };

  tsangertype-font-shuyuan-w05 = callPackage ./shuyuan-w05.nix { };

  tsangertype-font-xiaowanzi = callPackage ./xiaowanzi.nix { };

  tsangertype-font-yumo-w01 = callPackage ./yumo-w01.nix { };

  tsangertype-font-yumo-w02 = callPackage ./yumo-w02.nix { };

  tsangertype-font-yumo-w03 = callPackage ./yumo-w03.nix { };

  tsangertype-font-yumo-w04 = callPackage ./yumo-w04.nix { };

  tsangertype-font-yumo-w05 = callPackage ./yumo-w05.nix { };

  tsangertype-font-yuyang-w01 = callPackage ./yuyang-w01.nix { };

  tsangertype-font-yuyang-w02 = callPackage ./yuyang-w02.nix { };

  tsangertype-font-yuyang-w03 = callPackage ./yuyang-w03.nix { };

  tsangertype-font-yuyang-w04 = callPackage ./yuyang-w04.nix { };

  tsangertype-font-yuyang-w05 = callPackage ./yuyang-w05.nix { };

  tsangertype-font-zhoukezhengdabangshu = callPackage ./zhoukezhengdabangshu.nix { };
}

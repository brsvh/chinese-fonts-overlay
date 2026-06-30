{
  inputs = {
    blank = {
      url = "git+https://github.com/divnix/blank.git?ref=master";
    };

    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixpkgs-unstable";
    };

    systems = {
      url = "git+https://github.com/nix-systems/x86_64-linux.git?ref=main";
    };
  };

  outputs = _: { };
}

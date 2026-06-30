{
  lib,
  ...
}:
let
  inherit (lib)
    makeExtensible
    ;
in
makeExtensible (
  final:
  let
    import' =
      file:
      import file {
        inherit
          lib
          ;

        infix-lib = final;
      };
  in
  {
    inherit (final.derivations)
      filterDerivations
      ;

    inherit (final.flake)
      evalFlakeModule
      hasInput
      mkFlake
      ;

    derivations = import' ./derivations.nix;
    flake = import' ./flake.nix;
    licenses = import' ./licenses.nix;
  }
)

{
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    filter
    isDerivation
    pipe
    ;
in
{
  /**
    Return derivations from an attribute set that satisfy a predicate.

    Non-derivation attributes in the input scope are ignored before applying
    the predicate.

    # Inputs

    `predicate`
    : Function used to select derivations.

    `scope` (Attribute set)
    : Attribute set that may contain derivations and helper attributes.

    # Type

    ```
    filterDerivations :: (Derivation -> Bool) -> AttrSet -> [ Derivation ]
    ```

    # Examples
    :::{.example}
    ## `chinese-fonts-overlay-lib.filterDerivations` usage example

    ```nix
    filterDerivations
      (
        package:
        (package.meta.license or null)
        == licenses.foundertype-family-license
      )
      foundertypePackages
    ```

    :::
  */
  filterDerivations =
    predicate: scope:
    pipe scope [
      attrValues
      (filter isDerivation)
      (filter predicate)
    ];
}

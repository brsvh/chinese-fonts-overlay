{
  fontPkgs,
  lib,
  pkgs,
  projectRoot,
  ...
}:
let
  inherit (lib)
    assertMsg
    concatMap
    concatStringsSep
    filter
    fromJSON
    groupBy
    isAttrs
    isString
    mapAttrsToList
    match
    pipe
    readFile
    toJSON
    ;

  inherit (pkgs)
    writeText
    ;

  fontCatalog =
    import (projectRoot + /packages/font-catalog.nix)
      {
        inherit projectRoot;

        pkgs = fontPkgs;
      };

  languageNames = fromJSON (
    readFile (
      projectRoot + /pages/etc/language-names.json
    )
  );

  languageSamples = fromJSON (
    readFile (
      projectRoot + /pages/etc/language-samples.json
    )
  );

  nonemptyString =
    value:
    isString value
    && match "[[:space:]]*" value == null;

  hasLanguageName =
    tag:
    languageNames ? ${tag}
    && nonemptyString languageNames.${tag};

  hasLanguageSample =
    tag:
    languageSamples ? ${tag}
    && isAttrs languageSamples.${tag}
    && nonemptyString (
      languageSamples.${tag}.text or null
    );

  missingLanguages =
    predicate:
    pipe fontCatalog.packages [
      (concatMap (
        package:
        map
          (tag: {
            inherit tag;

            inherit (package)
              attribute
              ;
          })
          (filter (tag: !(predicate tag)) package.languages)
      ))
      (groupBy (entry: entry.tag))
      (mapAttrsToList (
        tag: entries:
        "${tag} (${
          concatStringsSep ", " (
            map (entry: entry.attribute) entries
          )
        })"
      ))
    ];

  missingLanguageNames = missingLanguages hasLanguageName;

  missingLanguageSamples = missingLanguages hasLanguageSample;
in
assert assertMsg (missingLanguageNames == [ ])
  "Missing language names in pages/etc/language-names.json: ${concatStringsSep "; " missingLanguageNames}";
assert assertMsg (missingLanguageSamples == [ ])
  "Missing language samples in pages/etc/language-samples.json: ${concatStringsSep "; " missingLanguageSamples}";
writeText "font-metadata.json" (
  toJSON fontCatalog
)

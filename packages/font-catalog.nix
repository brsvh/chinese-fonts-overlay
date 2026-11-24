{
  pkgs,
  projectRoot,
}:
let
  inherit (pkgs.lib)
    attrNames
    concatMap
    filter
    filterAttrs
    isString
    pathExists
    pipe
    readDir
    toList
    ;

  directories =
    path:
    pipe path [
      readDir
      (filterAttrs (_: type: type == "directory"))
      attrNames
    ];

  metadata = import ./font-metadata.nix {
    inherit (pkgs) lib;
  };

  inherit (metadata) vendors;

  normalizeLicense =
    license:
    if isString license then
      {
        free = null;
        id = license;
        name = license;
        spdxId = null;
        url = null;
      }
    else
      {
        free = license.free or null;
        id =
          license.spdxId or (license.shortName
            or (license.fullName or "unknown")
          );
        name =
          license.fullName or (license.shortName or "未知");
        spdxId = license.spdxId or null;
        url = license.url or null;
      };

  packageEntry =
    vendor: name:
    let
      package = pkgs."${vendor}Packages".${name};
      inherit (package) meta;
      id = "${vendor}.${name}";
      info = metadata.validatePackage "${vendor}Packages.${name}" package;
      redistributable =
        (meta.redistributable or false) == true;
    in
    {
      inherit id redistributable;

      inherit (info)
        displayName
        languages
        licenseCost
        styles
        vendor
        ;

      inherit (package) pname;

      attribute = "${vendor}Packages.${name}";
      description = meta.description or "";
      embedding = info.embedding or redistributable;
      homepages = toList (meta.homepage or [ ]);

      licenses = map normalizeLicense (
        toList (meta.license or [ ])
      );

      longDescription = meta.longDescription or "";
      notices = info.notices or [ ];

      source = {
        path = "packages/${vendor}/${name}/package.nix";
      };

      vendorName = vendors.${info.vendor};
      version = package.version or "";
    };

  vendorEntries =
    vendor:
    let
      directory = projectRoot + "/packages/${vendor}";
      isFontPackage =
        name:
        pathExists (directory + "/${name}/package.nix")
        && !(pkgs."${vendor}Packages".${name}.isFontAggregate
          or false
        );
    in
    pipe directory [
      directories
      (filter isFontPackage)
      (map (packageEntry vendor))
    ];
in
{
  inherit vendors;

  licenseCostLabels = metadata.licenseCosts;
  noticeLevelLabels = metadata.noticeLevels;

  packages = concatMap vendorEntries (
    directories (projectRoot + /packages)
  );

  schema = 2;
  styleLabels = metadata.styles;
}

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
    readDir
    toList
    ;

  directories =
    path:
    attrNames (
      filterAttrs (_: type: type == "directory") (
        readDir path
      )
    );

  fontInfo = import ../lib/font-info.nix {
    inherit (pkgs) lib;
  };

  inherit (fontInfo) vendors;

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
      meta = package.meta;
      id = "${vendor}.${name}";
      info = fontInfo.validate id (
        package.fontInfo or { }
      );
    in
    {
      inherit id;

      inherit (info)
        languages
        licenseCost
        styles
        vendor
        ;

      attribute = "${vendor}Packages.${name}";
      description = meta.description or "";
      homepages = toList (meta.homepage or [ ]);

      licenses = map normalizeLicense (
        toList (meta.license or [ ])
      );

      longDescription = meta.longDescription or "";
      notices = info.notices or [ ];
      pname = package.pname;
      redistributable =
        (meta.redistributable or false) == true;

      source = {
        path = "packages/${vendor}/${name}/package.nix";
      };

      vendorName = vendors.${info.vendor};
      version = package.version or "";
    };
in
{
  inherit vendors;

  licenseCostLabels = fontInfo.licenseCosts;
  noticeLevelLabels = fontInfo.noticeLevels;

  packages = concatMap (
    vendor:
    map (packageEntry vendor) (
      filter
        (
          name:
          pathExists (
            projectRoot
            + "/packages/${vendor}/${name}/package.nix"
          )
          && !(pkgs."${vendor}Packages".${name}.isFontAggregate
            or false
          )
        )
        (
          directories (projectRoot + "/packages/${vendor}")
        )
    )
  ) (directories (projectRoot + /packages));

  schema = 2;
  styleLabels = fontInfo.styles;
}

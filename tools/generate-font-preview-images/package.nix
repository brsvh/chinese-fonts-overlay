{
  coreutils,
  findutils,
  fontconfig,
  git,
  gnused,
  imagemagick,
  lib,
  nix,
  pango,
  writeShellScriptBin,
  writeText,
  ...
}:
let
  inherit (lib)
    concatLists
    concatStringsSep
    licenses
    maintainers
    makeBinPath
    map
    mapAttrsToList
    ;

  fontPreviewSkippedFontNames = { };

  fontPreviewRuntimePackages = [
    coreutils
    findutils
    fontconfig
    git
    gnused
    imagemagick
    nix
    pango
  ];

  fontPreviewSkippedFontRows = concatLists (
    mapAttrsToList (
      scopeName: scope:
      concatLists (
        mapAttrsToList (
          pname: fontNames:
          map (
            fontName:
            concatStringsSep "\t" [
              scopeName
              pname
              fontName
            ]
          ) fontNames
        ) scope
      )
    ) fontPreviewSkippedFontNames
  );

  fontPreviewSkippedFontManifest =
    writeText "font-preview-skipped-fonts.tsv"
      (
        (concatStringsSep "\n" fontPreviewSkippedFontRows)
        + "\n"
      );
in
(writeShellScriptBin "generate-font-preview-images" ''
  set -euo pipefail

  export PATH=${makeBinPath fontPreviewRuntimePackages}

  temporary_files=()
  trap 'rm -f -- "''${temporary_files[@]}"' EXIT

  arabic_sample='أنا أستطيع أكل الزجاج ولا يؤلمني'
  bopomofo_sample='ㄨㄛˇ ㄋㄥˊ ㄊㄨㄣ ㄒㄧㄚˋ ㄅㄛ ˙ㄌㄧ ㄦˊ ㄅㄨˋ ㄕㄤ ㄕㄣ ㄊㄧˇ'
  english_sample='I can eat glass, it does not hurt me'
  devanagari_sample='मैं काँच खा सकता हूँ, मुझे इससे चोट नहीं लगती'
  gurmukhi_sample='ਮੈਂ ਕੱਚ ਖਾ ਸਕਦਾ ਹਾਂ, ਮੈਨੂੰ ਇਸ ਨਾਲ ਸੱਟ ਨਹੀਂ ਲੱਗਦੀ'
  gujarati_sample='હું કાચ ખાઈ શકું છું, તે મને ઈજા કરતું નથી'
  japanese_sample='私はガラスを食べられます。それは私を傷つけません。'
  javanese_sample='Aku bisa mangan kaca tanpa lara'
  khmer_sample='ខ្ញុំអាចញ៉ាំកញ្ចក់បាន វាមិនធ្វើឲ្យខ្ញុំឈឺទេ'
  korean_sample='나는 유리를 먹을 수 있어요. 그래도 아프지 않아요.'
  lao_sample='ຂ້ອຍກິນແກ້ວໄດ້ ມັນບໍ່ເຮັດໃຫ້ຂ້ອຍເຈັບ'
  marlett_sample='E +, "#$% *:'
  math_sample='e^{iπ} + 1 = 0'
  mongolian_sample='ᠪᠢ ᠰᠢᠯᠢ ᠢᠳᠡᠶᠦ ᠴᠢᠳᠠᠨᠠ ᠂ ᠨᠠᠳᠤᠷ ᠬᠣᠤᠷᠠᠳᠠᠢ ᠪᠢᠰᠢ'
  myanmar_sample='ကျွန်တော် ကျွန်မ မှန်စားနိုင်တယ်။ ၎င်းကြောင့် ထိခိုက်မှုမရှိပါ။'
  phagspa_sample='ꡢꡡ ꡋꡦꡃ ꡉꡟꡋ ꡜꡠꡝ ꡎꡡ ꡙꡞ ꡝꡖꡞ ꡎꡟ ꡚꡏ ꡚꡞꡋ ꡉꡞ'
  rare_chinese_sample='𫗦𤥗 𭴊𢦏𦝡'
  segoe_icons_sample=$'\uE726 \uE727 \uE814 \uE95E \uE930'
  segoe_ui_emoji_sample='😋 🪟 → 🙂 ✅'
  segoe_ui_historic_sample='𐌹 𐌺 𓀀 𓂀 𓏏'
  segoe_ui_symbol_sample='☕ ◊ → ☺ ⚕ ✓'
  simplified_sample='我能吞下玻璃而不伤身体'
  symbols_sample='p → ¬q, p ∴ ¬q'
  symbol_legacy_sample='abgde + pq = W'
  tai_le_sample='ᥐᥦᥝᥲ ᥐᥤᥢ ᥘᥭᥲ ᥕᥧᥱ, ᥟᥛᥱ ᥞᥥᥖᥱ ᥞᥬᥲ ᥖᥨᥝ ᥓᥥᥙᥲ'
  tai_lue_sample='ᦅᦵᦂᧁᧉ ᦂᦲᧃ ᦺᦡᧉ ᦢᧈ ᦵᦔᧃ ᦵᦈᧇ ᦎᦷᧅ'
  thai_sample='ฉันกินกระจกได้ แต่มันไม่ทำให้ฉันเจ็บ'
  tibetan_sample='ཤེལ་སྒོ་ཟ་ནས་ང་ན་གི་མ་རེད།'
  traditional_sample='我能吞下玻璃而不傷身體'
  vietnamese_sample='Tôi có thể ăn thủy tinh mà không hại gì.'
  webdings_sample='m 4 c 4 d 4 a'
  wingdings_sample='I E $ E B J C'
  yi_sample='ꉢꋤꇓꅝꇬꑌꇭꀧꀋꌸ'

  usage() {
    printf 'usage: %s [--override] [--package-name pname[,pname...]] [--manifest FILE] [--output-dir DIR]\n' \
      "$(basename -- "$0")" >&2
  }

  project_root() {
    if root=$(git rev-parse --show-toplevel 2>/dev/null); then
      printf '%s\n' "$root"
      return
    fi

    printf '%s\n' \
      'cannot find project root; run inside this repository' >&2
    exit 1
  }

  font_family_name() {
    local font=$1
    local font_file
    local name

    name="$(
      fc-scan --format '%{family}\n' "$font" \
        | sed -n '1{
          s/,.*//
          s#/#-#g
          s/^[[:space:]]*//
          s/[[:space:]]*$//
          p
          q
        }'
    )"

    if [ -z "$name" ]; then
      font_file=$(basename -- "$font")
      name=''${font_file%.*}
    fi

    printf '%s\n' "$name"
  }

  font_style_name() {
    local font=$1

    fc-scan --format '%{style}\n' "$font" \
      | sed -n '1{
        s/,.*//
        s#/#-#g
        s/^[[:space:]]*//
        s/[[:space:]]*$//
        p
        q
      }'
  }

  is_invalid_image() {
    local colors width height
    local image=$1

    read -r colors width height < <(magick identify -format '%k %w %h\n' "$image")
    [ "$colors" -le 1 ] || [ "$width" -le "$height" ]
  }

  render_with_magick() {
    local font=$1
    local output=$2
    local sample=$3

    magick \
      -quiet \
      -background white \
      -fill black \
      -font "$font" \
      -pointsize 64 \
      -gravity center \
      -size 30000x360 \
      "caption:$sample" \
      -trim \
      +repage \
      -resize '1200x360>' \
      -bordercolor white \
      -border 16x16 \
      "$output"
  }

  render_with_pango() {
    local fontconfig_file=$1
    local font_name=$2
    local output=$3
    local pango_image
    local sample=$4

    pango_image=$(mktemp "$(dirname "$output")/.preview-pango.XXXXXX.png")
    temporary_files+=("$pango_image")

    FONTCONFIG_FILE=$fontconfig_file \
      pango-view \
        --no-display \
        --pixels \
        --background=white \
        --foreground=black \
        --font="$font_name 64" \
        --width=30000 \
        --align=center \
        --single-par \
        --output="$pango_image" \
        --text="$sample"

    magick \
      "$pango_image" \
      -trim \
      +repage \
      -resize '1200x360>' \
      -bordercolor white \
      -border 16x16 \
      "$output"

    rm -f "$pango_image"
  }

  choose_sample() {
    local sample_key=$1
    local font_name=''${2:-}

    case "$sample_key" in
      arabic)
        printf '%s\n' "$arabic_sample"
        ;;
      bopomofo)
        printf '%s\n' "$bopomofo_sample"
        ;;
      english)
        printf '%s\n' "$english_sample"
        ;;
      devanagari)
        printf '%s\n' "$devanagari_sample"
        ;;
      gurmukhi)
        printf '%s\n' "$gurmukhi_sample"
        ;;
      gujarati)
        printf '%s\n' "$gujarati_sample"
        ;;
      japanese)
        printf '%s\n' "$japanese_sample"
        ;;
      javanese)
        printf '%s\n' "$javanese_sample"
        ;;
      khmer)
        printf '%s\n' "$khmer_sample"
        ;;
      korean)
        printf '%s\n' "$korean_sample"
        ;;
      lao)
        printf '%s\n' "$lao_sample"
        ;;
      marlett)
        printf '%s\n' "$marlett_sample"
        ;;
      math)
        printf '%s\n' "$math_sample"
        ;;
      mongolian)
        printf '%s\n' "$mongolian_sample"
        ;;
      myanmar)
        printf '%s\n' "$myanmar_sample"
        ;;
      phagspa)
        printf '%s\n' "$phagspa_sample"
        ;;
      rare-chinese)
        printf '%s\n' "$rare_chinese_sample"
        ;;
      segoe-icons)
        printf '%s\n' "$segoe_icons_sample"
        ;;
      segoe-ui-symbols)
        case "$font_name" in
          'Segoe UI Emoji')
            printf '%s\n' "$segoe_ui_emoji_sample"
            ;;
          'Segoe UI Historic')
            printf '%s\n' "$segoe_ui_historic_sample"
            ;;
          *)
            printf '%s\n' "$segoe_ui_symbol_sample"
            ;;
        esac
        ;;
      simplified-chinese)
        printf '%s\n' "$simplified_sample"
        ;;
      symbols)
        printf '%s\n' "$symbols_sample"
        ;;
      symbol-legacy)
        printf '%s\n' "$symbol_legacy_sample"
        ;;
      tai-le)
        printf '%s\n' "$tai_le_sample"
        ;;
      tai-lue)
        printf '%s\n' "$tai_lue_sample"
        ;;
      southeast-asian)
        printf '%s\n%s\n' "$thai_sample" "$vietnamese_sample"
        ;;
      thai)
        printf '%s\n' "$thai_sample"
        ;;
      tibetan)
        printf '%s\n' "$tibetan_sample"
        ;;
      traditional-chinese)
        printf '%s\n' "$traditional_sample"
        ;;
      vietnamese)
        printf '%s\n' "$vietnamese_sample"
        ;;
      webdings)
        printf '%s\n' "$webdings_sample"
        ;;
      wingdings)
        printf '%s\n' "$wingdings_sample"
        ;;
      yi)
        printf '%s\n' "$yi_sample"
        ;;
      *)
        printf 'unknown font preview sample key: %s\n' "$sample_key" >&2
        exit 1
        ;;
    esac
  }

  declare -A skipped_font_names=()

  while IFS=$'\t' read -r skipped_scope skipped_pname skipped_font_name; do
    skipped_font_names["$skipped_scope"$'\t'"$skipped_pname"$'\t'"$skipped_font_name"]=1
  done < ${fontPreviewSkippedFontManifest}

  should_skip_font() {
    local font_name=$3
    local key
    local pname=$2
    local scope=$1

    key="$scope"$'\t'"$pname"$'\t'"$font_name"

    [ "''${skipped_font_names[$key]+set}" = set ]
  }

  override=false
  manifest=
  output_dir=
  declare -A selected_package_names=()
  package_name_filter=false

  add_package_names() {
    local name
    local -a package_name_items
    local package_names=$1

    if [ -z "$package_names" ]; then
      printf 'empty --package-name value\n' >&2
      exit 2
    fi

    IFS=, read -r -a package_name_items <<< "$package_names"

    for name in "''${package_name_items[@]}"; do
      if [ -z "$name" ]; then
        printf 'empty package name in --package-name value: %s\n' \
          "$package_names" >&2
        exit 2
      fi

      selected_package_names["$name"]=0
    done

    package_name_filter=true
  }

  should_generate_package() {
    local pname=$1

    if [ "$package_name_filter" = false ]; then
      return 0
    fi

    if [ "''${selected_package_names[$pname]+set}" = set ]; then
      selected_package_names["$pname"]=1
      return 0
    fi

    return 1
  }

  validate_package_name_filter() {
    local manifest=$1
    local package
    local pname
    local sample_key
    local scope

    if [ "$package_name_filter" = false ]; then
      return
    fi

    while IFS=$'\t' read -r scope pname sample_key package; do
      if [ "''${selected_package_names[$pname]+set}" != set ]; then
        continue
      fi

      selected_package_names["$pname"]=1

      if [ "$sample_key" = "__missing_sample_key__" ]; then
        printf 'font preview sample key is not configured for %s.%s\n' \
          "$scope" "$pname" >&2
        exit 1
      fi
    done < "$manifest"

    for pname in "''${!selected_package_names[@]}"; do
      if [ "''${selected_package_names[$pname]}" = 0 ]; then
        printf 'unknown font preview package name: %s\n' "$pname" >&2
        exit 1
      fi
    done
  }

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --manifest|--output-dir)
        if [ "$#" -lt 2 ] || [ -z "$2" ]; then
          usage
          exit 2
        fi
        if [ "$1" = --manifest ]; then
          manifest=$2
        else
          output_dir=$2
        fi
        shift 2
        ;;
      --override)
        override=true
        shift
        ;;
      --package-name)
        if [ "$#" -lt 2 ]; then
          usage
          exit 2
        fi

        add_package_names "$2"
        shift 2
        ;;
      --package-name=*)
        add_package_names "''${1#--package-name=}"
        shift
        ;;
      *)
        usage
        exit 2
        ;;
    esac
  done

  if [ -z "$manifest" ]; then
    if [ "$package_name_filter" = false ]; then
      printf 'select packages with --package-name or provide --manifest\n' >&2
      exit 2
    fi
    manifest=$(mktemp)
    temporary_files+=("$manifest")
    package_names=$(IFS=,; printf '%s' "''${!selected_package_names[*]}")
    nix run --no-update-lock-file --no-write-lock-file \
      --option accept-flake-config false \
      --option allow-import-from-derivation false \
      --option builders "" "$(project_root)#font-ci" -- preview-manifest \
      --root "$(project_root)" --package-name "$package_names" --output "$manifest"
  fi

  if [ ! -s "$manifest" ]; then
    printf 'empty font manifest\n' >&2
    exit 1
  fi
  validate_package_name_filter "$manifest"

  if [ -z "$output_dir" ]; then
    output_dir=$(project_root)/font-preview-images
  fi
  mkdir -p "$output_dir"
  declare -A image_counts=()

  while IFS=$'\t' read -r scope pname sample_key package; do
    if ! should_generate_package "$pname"; then
      continue
    fi

    if [[ ! "$scope" =~ ^[a-z0-9][a-z0-9_-]*$ ]] \
      || [[ ! "$pname" =~ ^[a-z0-9][a-z0-9_+-]*$ ]] \
      || [[ ! "$sample_key" =~ ^[a-z0-9-]+$ ]] \
      || [[ ! "$package" =~ ^/nix/store/[0-9a-df-np-sv-z]{32}-[^/[:space:]]+$ ]]; then
      printf 'invalid font manifest row\n' >&2
      exit 1
    fi
    fonts_dir=$package/share/fonts
    scope_dir=$output_dir/$scope

    if [ "$sample_key" = "__missing_sample_key__" ]; then
      printf 'font preview sample key is not configured for %s.%s\n' \
        "$scope" "$pname" >&2
      exit 1
    fi

    if [ ! -d "$fonts_dir" ]; then
      printf 'missing font directory: %s\n' "$fonts_dir" >&2
      exit 1
    fi

    mkdir -p "$scope_dir"

    fontconfig_file=$(mktemp "$scope_dir/.fontconfig.XXXXXX.conf")
    temporary_files+=("$fontconfig_file")
    {
      printf '%s\n' '<?xml version="1.0"?>'
      printf '%s\n' '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">'
      printf '%s\n' '<fontconfig>'
      printf '  <dir>%s</dir>\n' "$fonts_dir"
      printf '%s\n' '</fontconfig>'
    } > "$fontconfig_file"

    declare -A family_counts=()
    font_paths=()
    font_names=()
    font_styles=()

    while IFS= read -r -d "" font; do
      font_name=$(font_family_name "$font")
      font_paths+=("$font")
      font_names+=("$font_name")
      font_styles+=("$(font_style_name "$font")")
      family_counts["$font_name"]=$(( ''${family_counts[$font_name]:-0} + 1 ))
    done < <(
      find -L "$fonts_dir" \
        -type f \
        \( -iname '*.otf' -o -iname '*.otc' -o -iname '*.ttf' -o -iname '*.ttc' \) \
        -print0 | sort -z
    )

    if [ "''${#font_paths[@]}" -eq 0 ]; then
      printf 'no font files in %s\n' "$fonts_dir" >&2
      exit 1
    fi

    expected=0
    validated=0
    for index in "''${!font_paths[@]}"; do
      font=''${font_paths[$index]}
      font_name=''${font_names[$index]}
      font_style=''${font_styles[$index]}

      if [ "''${family_counts[$font_name]}" -gt 1 ] && [ -n "$font_style" ]; then
        font_name="$font_name $font_style"
      fi

      if should_skip_font "$scope" "$pname" "$font_name"; then
        continue
      fi

      expected=$((expected + 1))
      image=$scope_dir/$pname+$font_name.png
      image_key=$scope/$pname+$font_name
      image_count=''${image_counts[$image_key]:-0}
      image_counts["$image_key"]=$((image_count + 1))

      if [ "$image_count" -gt 0 ]; then
        image=$scope_dir/$pname+$font_name-$((image_count + 1)).png
      fi

      if [ "$override" = false ] && [ -e "$image" ]; then
        if is_invalid_image "$image"; then
          printf 'invalid existing preview: %s\n' "$image" >&2
          exit 1
        fi
        validated=$((validated + 1))
        continue
      fi

      sample=$(choose_sample "$sample_key" "$font_name")
      temporary_image=$(mktemp "$scope_dir/.preview.XXXXXX.png")

      temporary_files+=("$temporary_image")
      if ! render_with_magick "$font" "$temporary_image" "$sample" \
        || is_invalid_image "$temporary_image"; then
        rm -f "$temporary_image"
        temporary_image=$(mktemp "$scope_dir/.preview.XXXXXX.png")
        temporary_files+=("$temporary_image")
        render_with_pango \
          "$fontconfig_file" \
          "$font_name" \
          "$temporary_image" \
          "$sample"
      fi

      if is_invalid_image "$temporary_image"; then
        printf 'invalid rendered preview: %s\n' "$font" >&2
        exit 1
      fi

      magick "$temporary_image" -strip -depth 8 \
        -define png:exclude-chunk=all "PNG24:$temporary_image"
      mv -f "$temporary_image" "$image"
      validated=$((validated + 1))

      printf '%s\n' "$image"
    done

    if [ "$expected" -eq 0 ] || [ "$validated" -ne "$expected" ]; then
      printf 'preview count mismatch for %s: %s/%s\n' "$pname" "$validated" "$expected" >&2
      exit 1
    fi
    rm -f "$fontconfig_file"
  done < "$manifest"
'').overrideAttrs
  (_: {
    meta = {
      description = "Generate preview PNGs for Chinese font packages";
      license = licenses.cc0;
      mainProgram = "generate-font-preview-images";
      maintainers = with maintainers; [ brsvh ];
    };

  })

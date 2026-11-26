/* Font language scanner using pinned Fontconfig and FreeType interfaces.  */

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_CID_H
#include FT_TRUETYPE_TABLES_H

#include <fontconfig/fontconfig.h>

#include <fontconfig/fcfreetype.h>

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum exclusive_lang
{
  EXCLUSIVE_NONE = 0,
  EXCLUSIVE_JA,
  EXCLUSIVE_ZH_CN,
  EXCLUSIVE_KO,
  EXCLUSIVE_ZH_TW
};

/* Owned Fontconfig charsets used for orthography supplements.  */
struct orth_sets
{
  FcCharSet *zh_cn_excluded;
  FcCharSet *zh_cn_required;
  FcCharSet *ko_excluded;
  FcCharSet *ko_required;
};

/* Compare two pointers to NUL-terminated strings for qsort.  */
static int
compare_cstrings (const void *left, const void *right)
{
  const char *const *a = left;
  const char *const *b = right;

  return strcmp (*a, *b);
}

/* Write UTF-8 TEXT as a JSON string literal to stdout.  */
static void
write_json_string (const char *text)
{
  putchar ('"');

  for (const unsigned char *p = (const unsigned char *)text; *p; p++)
    {
      switch (*p)
        {
        case '"':
          fputs ("\\\"", stdout);
          break;

        case '\\':
          fputs ("\\\\", stdout);
          break;

        case '\b':
          fputs ("\\b", stdout);
          break;

        case '\f':
          fputs ("\\f", stdout);
          break;

        case '\n':
          fputs ("\\n", stdout);
          break;

        case '\r':
          fputs ("\\r", stdout);
          break;

        case '\t':
          fputs ("\\t", stdout);
          break;

        default:
          if (*p < 0x20)
            printf ("\\u%04x", (unsigned int)*p);
          else
            putchar (*p);
        }
    }

  putchar ('"');
}

/* Release all owned charsets in ORTH and clear its fields.  */
static void
destroy_orth_sets (struct orth_sets *orth)
{
  if (orth->zh_cn_excluded)
    FcCharSetDestroy (orth->zh_cn_excluded);
  if (orth->zh_cn_required)
    FcCharSetDestroy (orth->zh_cn_required);
  if (orth->ko_excluded)
    FcCharSetDestroy (orth->ko_excluded);
  if (orth->ko_required)
    FcCharSetDestroy (orth->ko_required);

  *orth = (struct orth_sets){ 0 };
}

/* Populate ORTH with zh-cn and ko supplement charsets from Fontconfig's
   built-in orthographies.  Fontconfig's zh-cn.orth (shared by zh-sg.orth)
   includes U+02C7 and U+02C9 alongside GB 2312-80 Hanzi, and ko.orth includes
   archaic compatibility jamo U+3165-U+318E.  Return true on success.  */
static bool
build_orth_sets (struct orth_sets *orth)
{
  *orth = (struct orth_sets){ 0 };

  const FcCharSet *zh_cn_orth = FcLangGetCharSet ((const FcChar8 *)"zh-cn");
  const FcCharSet *ko_orth = FcLangGetCharSet ((const FcChar8 *)"ko");

  if (!zh_cn_orth || !ko_orth)
    {
      fputs ("Fontconfig is missing zh-cn or ko orthography data\n", stderr);
      return false;
    }

  orth->zh_cn_excluded = FcCharSetCreate ();
  orth->ko_excluded = FcCharSetCreate ();

  if (!orth->zh_cn_excluded || !orth->ko_excluded)
    goto fail;

  if (!FcCharSetAddChar (orth->zh_cn_excluded, 0x02c7)
      || !FcCharSetAddChar (orth->zh_cn_excluded, 0x02c9))
    goto fail;

  for (FcChar32 cp = 0x3165; cp <= 0x318e; cp++)
    {
      if (!FcCharSetAddChar (orth->ko_excluded, cp))
        goto fail;
    }

  orth->zh_cn_required = FcCharSetSubtract (zh_cn_orth, orth->zh_cn_excluded);
  orth->ko_required = FcCharSetSubtract (ko_orth, orth->ko_excluded);

  if (!orth->zh_cn_required || !orth->ko_required)
    goto fail;

  return true;

fail:
  destroy_orth_sets (orth);
  fputs ("Failed to allocate Fontconfig orthography charsets\n", stderr);
  return false;
}

/* Determine Fontconfig's CJK exclusive language for FACE_INDEX in PATH,
   following Fontconfig's CID ordering and OS/2 ulCodePageRange1 rules.
   Write the result to OUT_LANG and return true on success.  */
static bool
face_exclusive_lang (FT_Library ft_library, const char *path,
                     FT_Long face_index, enum exclusive_lang *out_lang)
{
  FT_Face face = NULL;

  if (FT_New_Face (ft_library, path, face_index, &face) != 0)
    {
      fprintf (stderr, "FreeType failed to open face %ld in %s\n", face_index,
               path);
      return false;
    }

  enum exclusive_lang result = EXCLUSIVE_NONE;
  const char *registry = NULL;
  const char *ordering = NULL;
  FT_Int supplement = 0;

  if (FT_Get_CID_Registry_Ordering_Supplement (face, &registry, &ordering,
                                               &supplement)
          == 0
      && ordering != NULL)
    {
      if (strcmp (ordering, "GB1") == 0)
        result = EXCLUSIVE_ZH_CN;
      else if (strcmp (ordering, "CNS1") == 0)
        result = EXCLUSIVE_ZH_TW;
      else if (strcmp (ordering, "Japan1") == 0)
        result = EXCLUSIVE_JA;
      else if (strcmp (ordering, "Korea1") == 0)
        result = EXCLUSIVE_KO;
    }

  if (result == EXCLUSIVE_NONE)
    {
      const TT_OS2 *os2 = FT_Get_Sfnt_Table (face, FT_SFNT_OS2);

      if (os2 != NULL && os2->version >= 1 && os2->version != 0xffff)
        {
          uint32_t cpr1 = (uint32_t)os2->ulCodePageRange1;
          bool has_ja = (cpr1 & (1u << 17)) != 0;
          bool has_zh_cn = (cpr1 & (1u << 18)) != 0;
          bool has_ko = (cpr1 & ((1u << 19) | (1u << 21))) != 0;
          bool has_zh_tw = (cpr1 & (1u << 20)) != 0;
          unsigned int count = (unsigned int)has_ja + (unsigned int)has_zh_cn
                               + (unsigned int)has_ko
                               + (unsigned int)has_zh_tw;

          if (count == 1)
            {
              if (has_ja)
                result = EXCLUSIVE_JA;
              else if (has_zh_cn)
                result = EXCLUSIVE_ZH_CN;
              else if (has_ko)
                result = EXCLUSIVE_KO;
              else
                result = EXCLUSIVE_ZH_TW;
            }
        }
    }

  FT_Done_Face (face);
  *out_lang = result;
  return true;
}

/* Add zh-cn/zh-sg and ko supplements to LANG_SET when CS covers the required
   orthography subset, misses at least one exempted code point, and EXCLUSIVE
   does not forbid the language.  Return true on success.  */
static bool
apply_supplements (FcLangSet *lang_set, const FcCharSet *cs,
                   enum exclusive_lang exclusive, const struct orth_sets *orth)
{
  if (!cs)
    return true;

  if (!FcCharSetIsSubset (orth->zh_cn_excluded, cs)
      && FcCharSetIsSubset (orth->zh_cn_required, cs))
    {
      if (!FcLangSetAdd (lang_set, (const FcChar8 *)"zh-sg"))
        return false;

      if ((exclusive == EXCLUSIVE_NONE || exclusive == EXCLUSIVE_ZH_CN)
          && !FcLangSetAdd (lang_set, (const FcChar8 *)"zh-cn"))
        return false;
    }

  if (!FcCharSetIsSubset (orth->ko_excluded, cs)
      && FcCharSetIsSubset (orth->ko_required, cs)
      && (exclusive == EXCLUSIVE_NONE || exclusive == EXCLUSIVE_KO))
    {
      if (!FcLangSetAdd (lang_set, (const FcChar8 *)"ko"))
        return false;
    }

  return true;
}

/* Write LANG_SET as a sorted JSON array of unique language tags to stdout.
   Return true on success.  */
static bool
write_lang_set_json (const FcLangSet *lang_set)
{
  FcStrSet *langs = FcLangSetGetLangs (lang_set);

  if (!langs)
    {
      fputs ("Failed to extract language tags from FcLangSet\n", stderr);
      return false;
    }

  FcStrList *list = FcStrListCreate (langs);

  if (!list)
    {
      FcStrSetDestroy (langs);
      fputs ("Failed to iterate language tags\n", stderr);
      return false;
    }

  size_t capacity = 32;
  size_t count = 0;
  const char **items = malloc (capacity * sizeof *items);

  if (!items)
    {
      FcStrListDone (list);
      FcStrSetDestroy (langs);
      fputs ("Out of memory collecting language tags\n", stderr);
      return false;
    }

  FcChar8 *tag = NULL;

  while ((tag = FcStrListNext (list)) != NULL)
    {
      if (count == capacity)
        {
          if (capacity > SIZE_MAX / 2 / sizeof *items)
            {
              free (items);
              FcStrListDone (list);
              FcStrSetDestroy (langs);
              fputs ("Language tag list overflow\n", stderr);
              return false;
            }

          capacity *= 2;
          const char **grown = realloc (items, capacity * sizeof *items);

          if (!grown)
            {
              free (items);
              FcStrListDone (list);
              FcStrSetDestroy (langs);
              fputs ("Out of memory growing language tag list\n", stderr);
              return false;
            }

          items = grown;
        }

      items[count++] = (const char *)tag;
    }

  if (count > 1)
    qsort (items, count, sizeof *items, compare_cstrings);

  putchar ('[');

  for (size_t i = 0; i < count; i++)
    {
      if (i > 0)
        putchar (',');
      write_json_string (items[i]);
    }

  putchar (']');

  free (items);
  FcStrListDone (list);
  FcStrSetDestroy (langs);
  return true;
}

/* Emit a single face object from PAT to stdout.  Return true on success.  */
static bool
write_face_json (FcPattern *pat, int fc_index, enum exclusive_lang exclusive,
                 const struct orth_sets *orth, const char *path)
{
  FcChar8 *family = NULL;
  FcResult family_res = FcPatternGetString (pat, FC_FAMILY, 0, &family);

  if (family_res != FcResultMatch && family_res != FcResultNoMatch)
    {
      fprintf (stderr, "Invalid family property in %s\n", path);
      return false;
    }

  FcChar8 *style = NULL;
  FcResult style_res = FcPatternGetString (pat, FC_STYLE, 0, &style);

  if (style_res != FcResultMatch && style_res != FcResultNoMatch)
    {
      fprintf (stderr, "Invalid style property in %s\n", path);
      return false;
    }

  FcLangSet *pat_langs = NULL;
  FcResult lang_res = FcPatternGetLangSet (pat, FC_LANG, 0, &pat_langs);
  FcLangSet *langs = NULL;

  if (lang_res == FcResultMatch)
    langs = FcLangSetCopy (pat_langs);
  else if (lang_res == FcResultNoMatch)
    langs = FcLangSetCreate ();
  else
    {
      fprintf (stderr, "Invalid lang property in %s\n", path);
      return false;
    }

  if (!langs)
    {
      fputs ("Failed to allocate FcLangSet\n", stderr);
      return false;
    }

  FcCharSet *cs = NULL;
  FcResult cs_res = FcPatternGetCharSet (pat, FC_CHARSET, 0, &cs);

  if (cs_res != FcResultMatch && cs_res != FcResultNoMatch)
    {
      FcLangSetDestroy (langs);
      fprintf (stderr, "Invalid charset property in %s\n", path);
      return false;
    }

  if (!apply_supplements (langs, cs_res == FcResultMatch ? cs : NULL,
                          exclusive, orth))
    {
      FcLangSetDestroy (langs);
      fprintf (stderr, "Failed to update language set for %s\n", path);
      return false;
    }

  printf ("{\"index\":%d,\"family\":", fc_index);
  write_json_string (family ? (const char *)family : "");
  fputs (",\"style\":", stdout);
  write_json_string (style ? (const char *)style : "");
  fputs (",\"languages\":", stdout);

  bool ok = write_lang_set_json (langs);
  FcLangSetDestroy (langs);

  if (!ok)
    return false;

  putchar ('}');
  return true;
}

/* Scan all faces and named instances in PATH and write JSON to stdout.  */
static int
scan_file (const char *path)
{
  int status = EXIT_FAILURE;
  FcConfig *config = FcInitLoadConfig ();
  struct orth_sets orth = { 0 };
  FT_Library ft_library = NULL;
  FcFontSet *fs = NULL;

  if (!config || !FcConfigSetCurrent (config))
    {
      fputs ("Failed to initialize Fontconfig configuration\n", stderr);
      if (config)
        FcConfigDestroy (config);
      goto cleanup;
    }

  FcConfigDestroy (config);
  config = NULL;

  if (!build_orth_sets (&orth))
    goto cleanup;

  if (FT_Init_FreeType (&ft_library) != 0)
    {
      fputs ("Failed to initialize FreeType\n", stderr);
      goto cleanup;
    }

  fs = FcFontSetCreate ();

  if (!fs)
    {
      fputs ("Failed to allocate FcFontSet\n", stderr);
      goto cleanup;
    }

  FcFreeTypeQueryAll ((const FcChar8 *)path, (unsigned int)-1, NULL, NULL, fs);

  if (fs->nfont <= 0)
    {
      fprintf (stderr, "Fontconfig returned no faces: %s\n", path);
      goto cleanup;
    }

  putchar ('[');

  FT_Long cached_base = -1;
  enum exclusive_lang cached_exclusive = EXCLUSIVE_NONE;

  for (int i = 0; i < fs->nfont; i++)
    {
      FcPattern *pat = fs->fonts[i];
      int fc_index = 0;

      if (FcPatternGetInteger (pat, FC_INDEX, 0, &fc_index) != FcResultMatch
          || fc_index < 0)
        {
          fprintf (stderr, "Missing or invalid face index in %s\n", path);
          goto cleanup;
        }

      FT_Long base_index = (FT_Long)(fc_index & 0xffff);

      if (base_index != cached_base)
        {
          if (!face_exclusive_lang (ft_library, path, base_index,
                                    &cached_exclusive))
            goto cleanup;
          cached_base = base_index;
        }

      if (i > 0)
        putchar (',');

      if (!write_face_json (pat, fc_index, cached_exclusive, &orth, path))
        goto cleanup;
    }

  fputs ("]\n", stdout);

  if (fflush (stdout) != 0 || ferror (stdout))
    {
      fputs ("Failed to write scan output\n", stderr);
      goto cleanup;
    }

  status = EXIT_SUCCESS;

cleanup:
  if (fs)
    FcFontSetDestroy (fs);
  if (ft_library)
    FT_Done_FreeType (ft_library);
  destroy_orth_sets (&orth);
  FcFini ();
  return status;
}

int
main (int argc, char **argv)
{
  if (argc != 2)
    {
      fputs ("Usage: chinese-fonts-overlay-scan-font [--version | FILE]\n",
             stderr);
      return EXIT_FAILURE;
    }

  if (strcmp (argv[1], "--version") == 0)
    {
      int version = FcGetVersion ();

      printf ("fontconfig version %d.%d.%d\n", version / 10000,
              (version / 100) % 100, version % 100);
      return fflush (stdout) == 0 && !ferror (stdout) ? EXIT_SUCCESS
                                                      : EXIT_FAILURE;
    }

  return scan_file (argv[1]);
}

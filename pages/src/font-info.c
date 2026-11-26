/* Font and WebP inspection for the Guile build tools.  */

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_MULTIPLE_MASTERS_H
#include FT_SFNT_NAMES_H
#include FT_TRUETYPE_TABLES_H
#include <glib.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <webp/decode.h>

/* Report MESSAGE and PATH on stderr and return EXIT_FAILURE.  */
static int
report_error (const char *message, const char *path)
{
  fprintf (stderr, "%s: %s\n", message, path);
  return EXIT_FAILURE;
}

/* Write borrowed UTF-8 TEXT as an escaped Scheme string on stdout.  */
static void
write_scheme_string (const char *text)
{
  putchar ('"');

  for (const unsigned char *c = (const unsigned char *)text; *c; c++)
    {
      switch (*c)
        {
        case '"':
          fputs ("\\\"", stdout);
          break;

        case '\\':
          fputs ("\\\\", stdout);
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
          if (*c < 32)
            printf ("\\x%02x", *c);
          else
            putchar (*c);
        }
    }

  putchar ('"');
}

/* Decode name ID from borrowed FACE, stopping at an English Mac or US record.
   Return an owned UTF-8 string to be released with g_free, or NULL when no
   supported record can be decoded.  */
static char *
read_sfnt_name (FT_Face face, unsigned id)
{
  char *result = NULL;

  for (FT_UInt i = 0; i < FT_Get_Sfnt_Name_Count (face); i++)
    {
      FT_SfntName entry;

      if (FT_Get_Sfnt_Name (face, i, &entry) || entry.name_id != id)
        continue;

      const char *encoding = NULL;

      if (entry.platform_id == 0 || entry.platform_id == 3)
        encoding = "UTF-16BE";
      else if (entry.platform_id == 1)
        {
          switch (entry.encoding_id)
            {
            case 0:
              encoding = "MACINTOSH";
              break;

            case 1:
              encoding = "SHIFT_JIS";
              break;

            case 2:
              encoding = "BIG5";
              break;

            case 3:
              encoding = "EUC-KR";
              break;

            case 25:
              encoding = "GB2312";
              break;
            }
        }

      if (!encoding || !entry.string || entry.string_len == 0
          || entry.string_len > (FT_UInt)INT_MAX)
        continue;

      char *decoded
          = g_convert ((const char *)entry.string, (gssize)entry.string_len,
                       "UTF-8", encoding, NULL, NULL, NULL);

      if (!decoded || !*decoded)
        {
          g_free (decoded);
          continue;
        }

      g_free (result);
      result = decoded;

      if ((entry.platform_id == 1 && entry.language_id == 0)
          || (entry.platform_id == 3 && entry.language_id == 0x409))
        break;
    }

  return result;
}

/* Write a string-valued alist field using borrowed KEY and VALUE.  */
static void
write_string_field (const char *key, const char *value)
{
  putchar ('(');
  write_scheme_string (key);
  fputs (" . ", stdout);
  write_scheme_string (value);
  fputs (")\n", stdout);
}

/* Write variation coordinates from borrowed VAR and VALUES as an alist.
   NULL VALUES selects axis defaults; NULL VAR denotes a static font.  */
static void
write_variation_coordinates (FT_MM_Var *var, FT_Fixed *values)
{
  putchar ('(');

  if (var)
    for (FT_UInt i = 0; i < var->num_axis; i++)
      {
        FT_ULong tag = var->axis[i].tag;
        char text[5] = { (char)(tag >> 24), (char)(tag >> 16),
                         (char)(tag >> 8), (char)tag, 0 };

        putchar ('(');
        write_scheme_string (text);
        fputs (" . ", stdout);

        double value = (values ? values[i] : var->axis[i].def) / 65536.0;

        if (value == (long)value)
          printf ("%.1f", value);
        else
          printf ("%.17g", value);
        putchar (')');
      }

  putchar (')');
}

/* Write Unicode coverage from borrowed FACE, including symbol cmap aliases.
   This changes FACE's selected charmap while enumerating its characters.  */
static void
write_character_coverage (FT_Face face)
{
  /* Match the preferred Unicode cmap order used by the former FontTools
     reader.  */
  const unsigned order[][2] = { { 3, 10 }, { 0, 6 }, { 0, 4 }, { 3, 1 },
                                { 0, 3 },  { 0, 2 }, { 0, 1 }, { 0, 0 } };
  FT_CharMap selected = NULL;

  for (size_t i = 0; !selected && i < G_N_ELEMENTS (order); i++)
    for (int j = 0; j < face->num_charmaps; j++)
      if (face->charmaps[j]->platform_id == order[i][0]
          && face->charmaps[j]->encoding_id == order[i][1])
        {
          selected = face->charmaps[j];
          break;
        }

  int symbol = 0;

  if (selected)
    {
      FT_UInt glyph = 0;

      if (!FT_Set_Charmap (face, selected))
        FT_Get_First_Char (face, &glyph);

      if (!glyph)
        selected = NULL;
    }

  if (!selected)
    for (int i = 0; i < face->num_charmaps; i++)
      if (face->charmaps[i]->platform_id == 3
          && face->charmaps[i]->encoding_id == 0)
        {
          selected = face->charmaps[i];
          symbol = 1;
          break;
        }

  fputs ("(\"characters\" . (", stdout);

  if (selected && !FT_Set_Charmap (face, selected))
    {
      FT_UInt glyph;
      FT_ULong cp = FT_Get_First_Char (face, &glyph);

      while (glyph)
        {
          printf ("%lu ", cp);
          if (symbol && cp >= 0xf000 && cp < 0xf100)
            printf ("%lu ", cp - 0xf000);
          cp = FT_Get_Next_Char (face, cp, &glyph);
        }
    }

  fputs ("))\n", stdout);
}

/* Inspect all faces and named instances in PATH and write Scheme data.
   Resources belong to this operation; return 0 on success or EXIT_FAILURE.  */
static int
inspect (const char *path)
{
  int status = EXIT_FAILURE;
  FT_Library library = NULL;
  FT_Face face = NULL;
  FILE *input = NULL;
  FT_MM_Var *var = NULL;
  char *family = NULL;
  char *style = NULL;
  char *full = NULL;

  if (FT_Init_FreeType (&library))
    return report_error ("Cannot initialize FreeType", path);
  if (FT_New_Face (library, path, -1, &face))
    {
      report_error ("Cannot open font", path);
      goto cleanup;
    }

  FT_Long count = face->num_faces;
  if (count <= 0)
    {
      report_error ("Font contains no faces", path);
      goto cleanup;
    }

  unsigned char magic[4] = { 0 };
  input = fopen (path, "rb");

  if (!input || fread (magic, 1, sizeof magic, input) != sizeof magic)
    {
      report_error ("Cannot read font header", path);
      goto cleanup;
    }

  fclose (input);
  input = NULL;

  int collection = !memcmp (magic, "ttcf", 4);

  FT_Done_Face (face);
  face = NULL;

  putchar ('(');

  for (FT_Long index = 0; index < count; index++)
    {
      if (FT_New_Face (library, path, index, &face))
        {
          report_error ("Cannot open collection member", path);
          goto cleanup;
        }

      family = read_sfnt_name (face, 16);

      if (!family)
        family = read_sfnt_name (face, 1);
      if (!family)
        {
          family = g_path_get_basename (path);
          char *extension = strrchr (family, '.');

          if (extension)
            *extension = '\0';
        }

      style = read_sfnt_name (face, 17);

      if (!style)
        style = read_sfnt_name (face, 2);
      if (!style)
        style = g_strdup ("Regular");

      full = read_sfnt_name (face, 4);

      if (!full)
        full = g_strdup_printf ("%s %s", family, style);

      TT_OS2 *os2 = FT_Get_Sfnt_Table (face, ft_sfnt_os2);
      TT_Header *head = FT_Get_Sfnt_Table (face, ft_sfnt_head);

      printf ("((\"index\" . %ld)(\"collection\" . %s)(\"weight\" . %u)\n",
              index, collection ? "#t" : "#f", os2 ? os2->usWeightClass : 400);
      write_string_field ("family", family);
      write_string_field ("fullName", full);
      write_string_field ("style",
                          head && (head->Mac_Style & 2) ? "italic" : "normal");
      write_character_coverage (face);

      if (FT_HAS_MULTIPLE_MASTERS (face) && FT_Get_MM_Var (face, &var))
        {
          report_error ("Cannot read variable axes", path);
          goto cleanup;
        }

      fputs ("(\"variants\" . (", stdout);
      fputs ("((\"name\" . ", stdout);
      write_scheme_string (style);
      fputs (")(\"coordinates\" . ", stdout);
      write_variation_coordinates (var, NULL);
      fputs ("))", stdout);

      if (var)
        for (FT_UInt i = 0; i < var->num_namedstyles; i++)
          {
            char *label = read_sfnt_name (face, var->namedstyle[i].strid);

            if (!label)
              label = g_strdup_printf ("Instance %u", i + 1);

            fputs ("((\"name\" . ", stdout);
            write_scheme_string (label);
            fputs (")(\"coordinates\" . ", stdout);
            write_variation_coordinates (var, var->namedstyle[i].coords);
            fputs ("))", stdout);

            g_free (label);
          }

      fputs (")))\n", stdout);

      if (var)
        {
          FT_Done_MM_Var (library, var);
          var = NULL;
        }
      g_clear_pointer (&family, g_free);
      g_clear_pointer (&style, g_free);
      g_clear_pointer (&full, g_free);
      FT_Done_Face (face);
      face = NULL;
    }

  puts (")");
  status = 0;

cleanup:
  if (var)
    FT_Done_MM_Var (library, var);
  g_free (family);
  g_free (style);
  g_free (full);
  if (face)
    FT_Done_Face (face);
  if (input)
    fclose (input);
  if (library)
    FT_Done_FreeType (library);
  return status;
}

/* Validate a nonblank horizontal lossless WebP with transparent borders at
   PATH.  Write its pixel dimensions as a Scheme vector, or return
   EXIT_FAILURE.  */
static int
image_info (const char *path)
{
  int status = EXIT_FAILURE;
  gchar *contents = NULL;
  gsize length = 0;
  GError *error = NULL;
  uint8_t *data = NULL;
  WebPBitstreamFeatures features;

  if (!g_file_get_contents (path, &contents, &length, &error))
    {
      report_error (error->message, path);
      goto cleanup;
    }

  const uint8_t *encoded = (const uint8_t *)contents;
  if (WebPGetFeatures (encoded, length, &features) != VP8_STATUS_OK)
    {
      report_error ("Invalid WebP", path);
      goto cleanup;
    }
  if (features.has_animation || features.format != 2)
    {
      report_error ("Expected static lossless WebP", path);
      goto cleanup;
    }

  int width = features.width;
  int height = features.height;

  if (width <= height || height <= 0)
    {
      report_error ("Expected horizontal WebP", path);
      goto cleanup;
    }
  if (!features.has_alpha)
    {
      report_error ("Expected transparent WebP", path);
      goto cleanup;
    }

  int decoded_width = 0;
  int decoded_height = 0;
  data = WebPDecodeRGBA (encoded, length, &decoded_width, &decoded_height);
  g_clear_pointer (&contents, g_free);
  if (!data || decoded_width != width || decoded_height != height)
    {
      report_error ("Invalid WebP pixels", path);
      goto cleanup;
    }

  unsigned min[3] = { 255, 255, 255 };
  unsigned max[3] = { 0, 0, 0 };

  for (int y = 0; y < height; y++)
    for (int x = 0; x < width; x++)
      {
        const uint8_t *pixel = data + ((size_t)y * width + x) * 4;
        unsigned alpha = pixel[3];

        if ((x == 0 || y == 0 || x == width - 1 || y == height - 1) && alpha)
          {
            report_error ("Expected transparent WebP borders", path);
            goto cleanup;
          }

        for (int i = 0; i < 3; i++)
          {
            unsigned channel = (pixel[i] * alpha + 127) / 255 + 255 - alpha;
            min[i] = MIN (min[i], channel);
            max[i] = MAX (max[i], channel);
          }
      }

  if (min[0] == max[0] && min[1] == max[1] && min[2] == max[2])
    {
      report_error ("Expected nonblank WebP", path);
      goto cleanup;
    }

  printf ("#(%d %d)\n", width, height);
  status = 0;

cleanup:
  g_clear_error (&error);
  g_free (contents);
  WebPFree (data);
  return status;
}

/* Dispatch the requested inspection operation; diagnostics go to stderr.  */
int
main (int argc, char **argv)
{
  if (argc != 3)
    {
      fputs ("usage: font-info inspect|image-info FILE\n", stderr);
      return 2;
    }

  if (!strcmp (argv[1], "inspect"))
    return inspect (argv[2]);
  if (!strcmp (argv[1], "image-info"))
    return image_info (argv[2]);

  fputs ("Unknown operation\n", stderr);
  return 2;
}

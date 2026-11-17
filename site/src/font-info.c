/* Font and PNG inspection for the Guile build tools.  */

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_MULTIPLE_MASTERS_H
#include FT_SFNT_NAMES_H
#include FT_TRUETYPE_TABLES_H
#include <cairo.h>
#include <glib.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Report MESSAGE and PATH on stderr and terminate the inspector.  */
static void
fail (const char *message, const char *path)
{
  fprintf (stderr, "%s: %s\n", message, path);
  exit (EXIT_FAILURE);
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
            printf ("\\x%x;", *c);
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

      if (!encoding)
        continue;

      char *decoded = g_convert ((const char *)entry.string, entry.string_len,
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
   Resources belong to this operation; invalid fonts terminate the inspector.
 */
static void
inspect (const char *path)
{
  FT_Library library;
  FT_Face face;

  if (FT_Init_FreeType (&library))
    fail ("Cannot initialize FreeType", path);
  if (FT_New_Face (library, path, -1, &face))
    fail ("Cannot open font", path);

  FT_Long count = face->num_faces;
  unsigned char magic[4] = { 0 };
  FILE *input = fopen (path, "rb");

  if (!input || fread (magic, 1, sizeof magic, input) != sizeof magic)
    fail ("Cannot read font header", path);

  fclose (input);

  int collection = !memcmp (magic, "ttcf", 4);

  FT_Done_Face (face);

  putchar ('(');

  for (FT_Long index = 0; index < count; index++)
    {
      if (FT_New_Face (library, path, index, &face))
        fail ("Cannot open collection member", path);

      char *family = read_sfnt_name (face, 16);

      if (!family)
        family = read_sfnt_name (face, 1);
      if (!family)
        {
          family = g_path_get_basename (path);
          char *extension = strrchr (family, '.');

          if (extension)
            *extension = '\0';
        }

      char *style = read_sfnt_name (face, 17);

      if (!style)
        style = read_sfnt_name (face, 2);
      if (!style)
        style = g_strdup ("Regular");

      char *full = read_sfnt_name (face, 4);

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

      FT_MM_Var *var = NULL;

      if (FT_HAS_MULTIPLE_MASTERS (face) && FT_Get_MM_Var (face, &var))
        fail ("Cannot read variable axes", path);

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
        FT_Done_MM_Var (library, var);
      g_free (family);
      g_free (style);
      g_free (full);
      FT_Done_Face (face);
    }

  puts (")");

  FT_Done_FreeType (library);
}

/* Validate a nonblank horizontal PNG with transparent borders at PATH.
   Write its pixel dimensions as a Scheme vector, or terminate on failure.  */
static void
image_info (const char *path)
{
  cairo_surface_t *image = cairo_image_surface_create_from_png (path);

  if (cairo_surface_status (image) != CAIRO_STATUS_SUCCESS)
    fail ("Invalid PNG", path);

  int width = cairo_image_surface_get_width (image);
  int height = cairo_image_surface_get_height (image);

  if (width <= height || height <= 0)
    fail ("Expected horizontal PNG", path);

  cairo_surface_flush (image);

  unsigned char *data = cairo_image_surface_get_data (image);
  int stride = cairo_image_surface_get_stride (image);
  cairo_format_t format = cairo_image_surface_get_format (image);

  if (format != CAIRO_FORMAT_ARGB32)
    fail ("Expected transparent PNG", path);

  unsigned min[3] = { 255, 255, 255 };
  unsigned max[3] = { 0, 0, 0 };

  for (int y = 0; y < height; y++)
    for (int x = 0; x < width; x++)
      {
        uint32_t pixel = ((uint32_t *)(data + y * stride))[x];
        unsigned alpha = pixel >> 24;

        if ((x == 0 || y == 0 || x == width - 1 || y == height - 1) && alpha)
          fail ("Expected transparent PNG borders", path);

        for (int i = 0; i < 3; i++)
          {
            unsigned channel = ((pixel >> (8 * i)) & 255) + 255 - alpha;
            min[i] = MIN (min[i], channel);
            max[i] = MAX (max[i], channel);
          }
      }

  if (min[0] == max[0] && min[1] == max[1] && min[2] == max[2])
    fail ("Expected nonblank PNG", path);

  printf ("#(%d %d)\n", width, height);

  cairo_surface_destroy (image);
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
    inspect (argv[2]);
  else if (!strcmp (argv[1], "image-info"))
    image_info (argv[2]);
  else
    {
      fputs ("Unknown operation\n", stderr);
      return 2;
    }

  return 0;
}

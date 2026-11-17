/* Batch fixed-language PNG rendering.  Fonts stay in the local build
   environment.  */

#include <cairo.h>
#include <fontconfig/fontconfig.h>

/* Fontconfig's FreeType adapter requires the core declarations first.  */
#include <fontconfig/fcfreetype.h>
#include <math.h>
#include <pango/pangocairo.h>
#include <pango/pangofc-font.h>
#include <pango/pangofc-fontmap.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Owned rendering objects for the selected face.  Each worker processes its
   manifest sequentially and releases these objects before selecting a face. */
static PangoFontMap *map;
static PangoContext *context;
static PangoLayout *layout;

/* Release the selected face's layout, context, and font map.  */
static void
clear_face (void)
{
  g_clear_object (&layout);
  g_clear_object (&context);
  g_clear_object (&map);
}

/* Select FILE's face INDEX and VARIATIONS, disabling font fallback.
   FILE and VARIATIONS are borrowed NUL-terminated strings; "-" selects default
   coordinates.  Loading failure terminates the worker with a diagnostic.  */
static void
select_face (const char *file, int index, const char *variations)
{
  clear_face ();

  FcConfig *config = FcConfigCreate ();
  char *escaped = g_markup_escape_text (file, -1);
  char *xml = g_strdup_printf (
      "<fontconfig><match target=\"font\">"
      "<edit name=\"file\" mode=\"assign\"><string>%s</string></edit>"
      "<edit name=\"index\" mode=\"assign\"><int>%d</int></edit>"
      "<edit name=\"embolden\" mode=\"assign\"><bool>false</bool></edit>"
      "</match></fontconfig>",
      escaped, index);

  if (!FcConfigParseAndLoadFromMemory (config, (FcChar8 *)xml, FcTrue)
      || !FcConfigAppFontAddFile (config, (FcChar8 *)file))
    {
      fprintf (stderr, "Cannot load font: %s\n", file);
      exit (1);
    }

  int count;
  FcPattern *pattern = FcFreeTypeQuery ((FcChar8 *)file, index, NULL, &count);

  if (!pattern)
    {
      fprintf (stderr, "Cannot read font face: %s:%d\n", file, index);
      exit (1);
    }

  PangoFontDescription *description
      = pango_fc_font_description_from_pattern (pattern, FALSE);

  pango_font_description_set_absolute_size (description, 64 * PANGO_SCALE);
  if (strcmp (variations, "-") != 0)
    pango_font_description_set_variations (description, variations);

  map = pango_cairo_font_map_new_for_font_type (CAIRO_FONT_TYPE_FT);
  pango_fc_font_map_set_config (PANGO_FC_FONT_MAP (map), config);

  context = pango_font_map_create_context (map);
  pango_context_set_base_dir (context, PANGO_DIRECTION_WEAK_LTR);

  layout = pango_layout_new (context);
  pango_layout_set_font_description (layout, description);
  pango_layout_set_single_paragraph_mode (layout, TRUE);

  PangoAttrList *attributes = pango_attr_list_new ();

  pango_attr_list_insert (attributes, pango_attr_fallback_new (FALSE));
  pango_layout_set_attributes (layout, attributes);

  pango_attr_list_unref (attributes);
  pango_font_description_free (description);
  FcPatternDestroy (pattern);
  FcConfigDestroy (config);
  g_free (xml);
  g_free (escaped);
}

/* Render UTF-8 TEXT in LANGUAGE to OUTPUT using the selected face.
   All arguments are borrowed NUL-terminated strings.  Report unsupported or
   blank samples as a skip record on stdout; terminate on a PNG write error. */
static void
render (const char *language, const char *text, const char *output)
{
  pango_context_set_language (context, pango_language_from_string (language));
  pango_layout_context_changed (layout);
  pango_layout_set_text (layout, text, -1);

  PangoRectangle ink;

  pango_layout_get_pixel_extents (layout, &ink, NULL);

  if (pango_layout_get_unknown_glyphs_count (layout) || ink.width == 0
      || ink.height == 0)
    {
      printf ("skip\t%s\n", output);
      return;
    }

  double scale = fmin (1.0, fmin (1200.0 / ink.width, 360.0 / ink.height));
  int height = (int)ceil (ink.height * scale) + 32;
  int width = (int)ceil (ink.width * scale) + 32;

  if (width <= height)
    width = height + 16;

  cairo_surface_t *surface
      = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, width, height);
  cairo_t *cr = cairo_create (surface);

  cairo_translate (cr, 16, 16);
  cairo_scale (cr, scale, scale);
  cairo_translate (cr, -ink.x, -ink.y);
  cairo_set_source_rgba (cr, 0, 0, 0, 1);
  pango_cairo_show_layout (cr, layout);

  cairo_status_t status = cairo_surface_write_to_png (surface, output);

  if (status != CAIRO_STATUS_SUCCESS)
    {
      fprintf (stderr, "Cannot write %s: %s\n", output,
               cairo_status_to_string (status));
      exit (1);
    }

  cairo_destroy (cr);
  cairo_surface_destroy (surface);
}

/* Read six tab-separated fields per row: file, face index, variations,
   language, text, and output path.  Return nonzero for malformed input.  */
int
main (int argc, char **argv)
{
  if (argc != 2)
    {
      fprintf (stderr, "usage: render-font-samples MANIFEST.tsv\n");
      return 2;
    }

  FILE *manifest = fopen (argv[1], "r");

  if (!manifest)
    {
      perror (argv[1]);
      return 1;
    }

  char *line = NULL;
  char *previous = NULL;
  size_t capacity = 0;
  unsigned processed = 0;

  while (getline (&line, &capacity, manifest) >= 0)
    {
      line[strcspn (line, "\r\n")] = 0;
      char **fields = g_strsplit (line, "\t", -1);

      if (g_strv_length (fields) != 6)
        {
          fprintf (stderr, "Invalid sample manifest row\n");
          return 1;
        }

      guint64 index;

      if (!g_ascii_string_to_unsigned (fields[1], 10, 0, G_MAXINT,
                                       &index, NULL))
        {
          fprintf (stderr, "Invalid font face index: %s\n", fields[1]);
          return 1;
        }

      char *key
          = g_strdup_printf ("%s\t%s\t%s", fields[0], fields[1], fields[2]);

      if (!previous || strcmp (previous, key))
        select_face (fields[0], (int)index, fields[2]);
      g_free (previous);
      previous = key;

      render (fields[3], fields[4], fields[5]);
      g_strfreev (fields);

      if (++processed % 1000 == 0)
        fprintf (stderr, "Rendered %u language samples in worker.\n",
                 processed);
    }

  if (ferror (manifest))
    {
      fprintf (stderr, "Cannot read sample manifest: %s\n", argv[1]);
      return 1;
    }

  clear_face ();
  g_free (previous);
  free (line);
  fclose (manifest);

  return 0;
}

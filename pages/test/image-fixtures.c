/* Prepare generated image fixtures and pixel evidence for SRFI-64 tests.  */

#include "webp-image.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <webp/decode.h>
#include <webp/encode.h>

/* Write borrowed DATA of LENGTH bytes to DIRECTORY/NAME.
   Return FALSE with a stderr diagnostic on failure.  */
static gboolean
write_bytes (const char *directory, const char *name, const void *data,
             gsize length)
{
  if (length > G_MAXSSIZE)
    {
      fprintf (stderr, "%s: Buffer exceeds file size limit\n", name);
      return FALSE;
    }

  char *path = g_build_filename (directory, name, NULL);
  GError *error = NULL;
  gboolean success = g_file_set_contents (path, data, (gssize)length, &error);

  if (!success)
    {
      fprintf (stderr, "%s: %s\n", path, error->message);
      g_error_free (error);
    }

  g_free (path);
  return success;
}

/* Encode borrowed SURFACE to DIRECTORY/NAME through the production writer.
   Return FALSE with a stderr diagnostic on failure.  */
static gboolean
write_surface (const char *directory, const char *name,
               cairo_surface_t *surface)
{
  char *path = g_build_filename (directory, name, NULL);
  GError *error = NULL;
  gboolean success = write_webp_surface (surface, path, &error);

  if (!success)
    {
      fprintf (stderr, "%s: %s\n", path, error->message);
      g_error_free (error);
    }

  g_free (path);
  return success;
}

/* Print LENGTH bytes of borrowed DATA as a Scheme bytevector.  */
static void
write_bytevector (const uint8_t *data, size_t length)
{
  fputs ("#u8(", stdout);
  for (size_t i = 0; i < length; i++)
    printf ("%s%u", i ? " " : "", data[i]);
  putchar (')');
}

/* Generate small fixtures in the existing directory argv[1].  Emit expected
   straight RGBA and decoded RGBA for comparison by the Scheme test driver.  */
int
main (int argc, char **argv)
{
  if (argc != 2)
    {
      fputs ("usage: image-fixtures DIRECTORY\n", stderr);
      return 2;
    }

  int status = 1;
  cairo_surface_t *surface = NULL;
  char *path = NULL;
  gchar *encoded = NULL;
  gsize length = 0;
  GError *error = NULL;
  uint8_t *decoded = NULL;
  uint8_t *lossy = NULL;

  /* Extra row padding catches treating Cairo's stride as width times four.
     The middle row covers opaque color, several alpha values and rounding.  */
  uint32_t pixels[3][16] = { { 0 } };
  const uint32_t colors[]
      = { 0xffff0000, 0x80004080, 0x40004000, 0x01010000, 0x7f3f2040 };
  const uint8_t straight[] = { 255, 0,  0,   255, 0, 128, 255, 128, 0,   255,
                               0,   64, 255, 0,   0, 1,   126, 64,  129, 127 };
  uint8_t expected[8 * 3 * 4] = { 0 };
  memcpy (&pixels[1][1], colors, sizeof colors);
  memcpy (expected + (8 + 1) * 4, straight, sizeof straight);

  surface = cairo_image_surface_create_for_data (
      (unsigned char *)pixels, CAIRO_FORMAT_ARGB32, 8, 3, sizeof pixels[0]);
  if (!write_surface (argv[1], "pixels.webp", surface))
    goto cleanup;

  path = g_build_filename (argv[1], "pixels.webp", NULL);
  if (!g_file_get_contents (path, &encoded, &length, &error))
    {
      fprintf (stderr, "%s: %s\n", path, error->message);
      goto cleanup;
    }

  int width = 0;
  int height = 0;
  decoded = WebPDecodeRGBA ((const uint8_t *)encoded, length, &width, &height);
  if (!decoded || width != 8 || height != 3)
    {
      fprintf (stderr, "%s: Unexpected decoded dimensions %dx%d\n", path,
               width, height);
      goto cleanup;
    }

  if (length < 2)
    {
      fprintf (stderr, "%s: Encoded WebP is unexpectedly short\n", path);
      goto cleanup;
    }

  putchar ('(');
  write_bytevector (expected, sizeof expected);
  putchar (' ');
  write_bytevector (decoded, (size_t)width * height * 4);
  puts (")");

  if (!write_bytes (argv[1], "truncated.webp", encoded, length - 2))
    goto cleanup;

  size_t lossy_size = WebPEncodeRGBA (expected, 8, 3, 8 * 4, 75, &lossy);
  if (!lossy_size || !lossy)
    {
      fputs ("Cannot encode lossy WebP fixture\n", stderr);
      goto cleanup;
    }
  if (!write_bytes (argv[1], "lossy.webp", lossy, lossy_size))
    goto cleanup;

  pixels[0][0] = 0xff000000;
  cairo_surface_mark_dirty (surface);
  if (!write_surface (argv[1], "edge.webp", surface))
    goto cleanup;

  memset (pixels, 0, sizeof pixels);
  cairo_surface_mark_dirty (surface);
  if (!write_surface (argv[1], "blank.webp", surface))
    goto cleanup;

  for (unsigned y = 0; y < 3; y++)
    for (unsigned x = 0; x < 8; x++)
      pixels[y][x] = 0xff000000;
  cairo_surface_mark_dirty (surface);
  if (!write_surface (argv[1], "opaque.webp", surface))
    goto cleanup;

  status = 0;

cleanup:
  g_clear_error (&error);
  WebPFree (lossy);
  WebPFree (decoded);
  g_free (encoded);
  g_free (path);
  if (surface)
    cairo_surface_destroy (surface);
  return status;
}

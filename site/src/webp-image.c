/* Encode preview pixels directly, without an intermediate image file.  */

#include "webp-image.h"

#include <stdint.h>
#include <string.h>
#include <webp/encode.h>

gboolean
write_webp_surface (cairo_surface_t *surface, const char *path, GError **error)
{
  WebPConfig config;
  WebPPicture picture;
  WebPMemoryWriter writer;
  gboolean success = FALSE;

  if (cairo_surface_status (surface) != CAIRO_STATUS_SUCCESS
      || cairo_surface_get_type (surface) != CAIRO_SURFACE_TYPE_IMAGE
      || cairo_image_surface_get_format (surface) != CAIRO_FORMAT_ARGB32)
    {
      g_set_error_literal (error, G_FILE_ERROR, G_FILE_ERROR_FAILED,
                           "Expected a valid ARGB32 image surface");
      return FALSE;
    }

  if (!WebPConfigInit (&config) || !WebPPictureInit (&picture))
    {
      g_set_error_literal (error, G_FILE_ERROR, G_FILE_ERROR_FAILED,
                           "Cannot initialize WebP encoder");
      return FALSE;
    }

  config.lossless = 1;
  /* In lossless mode, quality controls search effort, not pixel fidelity.  */
  config.quality = 75;
  config.method = 6;
  config.exact = 1;
  picture.use_argb = 1;
  picture.width = cairo_image_surface_get_width (surface);
  picture.height = cairo_image_surface_get_height (surface);
  WebPMemoryWriterInit (&writer);
  picture.writer = WebPMemoryWrite;
  picture.custom_ptr = &writer;

  if (!WebPValidateConfig (&config) || !WebPPictureAlloc (&picture))
    goto encoding_failed;

  cairo_surface_flush (surface);
  const unsigned char *data = cairo_image_surface_get_data (surface);
  int stride = cairo_image_surface_get_stride (surface);

  for (int y = 0; y < picture.height; y++)
    for (int x = 0; x < picture.width; x++)
      {
        uint32_t pixel;
        memcpy (&pixel, data + (size_t)y * stride + (size_t)x * 4, 4);
        unsigned alpha = pixel >> 24;
        uint32_t straight = alpha << 24;

        if (alpha)
          for (int shift = 0; shift < 24; shift += 8)
            {
              unsigned channel = (pixel >> shift) & 255;
              channel = MIN (255, (channel * 255 + alpha / 2) / alpha);
              straight |= channel << shift;
            }

        picture.argb[(size_t)y * picture.argb_stride + x] = straight;
      }

  if (!WebPEncode (&config, &picture))
    goto encoding_failed;

  if (writer.size > G_MAXSSIZE)
    {
      g_set_error_literal (error, G_FILE_ERROR, G_FILE_ERROR_FAILED,
                           "Encoded WebP exceeds the file size limit");
      goto cleanup;
    }

  success = g_file_set_contents_full (
      path, (const char *)writer.mem, (gssize)writer.size,
      G_FILE_SET_CONTENTS_CONSISTENT, 0666, error);
  goto cleanup;

encoding_failed:
  g_set_error (error, G_FILE_ERROR, G_FILE_ERROR_FAILED,
               "Cannot encode WebP (error %d)", picture.error_code);
cleanup:
  WebPPictureFree (&picture);
  WebPMemoryWriterClear (&writer);
  return success;
}

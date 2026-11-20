/* Lossless encoding of Cairo image surfaces.  */

#ifndef WEBP_IMAGE_H
#define WEBP_IMAGE_H

#include <cairo.h>
#include <glib.h>

/* Encode borrowed ARGB32 image SURFACE losslessly to PATH.  Convert Cairo's
   native-endian, premultiplied pixels to straight ARGB, preserving alpha.
   Return false and set ERROR on failure; publish the complete file atomically.
   The caller retains SURFACE and must pass an initially empty ERROR.  */
gboolean write_webp_surface (cairo_surface_t *surface, const char *path,
                             GError **error);

#endif

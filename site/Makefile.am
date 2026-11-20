AM_CPPFLAGS = -I$(srcdir)/src
AM_CFLAGS = -Wall -Wextra $(FONT_CFLAGS)
LDADD = $(FONT_LIBS) -lm

bin_SCRIPTS = chinese-fonts-overlay-site
libexec_PROGRAMS = render-font-samples font-info
render_font_samples_SOURCES = \
  src/render-samples.c src/webp-image.c src/webp-image.h
font_info_SOURCES = src/font-info.c
check_PROGRAMS = image-fixtures
image_fixtures_SOURCES = \
  tests/image-fixtures.c src/webp-image.c src/webp-image.h

font_site_modules = \
  module/chinese-fonts-overlay-site/util.scm \
  module/chinese-fonts-overlay-site/samples.scm \
  module/chinese-fonts-overlay-site/previews.scm \
  module/chinese-fonts-overlay-site/catalog.scm \
  module/chinese-fonts-overlay-site/coverage.scm \
  module/chinese-fonts-overlay-site/server.scm \
  module/chinese-fonts-overlay-site/command.scm
nobase_dist_pkgdata_DATA = \
  $(font_site_modules) \
  data/language-samples.json \
  data/language-names.json
webdir = $(pkgdatadir)/web
web_DATA = \
  compiled-web/index.html \
  compiled-web/style.css \
  compiled-web/licenses.html \
  compiled-web/favicon.svg \
  compiled-web/cc0.svg \
  compiled-web/yuyang-regular.ttf \
  compiled-web/yuyang-medium.ttf \
  compiled-web/tsanger-license.pdf \
  compiled-web/bridge.js \
  compiled-web/main.wasm \
  compiled-web/reflect.js \
  compiled-web/reflect.wasm \
  compiled-web/wtf8.wasm
hoot_support_files = compiled-web/reflect.js compiled-web/reflect.wasm \
  compiled-web/wtf8.wasm

chinese-fonts-overlay-site: $(srcdir)/scripts/chinese-fonts-overlay-site.in \
	$(srcdir)/build-aux/substitute.scm Makefile
	$(AM_V_GEN)$(GUILE) --no-auto-compile \
	  $(srcdir)/build-aux/substitute.scm $< $@ \
	  GUILE "$(GUILE)" SOURCE "$(abs_top_srcdir)" BUILD "$(abs_top_builddir)" \
	  DATADIR "$(pkgdatadir)" LIBEXECDIR "$(libexecdir)" \
	  VERSION "$(PACKAGE_VERSION)"
	chmod +x $@

compiled-web/main.wasm: $(srcdir)/web/main.scm
	$(AM_V_GEN)$(MKDIR_P) compiled-web
	$(HOOT) compile --bundle -o $@ $(srcdir)/web/main.scm

$(hoot_support_files): compiled-web/main.wasm
	@test -f $@

compiled-web/%: $(srcdir)/web/%
	$(AM_V_GEN)$(MKDIR_P) compiled-web
	cp $< $@

compiled-web/input.css: $(srcdir)/web/style.css \
	$(srcdir)/build-aux/substitute.scm Makefile
	$(AM_V_GEN)$(MKDIR_P) compiled-web
	$(GUILE) --no-auto-compile $(srcdir)/build-aux/substitute.scm $< $@ \
	  HTML_SOURCE "$(abs_top_srcdir)/web/index.html" \
	  SCHEME_SOURCE "$(abs_top_srcdir)/web/main.scm" \
	  CATALOG_SOURCE \
	  "$(abs_top_srcdir)/module/chinese-fonts-overlay-site/catalog.scm" \
	  DAISYUI "$(DAISYUI)" \
	  DAISYUI_THEME "$(DAISYUI_THEME)"

compiled-web/style.css: compiled-web/input.css $(srcdir)/web/index.html \
	$(srcdir)/web/main.scm \
	$(srcdir)/module/chinese-fonts-overlay-site/catalog.scm \
	$(DAISYUI) $(DAISYUI_THEME)
	$(AM_V_GEN)$(TAILWINDCSS) -i $< -o $@ --minify

compiled-web/yuyang-regular.ttf: $(UI_FONT_REGULAR)
	$(AM_V_GEN)$(MKDIR_P) compiled-web
	cp $< $@

compiled-web/yuyang-medium.ttf: $(UI_FONT_MEDIUM)
	$(AM_V_GEN)$(MKDIR_P) compiled-web
	cp $< $@

compiled-web/tsanger-license.pdf: $(UI_FONT_LICENSE)
	$(AM_V_GEN)$(MKDIR_P) compiled-web
	cp $< $@

PORT = 8000
OUTPUT = $(abs_top_builddir)/public
CACHE = $(abs_top_builddir)/cache
site: all
	$(GUILE) --no-auto-compile ./chinese-fonts-overlay-site --build \
	  --catalog "$(CATALOG)" --previews "$(PREVIEWS)" \
	  --source-root "$(SOURCE_ROOT)" --revision "$(SOURCE_REVISION)" \
	  --output "$(OUTPUT)" --cache "$(CACHE)"
serve: all
	$(GUILE) --no-auto-compile ./chinese-fonts-overlay-site \
	  --catalog "$(CATALOG)" --previews "$(PREVIEWS)" \
	  --source-root "$(SOURCE_ROOT)" --revision "$(SOURCE_REVISION)" \
	  --output "$(OUTPUT)" --cache "$(CACHE)" --port "$(PORT)"

installcheck-local:
	$(GUILE) --no-auto-compile "$(bindir)/chinese-fonts-overlay-site" --version

install-exec-hook:
	$(GUILE) --no-auto-compile $(srcdir)/build-aux/substitute.scm \
	  $(srcdir)/scripts/chinese-fonts-overlay-site.in \
	  "$(DESTDIR)$(bindir)/chinese-fonts-overlay-site" \
	  GUILE "$(GUILE)" SOURCE "" BUILD "" \
	  DATADIR "$(pkgdatadir)" LIBEXECDIR "$(libexecdir)" \
	  VERSION "$(PACKAGE_VERSION)"
	chmod +x "$(DESTDIR)$(bindir)/chinese-fonts-overlay-site"

TEST_EXTENSIONS = .scm
SCM_LOG_COMPILER = $(GUILE)
AM_SCM_LOG_FLAGS = --no-auto-compile -L $(abs_top_srcdir)/module
TESTS = \
  tests/publication.scm \
  tests/coverage.scm \
  tests/server.scm
TESTS_ENVIRONMENT = \
  FONT_SITE_DATA='$(abs_top_srcdir)/data' \
  FONT_SITE_WEB='$(abs_top_builddir)/compiled-web' \
  FONT_SITE_INSPECTOR='$(abs_top_builddir)/font-info' \
  FONT_SITE_RENDERER='$(abs_top_builddir)/render-font-samples' \
  FONT_SITE_IMAGE_FIXTURES='$(abs_top_builddir)/image-fixtures' \
  FONT_SITE_FIXTURES='$(abs_top_srcdir)/tests/fixtures'

EXTRA_DIST = \
  bootstrap \
  scripts/chinese-fonts-overlay-site.in \
  build-aux/substitute.scm \
  web/index.html \
  web/style.css \
  web/licenses.html \
  web/favicon.svg \
  web/cc0.svg \
  web/main.scm \
  web/bridge.js \
  $(TESTS) \
  tests/fixtures/static.ttf \
  tests/fixtures/variable.ttf \
  tests/fixtures/collection.ttc \
  tests/fixtures/english.ttf \
  tests/fixtures/symbols.ttf
CLEANFILES = \
  chinese-fonts-overlay-site \
  compiled-web/input.css \
  $(web_DATA)

.PHONY: site serve

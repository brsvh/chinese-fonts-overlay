.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

SOURCE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_DIR ?= $(SOURCE_DIR)/build
CACHE_DIR ?= $(SOURCE_DIR)/.cache
DIRECTORY ?= $(BUILD_DIR)/public
PORT ?= 8000
GUILE ?= guile
HOOT ?= hoot
TAILWINDCSS ?= tailwindcss
PKG_CONFIG ?= pkg-config
CFLAGS ?= -O2 -g
SOURCE_REVISION ?=
RELEASE_DIR ?= $(BUILD_DIR)/release
PACKAGES ?=
MANUAL ?= $(BUILD_DIR)/manual
MAKEINFO ?= makeinfo
SYSTEM ?=
export MAKEINFO
REFERENCE ?=
MB_TYPE_DIR ?=
export PACKAGES MB_TYPE_DIR

override BUILD_DIR := $(abspath $(BUILD_DIR))
override CACHE_DIR := $(abspath $(CACHE_DIR))
override REFERENCE := $(if $(REFERENCE),$(abspath $(REFERENCE)))
BIN := $(BUILD_DIR)/bin
WEB := $(BUILD_DIR)/web
INPUTS := $(BUILD_DIR)/inputs
PAGE_MODULES := $(SOURCE_DIR)/module/pages
SCHEME = $(GUILE) --no-auto-compile -L "$(SOURCE_DIR)/module"
FONT_LIBS = pangocairo pangofc fontconfig cairo freetype2 glib-2.0 libwebp
CATALOG ?= $(INPUTS)/catalog.json
PREVIEWS ?= $(INPUTS)/fonts.json

STATIC_FILES := index.html licenses.html favicon.svg cc0.svg bridge.js \
	startup-head.html presentation.js manual.js
STATIC_ASSETS := $(addprefix $(WEB)/,$(STATIC_FILES))
HOOT_ASSETS := $(addprefix $(WEB)/,main.wasm reflect.js reflect.wasm wtf8.wasm)
UI_ASSETS := $(addprefix $(WEB)/,yuyang-regular.ttf yuyang-medium.ttf \
	tsanger-license.pdf)
ASSETS := $(STATIC_ASSETS) $(HOOT_ASSETS) $(UI_ASSETS) $(WEB)/style.css
NATIVE := $(BIN)/font-info $(BIN)/render-font-samples
SCHEME_ENV = FONT_SITE_DATA="$(SOURCE_DIR)/etc" FONT_SITE_WEB="$(WEB)" \
	FONT_SITE_INSPECTOR="$(BIN)/font-info" \
	FONT_SITE_RENDERER="$(BIN)/render-font-samples"

.PHONY: all check release serve clean clean-cache inputs manual check-manual \
	interface FORCE

all: $(NATIVE) $(ASSETS) inputs manual interface
	$(SCHEME_ENV) $(SCHEME) "$(SOURCE_DIR)/build-aux/build.scm" \
	  "$(SOURCE_DIR)" "$(BUILD_DIR)" "$(CACHE_DIR)" \
	  "$(CATALOG)" "$(PREVIEWS)" "$(SOURCE_REVISION)" \
	  "$(abspath $(MANUAL))"

manual:
ifeq ($(origin MANUAL),file)
	$(SCHEME) "$(SOURCE_DIR)/build-aux/manual.scm" \
	  "$(SOURCE_DIR)" "$(BUILD_DIR)" "$(REFERENCE)" \
	  "$(SOURCE_REVISION)" "$(SYSTEM)"
else
	test -r "$(MANUAL)/navigation.json"
endif

check-manual: manual
	$(SCHEME) "$(SOURCE_DIR)/build-aux/check-manual.scm" "$(MANUAL)"

interface: | $(WEB)
	$(SCHEME) "$(SOURCE_DIR)/build-aux/fonts.scm" "$(WEB)"

inputs:
ifeq ($(origin CATALOG)$(origin PREVIEWS),filefile)
	$(SCHEME) "$(SOURCE_DIR)/build-aux/inputs.scm" \
	  "$(SOURCE_DIR)/.." "$(INPUTS)"
else ifeq ($(origin CATALOG),file)
	$(error Set CATALOG and PREVIEWS together)
else ifeq ($(origin PREVIEWS),file)
	$(error Set CATALOG and PREVIEWS together)
else
ifneq ($(strip $(PACKAGES)),)
	$(error PACKAGES cannot be combined with CATALOG and PREVIEWS)
endif
	test -r "$(CATALOG)" && test -r "$(PREVIEWS)"
endif

$(BUILD_DIR) $(BIN) $(WEB) $(BUILD_DIR)/test:
	mkdir -p "$@"

$(BUILD_DIR)/native.settings: FORCE | $(BUILD_DIR)
	$(PKG_CONFIG) --atleast-version=2.66 glib-2.0
	$(SCHEME) "$(SOURCE_DIR)/build-aux/settings.scm" "$@" \
	  "$(CC)" "$(CPPFLAGS)" "$(CFLAGS)" "$(LDFLAGS)" \
	  "$(shell command -v $(CC))" \
	  "$(shell $(PKG_CONFIG) --cflags --libs $(FONT_LIBS))"

$(BIN)/font-info: $(SOURCE_DIR)/src/font-info.c \
	$(BUILD_DIR)/native.settings | $(BIN)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Wall -Wextra \
	  $$($(PKG_CONFIG) --cflags $(FONT_LIBS)) "$<" \
	  $(LDFLAGS) $$($(PKG_CONFIG) --libs $(FONT_LIBS)) -lm -o "$@"

$(BIN)/render-font-samples: $(SOURCE_DIR)/src/render-samples.c \
	$(SOURCE_DIR)/src/webp-image.c $(SOURCE_DIR)/src/webp-image.h \
	$(BUILD_DIR)/native.settings | $(BIN)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Wall -Wextra \
	  $$($(PKG_CONFIG) --cflags $(FONT_LIBS)) \
	  "$<" "$(SOURCE_DIR)/src/webp-image.c" \
	  $(LDFLAGS) $$($(PKG_CONFIG) --libs $(FONT_LIBS)) -lm -o "$@"

$(BIN)/image-fixtures: $(SOURCE_DIR)/test/image-fixtures.c \
	$(SOURCE_DIR)/src/webp-image.c $(SOURCE_DIR)/src/webp-image.h \
	$(BUILD_DIR)/native.settings | $(BIN)
	$(CC) $(CPPFLAGS) $(CFLAGS) -Wall -Wextra -I"$(SOURCE_DIR)/src" \
	  $$($(PKG_CONFIG) --cflags $(FONT_LIBS)) \
	  "$<" "$(SOURCE_DIR)/src/webp-image.c" \
	  $(LDFLAGS) $$($(PKG_CONFIG) --libs $(FONT_LIBS)) -lm -o "$@"

$(BUILD_DIR)/web.settings: FORCE | $(BUILD_DIR)
	$(SCHEME) "$(SOURCE_DIR)/build-aux/settings.scm" "$@" \
	  "$(HOOT)" "$(TAILWINDCSS)" "$(DAISYUI)" "$(DAISYUI_THEME)" \
	  "$(shell command -v $(HOOT))" "$(shell command -v $(TAILWINDCSS))" \
	  "$(UI_FONT_REGULAR)" "$(UI_FONT_MEDIUM)" "$(UI_FONT_LICENSE)"

$(HOOT_ASSETS) &: $(SOURCE_DIR)/web/main.scm \
	$(BUILD_DIR)/web.settings | $(WEB)
	$(HOOT) compile --bundle -o "$(WEB)/main.wasm" "$<"

$(STATIC_ASSETS): $(WEB)/%: $(SOURCE_DIR)/web/% | $(WEB)
	cp -f "$<" "$@"

$(WEB)/input.css: $(SOURCE_DIR)/web/style.css $(SOURCE_DIR)/Makefile \
	$(SOURCE_DIR)/build-aux/substitute.scm $(BUILD_DIR)/web.settings | $(WEB)
	test -r "$(DAISYUI)" && test -r "$(DAISYUI_THEME)"
	$(GUILE) --no-auto-compile "$(SOURCE_DIR)/build-aux/substitute.scm" \
	  "$<" "$@" HTML_SOURCE "$(SOURCE_DIR)/web/index.html" \
	  SCHEME_SOURCE "$(SOURCE_DIR)/web/main.scm" \
	  CATALOG_SOURCE "$(PAGE_MODULES)/preview/catalog.scm" \
	  LAYOUT_SOURCE "$(PAGE_MODULES)/presentation/layout.scm" \
	  MANUAL_SOURCE "$(PAGE_MODULES)/manual/page.scm" \
	  DAISYUI "$(DAISYUI)" DAISYUI_THEME "$(DAISYUI_THEME)"

$(WEB)/style.css: $(WEB)/input.css $(SOURCE_DIR)/web/index.html \
	$(SOURCE_DIR)/web/main.scm \
	$(PAGE_MODULES)/preview/catalog.scm \
	$(PAGE_MODULES)/presentation/layout.scm \
	$(PAGE_MODULES)/manual/page.scm $(DAISYUI) $(DAISYUI_THEME)
	$(TAILWINDCSS) -i "$<" -o "$@" --minify

$(WEB)/yuyang-regular.ttf: $(UI_FONT_REGULAR) \
	$(BUILD_DIR)/web.settings | $(WEB)
	cp -f "$(UI_FONT_REGULAR)" "$@"

$(WEB)/yuyang-medium.ttf: $(UI_FONT_MEDIUM) \
	$(BUILD_DIR)/web.settings | $(WEB)
	cp -f "$(UI_FONT_MEDIUM)" "$@"

$(WEB)/tsanger-license.pdf: $(UI_FONT_LICENSE) \
	$(BUILD_DIR)/web.settings | $(WEB)
	cp -f "$(UI_FONT_LICENSE)" "$@"

check: $(NATIVE) $(ASSETS) $(BIN)/image-fixtures interface | $(BUILD_DIR)/test
	cd "$(BUILD_DIR)/test" && GUILE="$(GUILE)" $(SCHEME_ENV) \
	  FONT_SITE_IMAGE_FIXTURES="$(BIN)/image-fixtures" \
	  FONT_SITE_FIXTURES="$(SOURCE_DIR)/test/fixtures/fonts" \
	  FONT_SITE_SOURCE="$(SOURCE_DIR)" \
	  $(SCHEME) "$(SOURCE_DIR)/test/publication.scm"
	cd "$(BUILD_DIR)/test" && \
	  $(SCHEME) "$(SOURCE_DIR)/test/server.scm"
	cd "$(BUILD_DIR)/test" && \
	  $(SCHEME) "$(SOURCE_DIR)/test/archive.scm"

release:
	$(SCHEME) "$(SOURCE_DIR)/build-aux/archive.scm" pack \
	  "$(abspath $(DIRECTORY))" "$(SOURCE_REVISION)" \
	  "$(abspath $(RELEASE_DIR))"

serve:
	$(SCHEME) "$(SOURCE_DIR)/build-aux/serve.scm" "$(DIRECTORY)" "$(PORT)"

clean:
	$(SCHEME) "$(SOURCE_DIR)/build-aux/clean.scm" build \
	  "$(SOURCE_DIR)" "$(BUILD_DIR)"

clean-cache:
	$(SCHEME) "$(SOURCE_DIR)/build-aux/clean.scm" cache \
	  "$(SOURCE_DIR)" "$(CACHE_DIR)"

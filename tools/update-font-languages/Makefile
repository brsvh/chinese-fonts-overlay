GUILE ?= guile
BUILD_DIR ?= build

.PHONY: check clean

check:
	mkdir -p "$(BUILD_DIR)"
	cd "$(BUILD_DIR)" && \
	  FONT_LANGUAGES_FIXTURES="$(abspath ../../tests/fixtures/fonts)" \
	  $(GUILE) --no-auto-compile -L "$(abspath module)" \
	  "$(abspath tests/coverage.scm)"

clean:
	rm -f "$(BUILD_DIR)/coverage.log"

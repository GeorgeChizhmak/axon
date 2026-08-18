PREFIX  ?= /usr/local
BINDIR   = $(PREFIX)/bin
DATADIR  = $(PREFIX)/share/arc42-c4

SCRIPTS  = $(wildcard src/arc42-c4 src/arc42-c4-* src/_arc42c4_dir)

.PHONY: install uninstall test

install:
	@echo "[arc42-c4] Installing to $(BINDIR) and $(DATADIR)"
	install -d $(DATADIR)/templates/arc42
	install -d $(DATADIR)/templates/doc-types
	cp -r templates/arc42/*     $(DATADIR)/templates/arc42/
	cp -r templates/doc-types/* $(DATADIR)/templates/doc-types/
	cp templates/workspace.dsl  $(DATADIR)/templates/
	cp templates/main.adoc      $(DATADIR)/templates/
	cp templates/README.adoc    $(DATADIR)/templates/
	@for f in $(SCRIPTS); do \
	    echo "  Installing $$(basename $$f)"; \
	    install -m 755 $$f $(BINDIR)/$$(basename $$f); \
	done
	@# Rewrite the config script: replace the lines after the ARC42C4_* markers
	@# with hardcoded absolute paths so the installed tool is self-contained.
	perl -i -pe \
	    's|^arc42c4_bin_dir=.*$$|arc42c4_bin_dir="$(BINDIR)"|; \
	     s|^arc42c4_template_dir=.*$$|arc42c4_template_dir="$(DATADIR)/templates"|' \
	    $(BINDIR)/arc42-c4-config
	@echo "[arc42-c4] ✓ Installation complete. Run 'arc42-c4 help' to get started."

uninstall:
	@echo "[arc42-c4] Removing installed files..."
	rm -f $(BINDIR)/arc42-c4 $(BINDIR)/arc42-c4-* $(BINDIR)/_arc42c4_dir
	rm -rf $(DATADIR)
	@echo "[arc42-c4] ✓ Uninstalled."

test:
	@bash tests/run_tests.sh

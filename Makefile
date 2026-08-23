PREFIX  ?= /usr/local
BINDIR   = $(PREFIX)/bin
DATADIR  = $(PREFIX)/share/axon

SCRIPTS  = $(wildcard src/axon src/axon-* src/_axon_dir)

.PHONY: install uninstall test

install:
	@echo "[axon] Installing to $(BINDIR) and $(DATADIR)"
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
	@# Rewrite the config script: replace the lines after the AXON_* markers
	@# with hardcoded absolute paths so the installed tool is self-contained.
	perl -i -pe \
	    's|^axon_bin_dir=.*$$|axon_bin_dir="$(BINDIR)"|; \
	     s|^axon_template_dir=.*$$|axon_template_dir="$(DATADIR)/templates"|' \
	    $(BINDIR)/axon-config
	@echo "[axon] ✓ Installation complete. Run 'axon help' to get started."

uninstall:
	@echo "[axon] Removing installed files..."
	rm -f $(BINDIR)/axon $(BINDIR)/axon-* $(BINDIR)/_axon_dir
	rm -rf $(DATADIR)
	@echo "[axon] ✓ Uninstalled."

test:
	@bash tests/run_tests.sh

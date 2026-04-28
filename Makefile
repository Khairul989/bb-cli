INSTALL_DIR := $(HOME)/.local/bin
TARGET      := $(INSTALL_DIR)/bb
SCRIPT      := $(CURDIR)/bin/bb

.PHONY: install uninstall

install:
	@echo "→ Checking dependencies..."
	@command -v curl >/dev/null || (echo "curl missing" && exit 1)
	@command -v git  >/dev/null || (echo "git missing"  && exit 1)
	@command -v jq   >/dev/null 2>&1 || (echo "→ Installing jq via brew..." && brew install jq)
	@mkdir -p $(INSTALL_DIR)
	@ln -sf $(SCRIPT) $(TARGET)
	@echo "→ Symlinked: $(TARGET)"
	@case ":$$PATH:" in *":$(HOME)/.local/bin:"*) echo "→ PATH ok" ;; \
	   *) echo "⚠  Add this to your shell rc:  export PATH=\"\$$HOME/.local/bin:\$$PATH\"" ;; esac
	@echo ""
	@echo "✓ Installed. Next: run 'bb auth login' to authenticate."

uninstall:
	@rm -f $(TARGET)
	@echo "Removed $(TARGET) (config at ~/.config/bb/config left intact — run 'bb auth logout' to remove)."

.PHONY: setup install open clean

# Setup project
setup:
	@echo "Setting up iOS project..."
	bundle install
	pod install
	@echo "✅ Setup complete! Open MediVault.xcworkspace in Xcode"

# Install dependencies
install:
	@echo "Installing dependencies..."
	bundle install
	pod install

# Open in Xcode
open:
	open MediVault.xcworkspace

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/
	rm -rf DerivedData/
	pod deintegrate || true
	rm -rf Pods/
	rm -f Podfile.lock
	@echo "✅ Clean complete"

# Help
help:
	@echo "MediVault iOS - Available commands:"
	@echo "  make setup    - Setup project (install deps and pods)"
	@echo "  make install  - Install dependencies"
	@echo "  make open     - Open project in Xcode"
	@echo "  make clean    - Clean build artifacts"

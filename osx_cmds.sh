defaults write com.ameba.SwiftBar PluginsDirectoryPath "$HOME/Library/Application Support/SwiftBar/plugins"
brew install --cask swiftbar
killall SwiftBar 2>/dev/null; open -a SwiftBar

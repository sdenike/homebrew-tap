cask "textmate-revived" do
  version "3.0.0-revived.18"
  sha256 "2a4749352aab1b8e3f4dda4d52787d6cf73ddba3a498440a80034cebcd1d95cc"

  url "https://github.com/sdenike/textmate/releases/download/v#{version}/TextMate-#{version}.tbz",
      verified: "github.com/sdenike/textmate/"
  name "TextMate Revived"
  desc "Maintained fork of TextMate — text editor for macOS, targeting macOS 26 on Apple silicon"
  homepage "https://github.com/sdenike/textmate"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :tahoe
  depends_on arch: :arm64

  app "TextMate.app"

  zap trash: [
    "~/Library/Application Support/TextMate",
    "~/Library/Caches/com.shelbydenike.TextMate",
    "~/Library/Preferences/com.shelbydenike.TextMate.plist",
    "~/Library/Saved Application State/com.shelbydenike.TextMate.savedState",
  ]
end

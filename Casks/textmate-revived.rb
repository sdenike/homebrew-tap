cask "textmate-revived" do
  version "3.0.0-revived.27"
  sha256 "b6a731a6c4951cabb99475df1d7703550d6e8d6db140cef82569bf25c1ed1081"

  url "https://github.com/sdenike/textmate/releases/download/v#{version}/TextMate-#{version}.tbz"
  name "TextMate Revived"
  desc "Maintained fork of the TextMate text editor"
  homepage "https://github.com/sdenike/textmate"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :tahoe

  app "TextMate.app"

  zap trash: [
    "~/Library/Application Support/TextMate",
    "~/Library/Caches/com.shelbydenike.TextMate",
    "~/Library/Preferences/com.shelbydenike.TextMate.plist",
    "~/Library/Saved Application State/com.shelbydenike.TextMate.savedState",
  ]
end

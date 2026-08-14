cask "textmate-revived" do
  version "3.0.0-revived.19"
  sha256 "dc5c50bc562316e747d4efb6a87e933041dae4573e292de1fe85b698b68ec4a6"

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

cask "hidden-revived" do
  version "2.1.1"
  sha256 "12bcc1d0cff4881ef38b0530fd2b334d75e9ec05217ea10fff8be0e1ddb74d74"

  url "https://github.com/sdenike/hidden-revived/releases/download/v#{version}/HiddenBarRevived-#{version}.zip",
      verified: "github.com/sdenike/hidden-revived/"
  name "Hidden Bar Revived"
  desc "Maintained fork of Hidden Bar — hides menu bar items to keep the bar tidy"
  homepage "https://github.com/sdenike/hidden-revived"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: :ventura

  app "Hidden Bar Revived.app"

  zap trash: [
    "~/Library/Application Scripts/com.sdenike.hiddenbar",
    "~/Library/Application Scripts/com.sdenike.hiddenbar.launcher",
    "~/Library/Containers/com.sdenike.hiddenbar",
    "~/Library/Containers/com.sdenike.hiddenbar.launcher",
    "~/Library/Preferences/com.sdenike.hiddenbar.launcher.plist",
    "~/Library/Preferences/com.sdenike.hiddenbar.plist",
  ]
end

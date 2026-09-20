# Homebrew Cask for SmartSelect.
#
# This is a template. To publish it, cut a GitHub Release that attaches
# SmartSelect.zip, then fill in `version` and `sha256` (shasum -a 256 SmartSelect.zip),
# and submit the cask to a tap (e.g. homebrew/cask or your own tap).
cask "smartselect" do
  version "0.1.0"
  sha256 :no_check # replace with the real checksum once a release exists

  url "https://github.com/smartselecthq/SmartSelect/releases/download/v#{version}/SmartSelect.zip"
  name "SmartSelect"
  desc "Double-click selection that snaps to the whole email, number, URL, date, or path"
  homepage "https://github.com/smartselecthq/SmartSelect"

  depends_on macos: ">= :monterey"

  app "SmartSelect.app"

  caveats <<~EOS
    SmartSelect needs Accessibility access to observe double-clicks and adjust the selection:
      System Settings → Privacy & Security → Accessibility
  EOS
end

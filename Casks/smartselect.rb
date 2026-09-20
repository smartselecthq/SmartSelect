# Homebrew Cask for SmartSelect.
#
# Wired to the v0.1.0 GitHub Release. On each new release the Release workflow
# prints the new `sha256` (also attached as SmartSelect.zip.sha256) — bump
# `version` and `sha256` here to match, then submit to a tap (your own, or
# homebrew/cask) so `brew install --cask smartselect` resolves.
cask "smartselect" do
  version "0.1.0"
  sha256 "ee5ffbd5b4c6d4c0a691c474d71464fbdfb252469ae9a5e768ab0055a2495d7c"

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

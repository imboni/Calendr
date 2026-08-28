cask "calendr" do
  version "v1.25.1"
  sha256 "e894eba5b1f267d3bf5f367bdf33918310394edd5c1cc032311f4bbe260e16e1"

  url "https://github.com/imboni/Calendr/releases/download/#{version}/Calendr.zip"
  name "Calendr"
  desc "Menu bar calendar with Chinese lunar dates, holidays and solar terms"
  homepage "https://github.com/imboni/Calendr"

  app "Calendr.app"

  zap trash: [
    "~/Library/Preferences/br.paker.Calendr.plist",
    "~/Library/Application Support/Calendr",
  ]
end

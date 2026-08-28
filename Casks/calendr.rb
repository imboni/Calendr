cask "calendr" do
  version "v1.25.0"
  sha256 :no_check

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

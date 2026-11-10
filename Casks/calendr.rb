cask "calendr" do
  version "v1.26.0"
  sha256 "dd0e8a76d3d3e056cc814aa74ee7ff79f0fa846c17108ef220b5849916157067"

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

cask "calendr" do
  version "v1.25.1"
  sha256 "566d5ef42a8fec0884ec35a2e6f4f34c8fc502c4253be91a5580f4b13fe9bd1f"

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

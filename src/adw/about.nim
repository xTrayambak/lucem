import pkg/owlkettle, pkg/owlkettle/adw
import ../meta

proc openAboutMenu*(app: Viewable) =
  discard app.open:
    gui:
      AboutWindow:
        applicationName = "Lucem"
        developerName = "The EquinoxHQ Team"
        version = meta.Version
        supportUrl = "https://discord.gg/Z5m3n9fjcU"
        issueUrl = "https://github.com/equinoxhq/lucem/issues"
        website = "https://equinoxhq.github.io"
        applicationIcon = "lucem"
        copyright =
          """
Copyright (C) 2025 xTrayambak and the EquinoxHQ Team
      """
        license = meta.License
        licenseType = LicenseGPL_3_0
        developers = @["Trayambak (xTrayambak)"]
        designers = @["Adrien (Ashtaka)"]
        artists = @[]
        documenters = @[]
        credits = @{"Emotional support (probably)": @["Kirby (k1yrix)"]}

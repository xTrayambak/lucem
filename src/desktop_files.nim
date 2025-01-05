## Make a .desktop entry for Lucem
## Copyright (C) 2024 Trayambak Rai
import std/[os, strutils, logging]
import ./internal_fonts

const
  ApplicationsPath* {.strdefine: "LucemAppsPath".} = "$1/.local/share/applications"

  SoberRunDesktopFile* =
    """
[Desktop Entry]
Version=1.0
Type=Application
Name=Lucem
Exec=$1
Comment=Run Roblox with quality of life fixes
GenericName=Wrapper around Sober
Terminal=false
Categories=Games
Icon=lucem
Keywords=roblox
Categories=Game
"""

  SoberGUIDesktopFile* =
    """
[Desktop Entry]
Version=1.0
Type=Application
Name=Lucem Settings
Exec=$1
Comment=Configure Lucem as per your needs
GenericName=Lucem Settings
Terminal=false
Categories=Utility
Keywords=settings
Icon=lucem
"""

proc createLucemDesktopFile*() =
  debug "lucem: create desktop files for lucem"
  let
    base = ApplicationsPath % [getHomeDir()]
    pathToLucem = getAppFilename()

  if not existsOrCreateDir(base):
    warn "lucem: `" & base &
      "` did not exist prior to this, your system seems to be a bit weird. Lucem has created it itself."
  
  let iconsPath = getHomeDir() / ".local" / "share" / "icons" / "hicolor" / "scalable"
  discard existsOrCreateDir(iconsPath)
  discard existsOrCreateDir(iconsPath / "apps")
  writeFile(iconsPath / "apps" / "lucem.svg", LucemIcon)

  debug "lucem: path to lucem binary is: " & pathToLucem

  debug "lucem: writing alternative to `lucem run` to " & base
  writeFile(base / "lucem.desktop", SoberRunDesktopFile % [pathToLucem & " run"])

  debug "lucem: writing alternative to `lucem shell` to " & base
  writeFile(
    base / "lucem_shell.desktop", SoberGUIDesktopFile % [pathToLucem & " shell"]
  )

  info "lucem: created desktop entries successfully!"

## This file implements `lucem init`, `lucem install-sober` and `lucem fetch-apk`
## Copyright (C) 2024 Trayambak Rai

import std/[logging, browsers, rdstdin, strutils]
import ../[flatpak, argparser, config, common]

const
  SOBER_FLATPAK_URL* {.strdefine: "SoberFlatpakUrl".} = "https://sober.vinegarhq.org/sober.flatpakref"
  APKMIRROR_URL* {.strdefine: "ApkMirrorUrl".} = "https://www.apkmirror.com/apk/roblox-corporation/roblox/roblox-$1-release/roblox-$1-android-apk-download"

proc initializeSober*(input: Input) {.inline.} =
  info "lucem: initializing sober"

  if not flatpakInstall(SOBER_FLATPAK_URL):
    error "lucem: failed to initialize sober."
    quit(1)

  info "lucem: installed sober successfully!"

proc initializeRoblox*(input: Input, config: Config) {.inline.} =
  info "lucem: an URL will now be opened in your browser."
  info "Instructions:"
  for instr in [
    "Click on the gray button that says \"DOWNLOAD APK BUNDLE\"",
    "Save the download in your Downloads folder. Do not rename it!"
  ]:
    echo "* " & instr

  openDefaultBrowser(APKMIRROR_URL % [config.apk.version])

  let confirmation = readLineFromStdin("Have you downloaded the APK? If not, you can retry. [y/N]: ")
  case confirmation.toLowerAscii()
  of "y":
    info "lucem: Sober will now be invoked. You need to pass on the APK to the GUI app that will now start."
    flatpakRun(SOBER_APP_ID)

    discard readLineFromStdin("Press Enter to continue once Sober tells you that the APK has been installed.")

    flatpakKill(SOBER_APP_ID)

    info "lucem: Voila! Sober should now be properly configured and installed!"
    info "lucem: To run Roblox, simply type:"
    info "lucem: `lucem run`"
    quit(0)
  else:
    info "lucem: Retrying."
    initializeRoblox(input, config)
    return

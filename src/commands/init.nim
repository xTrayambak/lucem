## This file implements `lucem init`, `lucem install-sober` and `lucem fetch-apk`
## Copyright (C) 2024 Trayambak Rai

import std/[logging, browsers, rdstdin, strutils]
import ../[flatpak, argparser, config, common]

const
  SOBER_FLATPAK_URL* {.strdefine: "SoberFlatpakUrl".} =
    "https://sober.vinegarhq.org/sober.flatpakref"
  APKMIRROR_URL* {.strdefine: "ApkMirrorUrl".} =
    "https://www.apkmirror.com/apk/roblox-corporation/roblox/roblox-$1-release/roblox-$1-android-apk-download"

proc initializeSober*(input: Input) {.inline.} =
  info "lucem: initializing sober"

  if not flatpakInstall(SOBER_FLATPAK_URL):
    error "lucem: failed to initialize sober."
    quit(1)

  info "lucem: installed sober successfully!"

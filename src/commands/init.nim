## This file implements `lucem init`
## Copyright (C) 2024 Trayambak Rai

import std/[logging]
import ../[flatpak, argparser]

const SOBER_FLATPAK_URL* {.strdefine: "SoberFlatpakUrl".} =
  "https://sober.vinegarhq.org/sober.flatpakref"

proc initializeSober*(input: Input) {.inline.} =
  info "lucem: initializing sober"

  if not flatpakInstall(SOBER_FLATPAK_URL):
    error "lucem: failed to initialize sober."
    quit(1)

  info "lucem: Installed Sober successfully!"
  info "lucem: You may run Roblox using `lucem run`"

## This file implements `lucem init`
## Copyright (C) 2024 Trayambak Rai

import std/[logging, strutils]
import ../[flatpak, argparser, common]

const
  SOBER_FLATPAK_URL* {.strdefine: "SoberFlatpakUrl".} =
    "https://sober.vinegarhq.org/sober.flatpakref"

proc initializeSober*(input: Input) {.inline.} =
  info "lucem: initializing sober"

  if not flatpakInstall(SOBER_FLATPAK_URL):
    error "lucem: failed to initialize sober."
    quit(1)

  info "lucem: installed sober successfully!"
  info "lucem: To run Roblox, simply type:"
  info "lucem: `lucem run`"
  quit(0)

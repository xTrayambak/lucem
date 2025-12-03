## Lucem is a bootstrapper for Sober (Roblox on Linux)
##
## Copyright (C) 2025 Trayambak Rai (xtrayambak@disroot.org)

import std/[random, os]
import pkg/owlkettle, pkg/owlkettle/adw
import pkg/[chronicles, shakar]
import application, meta, patch_loader, sober_dir

logScope:
  topics = "main"

const content = staticRead "patches/old-get-up.lpat.json"

proc main() {.inline.} =
  info "Lucem is now starting up", version = meta.Version

  # This is so professional
  randomize()
  echo sample(meta.Splashes)

  var loader: PatchLoader
  loader.loadPatch("old-get-up.lpat.js", content, official = true)
  loader.execute()

  runLucemApp()

  quit(QuitSuccess)

when isMainModule:
  main()

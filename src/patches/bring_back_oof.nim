## Patch to bring back the old "Oof" sound
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging, strutils]
import ../http

const
  LucemPatchOofSoundUrl* {.strdefine.} = "https://github.com/pizzaboxer/bloxstrap/raw/main/Bloxstrap/Resources/Mods/Sounds/OldDeath.ogg"
  SoberSoundResourcesPath* {.strdefine.} = "$1/.var/app/org.vinegarhq.Sober/data/sober/assets/content/sounds/"

proc enableOldOofSound*(enable: bool = true) =
  let
    basePath = SoberSoundResourcesPath % [getHomeDir()]
    newFp = basePath / "ouch.ogg.new"
    usedFp = basePath / "ouch.ogg"
    oldFp = basePath / "ouch.ogg.old"
  
  if enable:
    if not fileExists(newFp):
      info "patches: bringing back old oof sound"
      debug "patches: moving new oof sound to separate file"
      moveFile(usedFp, newFp)
      
      if not fileExists(oldFp):
        debug "patches: fetching old oof sound"
        let oldSound = httpGet(LucemPatchOofSoundUrl)
        writeFile(usedFp, oldSound)
      else:
        debug "patches: old sound is already downloaded, simply moving it instead."
        moveFile(oldFp, usedFp)

      info "patches: old oof sound should be restored!"
    else:
      debug "patches: old oof sound patch seems to be applied, ignoring."
  else:
    if not fileExists(newFp):
      debug "patches: old oof sound was not enabled, ignoring."
    else:
      info "patches: bringing back new oof sound"
      debug "patches: moving old oof sound to separate file"
      moveFile(usedFp, oldFp)
      moveFile(newFp, usedFp)

      info "patches: new oof sound should be restored!"

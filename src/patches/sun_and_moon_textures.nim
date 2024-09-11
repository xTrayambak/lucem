## Tweak the sun and moon textures
## Copyright (C) 2024 Trayambak Rai
import std/[os, strutils, logging]

const SoberSkyTexturesPath* {.strdefine.} =
  "$1/.var/app/org.vinegarhq.Sober/data/sober/assets/content/sky/"

proc setSunTexture*(path: string) =
  let basePath = SoberSkyTexturesPath % [getHomeDir()]

  if fileExists(basePath / "lucem_patched_sun") and
      readFile(basePath / "lucem_patched_sun") == path:
    debug "lucem: skipping patching sun texture - already marked as patched"
    return

  if path.len > 0:
    debug "lucem: patching sun texture to: " & path
    if not fileExists(path):
      error "lucem: cannot find file: " & path & " as a substitute for the sun texture!"
      quit(1)

    moveFile(basePath / "sun.jpg", basePath / "sun.jpg.old")
    copyFile(path, basePath / "sun.jpg")
    writeFile(basePath / "lucem_patched_sun", path)

    info "lucem: patched sun texture successfully!"
  else:
    if not fileExists(basePath / "lucem_patched_sun"):
      return

    debug "lucem: reverting sun texture to default"

    if not fileExists(basePath / "sun.jpg.old"):
      error "lucem: cannot restore sun texture to default as `sun.jpg.old` is missing!"
      error "lucem: you probably messed around with the files, run `lucem init` to fix everything."
      quit(1)

    removeFile(basePath / "lucem_patched_sun")
    moveFile(basePath / "sun.jpg.old", basePath / "sun.jpg")

    info "lucem: restored sun texture back to default successfully!"

proc setMoonTexture*(path: string) =
  let basePath = SoberSkyTexturesPath % [getHomeDir()]
  if fileExists(basePath / "lucem_patched_moon") and
      readFile(basePath / "lucem_patched_moon") == path:
    debug "lucem: skipping patching moon texture - already marked as patched"
    return

  if path.len > 0:
    debug "lucem: patching moon texture to: " & path
    if not fileExists(path):
      error "lucem: cannot find file: " & path & " as a substitute for the moon texture!"
      quit(1)

    moveFile(basePath / "moon.jpg", basePath / "moon.jpg.old")
    copyFile(path, basePath / "moon.jpg")
    writeFile(basePath / "lucem_patched_moon", path)

    info "lucem: patched moon texture successfully!"
  else:
    if not fileExists(basePath / "lucem_patched_moon"):
      return

    debug "lucem: reverting moon texture to default"

    if not fileExists(basePath / "moon.jpg.old"):
      error "lucem: cannot restore sun texture to default as `moon.jpg.old` is missing!"
      error "lucem: you probably messed around with the files, run `lucem init` to fix everything."
      quit(1)

    removeFile(basePath / "lucem_patched_moon")
    moveFile(basePath / "moon.jpg.old", basePath / "moon.jpg")

    info "lucem: restored moon texture back to default successfully!"

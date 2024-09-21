## Force Sober to use X11 or Wayland
## Copyright (C) 2024 Trayambak Rai
import std/[os, osproc, logging]
import ../[config, common, cache_calls]

proc setWindowingBackend*(backend: WindowingBackend) =
  if getState("windowing_backend", WindowingBackend, autodetectWindowingBackend()) ==
      backend:
    debug "lucem: windowing backend already set, ignoring."
    return

  let pkexec = findExe("pkexec") & ' '

  debug "lucem: setting windowing backend to " & $backend

  if backend == WindowingBackend.Wayland:
    debug "lucem: restricting X11 socket permissions from Sober"
    if execCmd(
      pkexec & "flatpak override --nofilesystem=/tmp/.X11-unix " & SOBER_APP_ID
    ) != 0:
      error "lucem: failed to restrict Sober's access to the X11 socket!"
      return

    debug "lucem: giving Sober access to the Wayland socket(s)"
    if execCmd(pkexec & "flatpak override --socket=wayland " & SOBER_APP_ID) != 0:
      error "lucem: failed to give Sober access to the Wayland socket!"
      return
  else:
    debug "lucem: giving Sober access to the X11 socket"
    if execCmd(pkexec & "flatpak override --filesystem=/tmp/.X11-unix " & SOBER_APP_ID) !=
        0:
      error "lucem: failed to give Sober access to the X11 socket!"
      return

    debug "lucem: restricting Wayland socket permissions from Sober"
    if execCmd(
      pkexec & "flatpak override --no-talk-name=org.freedesktop.Platform.Wayland " &
        SOBER_APP_ID
    ) != 0:
      error "lucem: failed to revoke Sober's access to the Wayland socket!"
      return

  storeState("windowing_backend", backend)

## Flatpak helper
## Copyright (C) 2024 Trayambak Rai

import std/[os, osproc, posix, logging, strutils]

proc flatpakInstall*(id: string, user: bool = true): bool {.inline, discardable.} =
  if findExe("flatpak").len < 1:
    error "flatpak: could not find flatpak executable! Are you sure that you have flatpak installed?"

  info "flatpak: install package \"" & id & '"'
  let (output, exitCode) =
    execCmdEx("flatpak install " & id & (if user: " --user" else: ""))

  if exitCode != 0 and not output.contains("is already installed"):
    error "flatpak: failed to install package \"" & id &
      "\"; flatpak process exited with abnormal exit code " & $exitCode
    error "flatpak: it also outputted the following:"
    error output
    false
  else:
    info "flatpak: successfully installed \"" & id & "\"!"
    true

proc soberRunning*: bool {.inline.} =
  execCmdEx("pidof sober").output.len > 2

proc flatpakRun*(
    id: string, path: string = "/dev/stdout", launcher: string = ""
): bool {.inline.} =
  info "flatpak: launching flatpak app \"" & id & '"'
  debug "flatpak: launcher = " & launcher

  let launcherExe = findExe(launcher)

  if launcherExe.len < 1 and launcher.len > 0:
    warn "flatpak: failed to find launcher executable for `" & launcher &
      "`; are you sure that it's in your PATH?"
    warn "flatpak: ignoring for now."

  if fork() == 0:
    debug "flatpak: we are the child - launching \"" & id & '"'
    discard execCmdEx(launcherExe & " flatpak run " & id & " > " & path)
    quit(0)
  else:
    debug "flatpak: we are the parent - continuing"

proc flatpakKill*(id: string): bool {.inline, discardable.} =
  info "flatpak: killing flatpak app \"" & id & '"'
  bool(execCmd("flatpak kill " & id))

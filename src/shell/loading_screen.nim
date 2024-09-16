## Loading screen which shows up when `lucem run` is invoked
## Copyright (C) 2024 Trayambak Rai
import std/[logging, locks]
import owlkettle, owlkettle/adw, owlkettle/bindings/gtk

type LoadingState* = enum
  WaitingForLaunch
  WaitingForRoblox
  Done
  Exited

viewable LoadingScreen:
  state:
    ptr LoadingState

  scheduledDeath:
    bool

  slock:
    Lock

method view*(app: LoadingScreenState): Widget =
  debug "shell: loading screen is being reupdated"
  debug "shell: app state: \"" & $app.state[] & '"'

  proc refresh(): bool =
    debug "shell: refresh: acquiring lock on `ptr LoadingState`"
    withLock app.slock:
      if app.state[] == Done:
        debug "shell: loading screen is done, hiding surface"
        app.scheduledDeath = true
        gtk_widget_hide(app.unwrapInternalWidget())
      elif app.state[] == Exited:
        debug "shell: roblox exited, we're quitting"
        quit(0)

    true

  discard addGlobalTimeout(100, refresh)

  result = gui:
    Window:
      title = "Lucem"
      defaultSize = (637, 246)

      Box:
        Label {.hAlign: AlignCenter, vAlign: AlignCenter.}:
          text = "<span size=\"x-large\"><b>Loading Roblox...</b></span>"
          useMarkup = true

proc initLoadingScreen*(state: ptr LoadingState, lock: Lock) {.inline.} =
  adw.brew(gui(LoadingScreen(state = state, slock = lock, scheduledDeath = false)))

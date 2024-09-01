## Loading screen which shows up when `lucem run` is invoked
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging, locks]
import owlkettle, owlkettle/adw

type
  LoadingState* = enum
    WaitingForLaunch
    WaitingForRoblox
    Done

func `$`*(state: LoadingState): string {.inline.} =
  case state
  of WaitingForLaunch: "Waiting for Sober to initialize"
  of WaitingForRoblox: "Waiting for Roblox to launch"
  of Done: "Done!"

viewable LoadingScreen:
  state: ptr LoadingState
  scheduledDeath: bool
  slock: Lock

method view*(app: LoadingScreenState): Widget =
  debug "shell: loading screen is being reupdated"
  debug "shell: app state: \"" & $app.state[] & '"'

  proc die: bool =
    app.closeWindow()

  proc refresh: bool =
    debug "shell: refresh: acquiring lock on `ptr LoadingState`"
    withLock app.slock:
      if app.state[] == Done and not app.scheduledDeath:
        debug "shell: loading screen is done, scheduled the destruction of the GTK4 surface by next redraw"
        app.scheduledDeath = true
        discard addGlobalIdleTask(die)
        discard app.redraw()
        return false

    true
      
  discard addGlobalTimeout(100, refresh)

  result = gui:
    Window:
      title = "Lucem"
      sizeRequest = (283, 71)

      Box:
        Spinner:
          spinning = true

        Label:
          text = "<b>" & $app.state[] & "</b>"
          useMarkup = true

proc initLoadingScreen*(
  state: ptr LoadingState,
  lock: Lock
) {.inline.} =
  adw.brew(
    gui(
      LoadingScreen(state = state, slock = lock, scheduledDeath = false)
    )
  )

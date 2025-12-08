## Application code
##
## Copyright (C) 2025 Trayambak Rai (xtrayambak@disroot.org)
## Copyright (C) 2025 AshtakaOOf
import std/[logging, os, options, posix, json, strutils, sequtils, sugar]
import pkg/owlkettle, pkg/owlkettle/[playground, adw]
import pkg/[chronicles, shakar]
#!fmt: off
import bindings/libadwaita, adw/about,
       config, resource_loader, store, viewable
#!fmt: on
import worker/[launcher, types]

logScope:
  topics = "application"

# I'm thinking it'd be cleaner idk
const TITLE = "Lucem"

proc setState(app: SettingsMenuState, state: SettingsState) =
  if app.state == state:
    return

  debug "settings: state=" & $state
  app.collapsed = true
  app.state = state

method view(app: SettingsMenuState): Widget =
  result = gui:
    Window:
      title = TITLE
      defaultSize = (600, 400)

      AdwHeaderBar {.addTitlebar.}:
        showTitle = true
        #style = HeaderBarFlat

        Button {.addLeft.}:
          icon = "sidebar-show-symbolic"
          style = [ButtonFlat]

          proc clicked() =
            app.collapsed = not app.collapsed
            debug "settings: collapsed: " & $app.collapsed

        Button {.addLeft.}:
          icon = "shopping-cart-symbolic"
            # use tag-symbolic if i can't find a way to theme it to dark mode
          style = [ButtonFlat]

          proc clicked() =
            openPatchStore(app)

        # Unless we add more options in here I'm commenting it out
        # Also added a save and quit if you ever want to use it
        MenuButton {.addRight.}:
          icon = "open-menu-symbolic"
          style = [ButtonFlat]

          PopoverMenu:
            sensitive = true
            sizeRequest = (-1, -1)
            position = PopoverBottom

            Box {.name: "main".}:
              orient = OrientY
              margin = 4
              spacing = 3

              ModelButton:
                text = "Save changes"

                proc clicked() =
                  info "Saving configuration changes"

              ModelButton:
                text = "About Lucem"

                proc clicked() =
                  openAboutMenu(app)

              #Separator()

              #[ModelButton:
                text = "Save and Quit"

                proc clicked() =
                  info "lucem: saving configuration changes"
                  app.config[].save()
                  info "lucem: closing settings app..."
                  quit()]#

        Button {.addRight.}:
          icon = "media-playback-start-symbolic"
          tooltip = "Start Sober"
          style = [ButtonSuggested]

          proc clicked() =
            info "Should be launching Sober"

        #[Button {.addRight.}:
          icon = "help-about-symbolic"
          tooltip = "Open the About Window"
          style = [ButtonFlat]

          proc clicked() =
            openAboutMenu(app)]#

        #[Button {.addRight.}:
          icon = "media-floppy-symbolic"
          tooltip = "Save changes"
          style = [ButtonFlat]

          proc clicked() =
            info "Saving configuration changes"]#

      OverlaySplitView:
        collapsed = not app.collapsed
        enableHideGesture = true
        enableShowGesture = true
        showSidebar = not app.collapsed
        sensitive = true
        sizeRequest = (-1, -1)
        minSidebarWidth = 350f

        Box {.addSidebar.}:
          orient = OrientY
          spacing = 8
          margin = 8
          Button {.expand: false.}:
            ButtonContent:
              label = "General Settings"
              iconName = "user-home-symbolic"
              style = [StyleClass("sidebar-button"), ButtonFlat]
              useUnderline = false

            proc clicked() =
              app.setState(SettingsState.General)

          Button {.expand: false.}:
            ButtonContent:
              label = "Patches"
              iconName = "video-display-symbolic"
              style = [ButtonFlat]
              useUnderline = false

            proc clicked() =
              app.setState(SettingsState.Patches)

        case app.state
        of SettingsState.General:
          Clamp:
            maximumSize = 500
            margin = 12
            Box:
              orient = OrientY
              spacing = 12

              PreferencesGroup {.expand: false.}:
                title = "General Settings"
                description = "These settings dictate Lucem's behaviour."

                ActionRow:
                  title = "Show Discord RPC"
                  subtitle =
                    "When enabled, Lucem will display the current experience you're playing on Discord."
                  tooltip = "This is enabled by default"

                  Switch() {.addSuffix.}:
                    state = app.config.discordRpc

                    proc changed(state: bool) =
                      app.config.discordRpc = state

              PreferencesGroup {.expand: false.}:
                title = "Rendering Parameters"
                description =
                  "These settings control how rendering is handled by Sober."

                ComboRow:
                  title = "Rendering Backend"
                  subtitle = "Only modify if you have issues with Vulkan."
                  tooltip = "Default is Vulkan"

                  items =
                    @["Vulkan", "OpenGL"]
                      #[selected = app.selected

                  proc select(index: int) =
                    app.selected = index

                    case index
                    of 0:
                      app.config.renderer = "vulkan"
                    of 1:
                      app.config.renderer = "opengl"
                    else:
                      echo "Error: Invalid index from Rendering Backend ComboRow: ",
                        index
                      app.config.renderer = "vulkan"
                      app.selected = 0]#

                ActionRow:
                  title = "Maximum FPS"
                  subtitle = "If you have VSync enabled, this will be ignored."
                  tooltip = "Default is 60"

                  Entry {.addSuffix.}:
                    text = (
                      if *app.config.maxFps:
                        $(&app.config.maxFps)
                      else:
                        "60"
                    )

                    proc changed(text: string) =
                      try:
                        app.config.maxFps = some(parseUint(text).uint16)
                      except ValueError:
                        discard

              PreferencesGroup {.expand: true.}:
                title = "Advanced Parameters"
                description =
                  "<b>Do not modify these settings if you aren't aware of what they do</b>."
        else:
          discard

proc runLucemApp*() =
  let events: array[1, ApplicationEvent] = [
    proc(_: WidgetState) {.closure.} =
      loadAppAssets()
  ]

  var config = loadConfig()
  var worker = startWorkerThread()

  worker.comm[].send(WorkerOp.FetchPatchIndex)

  adw.brew(
    gui(SettingsMenu(collapsed = true, config = config, worker = worker)),
    startupEvents = events,
    stylesheets = [],
  )

  config.save()

  debug "Waiting for worker thread to shut down"
  worker.comm[].send(WorkerOp.Exit)
  worker.thread.joinThread()
  worker.comm[].close()

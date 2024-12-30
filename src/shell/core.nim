## Lucem shell
## "soon:tm:" - tray
## Copyright (C) 2024 Trayambak Rai
import std/[os, strutils, json, logging, posix, tables, osproc]
import owlkettle, owlkettle/adw
import
  ../[config, argparser, cache_calls, fflags, notifications, desktop_files, fs, sober_config]

type ShellState* {.pure.} = enum
  Client
  Lucem
  Tweaks
  FflagEditor

viewable LucemShell:
  state:
    ShellState = Client
  config:
    ptr Config

  showFpsCapOpt:
    bool
  showFpsCapBuff:
    string

  telemetryOpt:
    bool

  backendOpt:
    seq[string] = @["Wayland", "X11"]
  backendBuff:
    int

  launcherBuff:
    string

  discordRpcOpt:
    bool
  serverLocationOpt:
    bool

  oldOofSound:
    bool
  customFontPath:
    string

  sunImgPath:
    string
  moonImgPath:
    string

  apkVersionBuff:
    string
  currFflagBuff:
    string

  prevFflagBuff:
    string

  automaticApkUpdates:
    bool

  pollingDelayBuff:
    string

method view(app: LucemShellState): Widget =
  var parsedFflags: SoberFFlags
  try:
    parseFflags(app.config[], parsedFflags)
  except FFlagParseError as exc:
    warn "shell: failed to parse fflags: " & exc.msg
    notify("Failed to parse FFlags", exc.msg)
    debug "shell: reverting to previous state"
    app.config[].client.fflags = app.prevFflagBuff
    app.currFflagBuff = app.prevFflagBuff

  result = gui:
    Window:
      title = "Lucem"
      defaultSize = (860, 640)

      AdwHeaderBar {.addTitlebar.}:
        centeringPolicy = CenteringPolicyLoose
        showTitle = true
        sizeRequest = (-1, -1)

        Button {.addLeft.}:
          sensitive = true
          #icon = "view-list-bullet-rtl-symbolic"
          text = "Features"
          tooltip = "The features provided by Lucem"

          proc clicked() =
            app.state = ShellState.Lucem

        Button {.addLeft.}:
          sensitive = true
          #icon = "applications-games-symbolic"
          text = "Client"
          tooltip = "Basic settings for Sober (e.g. framerate cap)"

          proc clicked() =
            app.state = ShellState.Client

        Button {.addLeft.}:
          sensitive = true
          #icon = "applications-science-symbolic"
          text = "Tweaks"
          tooltip = "Restore the Oof sound, use custom fonts and more"

          proc clicked() =
            app.state = ShellState.Tweaks

        Button {.addLeft.}:
          sensitive = true
          #icon = "utilities-terminal-symbolic"
          text = "FFlags"
          tooltip = "Add and remove FFlags easily"

          proc clicked() =
            app.state = ShellState.FflagEditor

        Button {.addRight.}:
          style = [ButtonFlat]
          icon = "media-floppy-symbolic" # floppy disk as a save icon (system icon)
          tooltip = "Save the modified configuration"

          proc clicked() =
            debug "shell: updated configuration file"
            app.config[].save()

        Button {.addRight.}:
          style = [ButtonFlat]
          icon = "bookmark-new-symbolic"
          tooltip = "Add desktop entries for Lucem"

          proc clicked() =
            debug "shell: created .desktop files"
            createLucemDesktopFile()

        Button {.addRight.}:
          style = [ButtonFlat]
          icon = "input-gaming-symbolic"
          tooltip = "Save configuration and launch Sober trough Lucem"

          proc clicked() =
            debug "shell: save config, exit config editor and launch lucem"
            app.config[].save()
            app.scheduleCloseWindow()

            if fork() == 0:
              debug "shell: we are the child - launching `lucem run`"
              quit(execCmd("lucem run"))
            else:
              debug "shell: we are the parent - quitting"
              quit(0)

      Box:

        case app.state
        of ShellState.Tweaks:
          PreferencesPage:

            PreferencesGroup:
              sizeRequest = (760, 560)
              title = "Tweaks and Patches"
              description = "These are some optional tweaks to customize your experience."

              ActionRow:
                title = "Bring Back the Old \"Oof\" Sound"
                subtitle =
                  "This replaces the new \"Eugh\" death sound with the classic \"Oof\" sound."
                CheckButton {.addSuffix.}:
                  state = app.oldOofSound

                  proc changed(state: bool) =
                    app.oldOofSound = not app.oldOofSound
                    app.config[].tweaks.oldOof = app.oldOofSound

                    debug "shell: old oof sound state: " & $app.oldOofSound

              ActionRow:
                title = "Custom Client Font"
                subtitle =
                  "Force the Roblox client to use a particular font whenever possible."

                Entry {.addSuffix.}:
                  text = app.customFontPath

                  proc changed(text: string) =
                    debug "shell: custom font entry changed: " & text
                    app.customFontPath = text

                  proc activate() =
                    let font = app.customFontPath.expandTilde()
                    if font.len > 0 and not isAccessible(font):
                      notify("Cannot set custom font", "File not accessible.")
                      return

                    app.config[].tweaks.font = font
                    debug "shell: custom font path is set to: " & app.customFontPath

              ActionRow:
                title = "Custom Sun Texture"
                subtitle =
                  "For games that do not set a custom sun texture, your specified texture will be shown instead."

                Entry {.addSuffix.}:
                  text = app.sunImgPath
                  placeholder = ""

                  proc changed(text: string) =
                    debug "shell: sun image entry changed: " & text
                    app.sunImgPath = text

                  proc activate() =
                    let path = app.sunImgPath.expandTilde()
                    if path.len > 0 and not isAccessible(path):
                      notify("Cannot set sun texture", "Texture file not accessible.")
                      return

                    app.config[].tweaks.sun = path
                    debug "shell: custom sun texture path is set to: " & app.sunImgPath

              ActionRow:
                title = "Custom Moon Texture"
                subtitle =
                  "For games that do not set a custom moon texture, your specified texture will be shown instead."

                Entry {.addSuffix.}:
                  text = app.moonImgPath
                  placeholder = ""

                  proc changed(text: string) =
                    debug "shell: moon image entry changed: " & text
                    app.moonImgPath = text

                  proc activate() =
                    let path = app.moonImgPath.expandTilde()
                    if path.len > 0 and not isAccessible(path):
                      notify("Cannot set moon texture", "Texture file not accessible.")
                      return

                    app.config[].tweaks.moon = path
                    debug "shell: custom moon texture path is set to: " & app.sunImgPath

        of ShellState.Lucem:
          PreferencesPage:

            PreferencesGroup:
              sizeRequest = (760, 560)
              title = "Lucem Settings"
              description =
                "These are settings to tweak the features that Lucem provides."

              ActionRow:
                title = "Discord Rich Presence"
                subtitle =
                  "This requires you to have either the official Discord client or an arRPC-based one."
                CheckButton {.addSuffix.}:
                  state = app.discordRpcOpt

                  proc changed(state: bool) =
                    app.discordRpcOpt = not app.discordRpcOpt
                    app.config[].lucem.discordRpc = app.discordRpcOpt

                    debug "shell: discord rpc option state: " &
                      $app.config[].lucem.discordRpc

              ActionRow:
                title = "Notify the Server Region"
                subtitle =
                  "When you join a game, a notification will be sent containing where the server is located."
                CheckButton {.addSuffix.}:
                  state = app.serverLocationOpt

                  proc changed(state: bool) =
                    app.serverLocationOpt = not app.serverLocationOpt
                    app.config[].lucem.notifyServerRegion = app.serverLocationOpt

                    debug "shell: notify server region option state: " &
                      $app.config[].lucem.notifyServerRegion

              ActionRow:
                title = "Clear all API caches"
                subtitle =
                  "This will clear all the API call caches. Some features might be slower next time you run Lucem."
                Button {.addSuffix.}:
                  icon = "user-trash-symbolic"
                  style = [ButtonDestructive]

                  proc clicked() =
                    let savedMb = clearCache()
                    info "shell: cleared out cache and reclaimed " & $savedMb &
                      " MB of space."
                    notify("Cleared API cache", $savedMb & " MB of space was freed.")

        of ShellState.FflagEditor:
          PreferencesPage:

            PreferencesGroup:
              sizeRequest = (760, 560)
              title = "FFlag Editor"
              description =
                "Please keep in mind that some games prohibit the modifications of FFlags. You might get banned from them due to modifying FFlags. Modifying FFlags can also make the Roblox client unstable in some cases. Do not touch these if you don't know what you're doing!"

              Box(orient = OrientY, spacing = 6, margin = 12):
                Box(orient = OrientX, spacing = 6) {.expand: false.}:
                  Entry:
                    text = app.currFflagBuff
                    placeholder = "Key=Value"

                    proc changed(text: string) =
                      app.currFflagBuff = text
                      debug "shell: fflag entry mutated: " & app.currFflagBuff

                    proc activate() =
                      debug "shell: fflag entry: " & app.currFflagBuff

                      # TODO: add validation
                      app.config.client.fflags &= '\n' & app.currFflagBuff

                  Button {.expand: false.}:
                    icon = "list-add-symbolic"
                    style = [ButtonSuggested]

                    proc clicked() =
                      # TODO: add validation
                      app.config[].client.fflags &= '\n' & app.currFflagBuff

                      debug "shell: fflag entry: " & app.currFflagBuff

                Frame:
                  ScrolledWindow:
                    ListBox:
                      for key, value in parsedFflags:
                        Box:
                          spacing = 6
                          Label:
                            xAlign = 0
                            text =
                              key & " = " & (
                                if value.kind == JString:
                                  value.getStr()
                                elif value.kind == JInt:
                                  $value.getInt()
                                elif value.kind == JBool:
                                  $value.getBool()
                                elif value.kind == JFloat:
                                  $value.getFloat()
                                else: "<invalid type>"
                              )

                          Button {.expand: false.}:
                            icon = "list-remove-symbolic"
                            style = [ButtonDestructive]

                            proc clicked() =
                              # FIXME: move the line selection and deletion code to src/fflags.nim! this is a total mess!
                              debug "shell: deleting fflag: " & key
                              app.prevFflagBuff = app.currFflagBuff

                              var
                                i = -1
                                line = -1
                                fflags =
                                  app.config[].client.fflags.splitLines().deepCopy()

                              for l in app.config[].client.fflags.splitLines():
                                inc i
                                if l.startsWith(key):
                                  line = i
                                  break

                              assert line != -1,
                                "Cannot find line at which key \"" & key & "\" is defined!"
                              debug "shell: config key to delete is at line " & $line
                              fflags.del(line)

                              app.config[].client.fflags = newString(0)
                              for i, line in fflags:
                                app.config[].client.fflags &= line
                                if i >= fflags.len - 1:
                                  app.config[].client.fflags &= '\n'

        of ShellState.Client:
          PreferencesPage:

            PreferencesGroup:
              sizeRequest = (760, 560)
              title = "Client Settings"
              description = "These settings are mostly applied via FFlags."

              ActionRow:
                title = "Disable Telemetry"
                subtitle =
                  "Disable all* telemetry that the Roblox client exposes via FFlags."
                CheckButton {.addSuffix.}:
                  state = app.telemetryOpt

                  proc changed(state: bool) =
                    app.telemetryOpt = not app.telemetryOpt
                    app.config[].client.telemetry = app.telemetryOpt

                    debug "shell: disable telemetry is now set to: " & $app.telemetryOpt

              ActionRow:
                title = "Disable FPS cap"
                subtitle = "Some games might ban you if they detect this. Note: Games dependent on framerate might misbehave."
                CheckButton {.addSuffix.}:
                  state = app.showFpsCapOpt

                  proc changed(state: bool) =
                    app.showFpsCapOpt = not app.showFpsCapOpt
                    app.config[].client.fps = if state: 9999 else: 60

                    debug "shell: disable/enable fps cap button state: " &
                      $app.showFpsCapOpt
                    debug "shell: fps is now set to: " & $app.config[].client.fps

              if app.showFpsCapOpt:
                ActionRow:
                  title = "FPS Cap"
                  subtitle = "Change the FPS cap to values Roblox doesn't offer. Avoid using a value above the monitor refresh rate."
                  Entry {.addSuffix.}:
                    text = app.showFpsCapBuff
                    placeholder = "e.g. 30, 60 (default), 144, etc."

                    proc changed(text: string) =
                      debug "shell: fps cap entry changed: " & text
                      app.showFpsCapBuff = text

                    proc activate() =
                      try:
                        debug "shell: parse fps cap buffer as integer: " &
                          app.showFpsCapBuff
                        let val = parseInt(app.showFpsCapBuff)
                        app.config[].client.fps = val
                        debug "shell: fps cap is now set to: " & $app.config[].client.fps
                      except ValueError as exc:
                        debug "shell: fps cap buffer has invalid value: " &
                          app.showFpsCapBuff
                        debug "shell: " & exc.msg

              ComboRow:
                title = "Backend"
                subtitle =
                  "Which display server Sober will use, on Wayland X11 will use Xwayland."
                items = app.backendOpt
                selected = app.backendBuff

                proc select(selectedIndex: int) =
                  debug "shell: launcher entry changed: " & app.backendOpt[selectedIndex]
                  app.backendBuff = selectedIndex

                proc activate() =
                  app.config[].client.backend = app.backendOpt[app.backendBuff]
                  debug "shell: backend is set to: " & app.backendOpt[app.backendBuff]

              ActionRow:
                title = "Launcher"
                subtitle =
                  "Lucem will launch Sober with a specified command. Leave this empty if you don't require it."
                Entry {.addSuffix.}:
                  text = app.launcherBuff
                  placeholder = "Eg. gamemoderun"

                  proc changed(text: string) =
                    debug "shell: launcher entry changed: " & text
                    app.launcherBuff = text

                  proc activate() =
                    app.config[].client.launcher = app.launcherBuff
                    debug "shell: launcher is set to: " & app.launcherBuff

              ActionRow:
                title = "Polling Delay"
                subtitle =
                  "Add a tiny delay in seconds to the event watcher thread. This barely impacts performance on modern systems."

                Entry {.addSuffix.}:
                  text = app.pollingDelayBuff
                  placeholder = "100 is sufficient for most modern systems"

                  proc changed(text: string) =
                    debug "shell: polling delay entry changed: " & text
                    app.pollingDelayBuff = text

                  proc activate() =
                    try:
                      app.config[].lucem.pollingDelay = app.pollingDelayBuff.parseUint()
                      debug "shell: polling delay is set to: " & app.pollingDelayBuff
                    except ValueError as exc:
                      warn "shell: failed to parse polling delay (" & app.pollingDelayBuff &
                        "): " & exc.msg

              ActionRow:
                title = "Automatic APK Updates"
                subtitle =
                  "If enabled, Sober will automatically fetch the latest versions of Roblox's APK for you from the Play Store."
                CheckButton {.addSuffix.}:
                  state = app.automaticApkUpdates

                  proc changed(state: bool) =
                    app.automaticApkUpdates = state
                    app.config[].client.apkUpdates = state

proc initLucemShell*(input: Input) {.inline.} =
  info "shell: initializing GTK4 shell"
  info "shell: libadwaita version: v" & $AdwVersion[0] & '.' & $AdwVersion[1]
  var config = parseConfig(input)

  adw.brew(
    gui(
      LucemShell(
        config = addr(config),
        state = ShellState.Lucem,
        showFpsCapOpt = config.client.fps != 9999,
        showFpsCapBuff = $config.client.fps,
        discordRpcOpt = config.lucem.discordRpc,
        telemetryOpt = config.client.telemetry,
        launcherBuff = config.client.launcher,
        serverLocationOpt = config.lucem.notifyServerRegion,
        customFontPath = config.tweaks.font,
        oldOofSound = config.tweaks.oldOof,
        sunImgPath = config.tweaks.sun,
        moonImgPath = config.tweaks.moon,
        pollingDelayBuff = $config.lucem.pollingDelay,
        automaticApkUpdates = config.client.apkUpdates,
      )
    )
  )

  info "lucem: saving configuration changes"
  config.save()
  info "lucem: done!"

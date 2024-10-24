## Run the Roblox client, update FFlags and optionally, provide Discord RPC and other features.
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging, strutils, json, times, locks]
import colored_logger, discord_rpc
import ../api/[games, thumbnails, ipinfo]
import
  ../patches/[bring_back_oof, patch_fonts, sun_and_moon_textures, windowing_backend]
import ../shell/loading_screen
import
  ../[
    argparser, config, flatpak, common, meta, sugar, notifications, fflags, log_file,
    sober_state,
  ]

const FFlagsFile* =
  "$1/.var/app/$2/data/sober/exe/ClientSettings/ClientAppSettings.json"

let fflagsFile = FFlagsFile % [getHomeDir(), SOBER_APP_ID]

proc updateConfig*(input: Input, config: Config) =
  info "lucem: updating config"
  if not fileExists(fflagsFile):
    error "lucem: could not open pre-existing FFlags file. Run `lucem init` first."
    quit(1)

  var fflags = readFile(fflagsFile).parseJson()

  info "lucem: target FPS is set to: " & $config.client.fps
  fflags["DFIntTaskSchedulerTargetFps"] = newJInt(int(config.client.fps))

  if not config.client.telemetry:
    info "lucem: disabling telemetry FFlags"
  else:
    warn "lucem: enabling telemetry FFlags. This is not recommended!"

  if not input.enabled("skip-patching", "N"):
    enableOldOofSound(config.tweaks.oldOof)
    setWindowingBackend(config.backend())
    patchSoberState(input, config)
    setClientFont(config.tweaks.font, config.tweaks.excludeFonts)
    setSunTexture(config.tweaks.sun)
    setMoonTexture(config.tweaks.moon)
  else:
    info "lucem: skipping patching (--skip-patching or -S was provided)"

  for flag in [
    "FFlagDebugDisableTelemetryEphemeralCounter",
    "FFlagDebugDisableTelemetryEphemeralStat", "FFlagDebugDisableTelemetryEventIngest",
    "FFlagDebugDisableTelemetryPoint", "FFlagDebugDisableTelemetryV2Counter",
    "FFlagDebugDisableTelemetryV2Event", "FFlagDebugDisableTelemetryV2Stat",
  ]:
    debug "lucem: set flag `" & flag & "` to " & $(not config.client.telemetry)
    fflags[flag] = newJBool(not config.client.telemetry)

  parseFFlags(config, fflags)

  let serialized = pretty(fflags)
  info "Writing FFlags JSON:"
  info serialized

  writeFile(fflagsFile, serialized)

proc onGameJoin*(
    config: Config, data: string, discord: Option[DiscordRPC], startedAt: float
) =
  var
    foundBeginningOfJson = false
    jdata: string

  for c in data:
    if not foundBeginningOfJson:
      if c == '{':
        foundBeginningOfJson = true
        jdata &= c

      continue
    else:
      jdata &= c

  debug "lucem: join metadata: " & jdata

  if config.lucem.discordRpc and *discord:
    let
      placeId = $parseJson(jdata)["placeId"].getInt()
      universeId = getUniverseFromPlace(placeId)
      client = &discord

      gameData = getGameDetail(universeId)
      thumbnail = getGameIcon(universeId)

    if !gameData:
      warn "lucem: failed to fetch game data; RPC will not be set."
      return

    if !thumbnail:
      warn "lucem: failed to fetch game thumbnail; RPC will not be set."
      return

    let
      data = &gameData
      icon = &thumbnail

    info "lucem: Joined game!"
    info "Name: " & data.name
    info "Description: " & data.description
    info "Price: " & $(if *data.price: &data.price else: 0'i64) & " robux"
    info "Developer: "
    info "  Name: " & data.creator.name
    info "  Verified: " & $data.creator.hasVerifiedBadge

    client.setActivity(
      Activity(
        details: "Playing " & data.name,
        state: "by " & data.creator.name,
        assets: some(
          ActivityAssets(
            largeImage: icon.imageUrl, largeText: "Sober + Lucem v" & Version
          )
        ),
        timestamps: ActivityTimestamps(start: startedAt.int64),
      )
    )

proc onServerIpRevealed*(config: Config, line: string) =
  if not config.lucem.notifyServerRegion:
    return

  var
    buffer: string
    pos = -1

  debug "lucem: server IP line buffer: " & line

  while pos < line.len - 1:
    inc pos

    if buffer.endsWith("UDMUX server "):
      break

    buffer &= line[pos]

  debug "lucem: server IP line buffer stopped before splitting at: " & $pos
  let serverIp = line[pos ..< line.len].split(',')[0].split(':')[0]
    # discard port, we don't need it.
  debug "lucem: server IP is: " & serverIp

  if (let ipinfo = getIpInfo(serverIp); *ipinfo):
    let data = &ipinfo
    notify(
      "Server Location",
      "This server is located in $1, $2, $3" % [data.city, data.region, data.country],
      10000,
    )
  else:
    warn "lucem: failed to get server location data!"
    notify("Server Location", "Failed to fetch server location data.", 10000)

proc onGameLeave*(config: Config, discord: Option[DiscordRPC]) =
  debug "lucem: left experience"

  if !discord:
    return

  let client = &discord

  client.setActivity(
    Activity(
      details: "Playing Roblox with Lucem (Sober)",
      state: "In the Roblox app",
      timestamps: ActivityTimestamps(start: epochTime().int64),
    )
  )

proc onBloxstrapRpc*(config: Config, discord: Option[DiscordRPC], line: string) =
  assert false
  debug "lucem: trying to extract BloxstrapRPC payload from line"
  debug "lucem: " & line
  let payload = line.split("[FLog::Output] [BloxstrapRPC]")

  if payload.len < 2:
    warn "lucem: failed to obtain BloxstrapRPC JSON payload as split results in one or less element."
    warn "lucem: " & line
    return

proc eventWatcher*(
    args:
      tuple[
        state: ptr LoadingState,
        slock: ptr Lock,
        discord: Option[DiscordRPC],
        config: Config,
        input: Input,
      ]
) =
  addHandler newColoredLogger()
  setLogFilter(lvlInfo)
  var verbose = false

  if args.input.enabled("verbose", "v"):
    verbose = true
    setLogFilter(lvlAll)

  info "lucem: this is the event watcher thread, running at thread ID " & $getThreadId()

  var
    line = 0
    startedPlayingAt = 0.0
    startingTime = 0.0
    hasntStarted = true

    soberIsRunning = false
    ticksUntilSoberRunCheck = 0

  while hasntStarted or soberIsRunning:
    let logFile = readFile(getSoberLogPath()).splitLines()

    if ticksUntilSoberRunCheck < 1:
      debug "lucem: checking if sober is still running"
      soberIsRunning = soberRunning()
      ticksUntilSoberRunCheck = 5000

    dec ticksUntilSoberRunCheck

    if logFile.len - 1 < line:
      continue

    let data = logFile[line]
    if data.len < 1:
      inc line
      continue

    if verbose or not defined(release):
      echo data

    if data.contains("OnLoad: ... Done"):
      debug "lucem: this is the event watcher thread - Sober has been initialized! Acquiring lock to loading screen state pointer and setting it to `WaitingForRoblox`"

      withLock args.slock[]:
        args.state[] = WaitingForRoblox

      debug "lucem: released loading screen state pointer lock"

    if data.contains("[FLog::Graphics] Vulkan: creating framebuffer"):
      debug "lucem: this is the event watcher thread - Roblox has initialized a surface! Acquiring lock to loading screen state pointer and setting it to `Done`"

      withLock args.slock[]:
        args.state[] = Done

      debug "lucem: released loading screen state pointer lock"

    if data.contains(
      "[FLog::GameJoinUtil] GameJoinUtil::joinGamePostStandard: URL: https://gamejoin.roblox.com/v1/join-game BODY:"
    ):
      startedPlayingAt = epochTime()
      startingTime = startedPlayingAt

      onGameJoin(args.config, data, args.discord, startedPlayingAt)

    if data.contains("[FLog::Output] Connecting to UDMUX server"):
      onServerIpRevealed(args.config, data)

    if data.contains("[FLog::Output] [BloxstrapRPC]"):
      onBloxstrapRpc(args.config, args.discord, data)

    if data.contains("[FLog::Network] Client:Disconnect") or
        data.contains("[FLog::SingleSurfaceApp] handleGameWillClose") or
        data.contains("[FLog::Network] Connection lost - Cannot contact server/client"):
      onGameLeave(args.config, args.discord)

    sleep(args.config.lucem.pollingDelay.int)
    hasntStarted = false
    inc line

  withLock args.slock[]:
    args.state[] = Exited

  info "lucem: Sober seems to have exited - we'll stop here too. Adios!"

proc runRoblox*(input: Input, config: Config) =
  var startingTime = epochTime()
  info "lucem: running Roblox via Sober"

  writeFile(getSoberLogPath(), newString(0))
  var discord: Option[DiscordRPC]

  if config.lucem.discordRpc:
    info "lucem: connecting to Discord RPC"
    var client = newDiscordRPC(DiscordRpcId.int64)

    try:
      discard client.connect()

      client.setActivity(
        Activity(
          details: "Playing Roblox with Lucem (Sober)",
          state: "In the Roblox app",
          timestamps: ActivityTimestamps(start: startingTime.int64),
        )
      )

      discord = some(move(client))
    except CatchableError as exc:
      warn "lucem: unable to connect to Discord RPC: " & exc.msg

  debug "lucem: initialize lock that guards `LoadingState` pointer"
  var slock: Lock
  initLock(slock)

  var state {.guard: slock.} = WaitingForLaunch

  debug "lucem: creating event watcher thread"
  var evThr: Thread[
    tuple[
      state: ptr LoadingState,
      slock: ptr Lock,
      discord: Option[DiscordRPC],
      config: Config,
      input: Input,
    ]
  ]
  createThread(evThr, eventWatcher, (addr state, addr slock, discord, config, input))

  info "lucem: redirecting sober logs to: " & getSoberLogPath()
  discard flatpakRun(SOBER_APP_ID, getSoberLogPath(), config.client.launcher)

  #[ if config.lucem.loadingScreen:
    debug "lucem: creating loading screen GTK4 surface"
    initLoadingScreen(addr state, slock) ]#
  if config.lucem.loadingScreen:
    warn "lucem: the loading screen is currently malfunctioning after the new Sober update. It'll be fixed soon. Sorry! :("

  debug "lucem: loading screen has ended, waiting for event watcher thread to exit or die."
  evThr.joinThread()

  debug "lucem: event watcher thread has exited."
  quit(0)

## Lucem daemon
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging, strutils, json]
import ./[argparser, config, sugar, proto, notifications]
import ./api/[games, thumbnails, ipinfo]
import pkg/[colored_logger, netty, pretty]

const
  Version* {.strdefine: "NimblePkgVersion".} = "???"

type
  Daemon* = object
    reactor*: Reactor
    config*: Config
    shouldQuit*: bool = false

proc onGameJoined*(daemon: var Daemon, data: string) =
  var
    foundBeginningOfJson = false
    jdata: string

  for c in data:
    if c == '}':
      jdata &= '}'
      break

    if not foundBeginningOfJson:
      if c == '{':
        foundBeginningOfJson = true
        jdata &= c

      continue
    else:
      jdata &= c

  debug "lucem: join metadata: " & jdata

  let
    placeId = $parseJson(jdata)["placeId"].getInt()
    universeId = getUniverseFromPlace(placeId)

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
  info "Price: " & (if *data.price: $(&data.price) & " robux" else: "free")
  info "Developer: "
  info "  Name: " & data.creator.name
  info "  Verified: " & $data.creator.hasVerifiedBadge

proc onServerIPRevealed*(daemon: var Daemon, ipAddr: string) =
  #[if not daemon.config.lucem.notifyServerRegion:
    return]#

  debug "lucem: server IP is: " & ipAddr

  if (let ipinfo = getIpInfo(ipAddr); *ipinfo):
    let data = &ipinfo
    notify(
      "Server Location",
      "This server is located in $1, $2, $3" % [data.city, data.region, data.country],
      10000,
    )
  else:
    warn "lucem: failed to get server location data!"
    notify("Server Location", "Failed to fetch server location data.", 10000)

proc loop*(daemon: var Daemon) =
  info "lucemd: entering loop"
  while not daemon.shouldQuit:
    sleep(250)
    daemon.reactor.tick()
    for message in daemon.reactor.messages:
      let opacket = message.getPacket()
      if not *opacket:
        warn "lucemd: got bogus data, ignoring."
        continue

      let packet = &opacket
      case packet.magic
      of mgOnGameJoin:
        let data = packet.arguments[0].getDecodedString()
        daemon.onGameJoined(data)
      of mgOnServerIp:
        let data = packet.arguments[0].getDecodedString()
        daemon.onServerIPRevealed(data)

proc initDaemon*(input: Input, config: Config) =
  info "lucemd: initializing daemon..."
  let
    port =
      if (let opt = input.flag("port"); *opt):
        parseUint(&opt)
      else:
        config.daemon.port

  info "lucemd: initializing reactor at port " & $port
  var daemon: Daemon
  daemon.reactor = newReactor("localhost", int port)
  daemon.loop()

proc main =
  addHandler(newColoredLogger())

  info "lucemd@" & Version & " starting up!"
  let input = parseInput()
  
  if input.enabled("verbose"):
    setLogFilter(lvlAll)
  else:
    setLogFilter(lvlInfo)

  let config = parseConfig(input)
  initDaemon(input, config)

when isMainModule:
  main()

import std/[os, logging, strutils]
import toml_serialization
import ./[argparser, sugar]

type
  APKConfig* = object
    version*: string

  LucemConfig* = object
    discord_rpc*: bool
    notify_server_region*: bool

  ClientConfig* = object
    fps*: int = 60
    launcher*: string = ""
    telemetry*: bool
    fflags*: string

  Tweaks* = object
    oldOof*: bool = false
    font*: string = ""

  Config* = object
    apk*: APKConfig
    lucem*: LucemConfig
    tweaks*: Tweaks
    client*: ClientConfig

const
  DefaultConfig* =
    """
[apk]
version = "2.639.688"

[lucem]
discord_rpc = true
notify_server_region = true

[tweaks]
oldOof = false
font = ""

[client]
fps = 60
fflags = """ &
    "\"\"\"\"\"\""

  ConfigLocation* {.strdefine: "LucemConfigLocation".} = "$1/.config/lucem/"

proc parseConfig*(input: Input): Config {.inline.} =
  discard existsOrCreateDir(ConfigLocation % [getHomeDir()])

  let
    inputFile = input.flag("config-file")
    config = readFile(
      if *inputFile:
        &inputFile
      elif fileExists(ConfigLocation % [getHomeDir()] / "config.toml"):
        ConfigLocation % [getHomeDir()] / "config.toml"
      else:
        warn "lucem: cannot find config file, defaulting to built-in config file."
        writeFile(ConfigLocation % [getHomeDir()] / "config.toml", DefaultConfig)
        ConfigLocation % [getHomeDir()] / "config.toml"
    )

  Toml.decode(config, Config)

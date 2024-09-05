import std/[os, logging, strutils]
import toml_serialization
import ./[argparser, sugar]

type
  APKConfig* = object
    version*: string = ""

  LucemConfig* = object
    discord_rpc*: bool = true
    notify_server_region*: bool = true
    loading_screen*: bool = true

  ClientConfig* = object
    fps*: int = 60
    launcher*: string = ""
    telemetry*: bool = false
    fflags*: string

  Tweaks* = object
    oldOof*: bool = false
    moon*: string = ""
    sun*: string = ""
    font*: string = ""

  Config* = object
    apk*: APKConfig
    lucem*: LucemConfig
    tweaks*: Tweaks
    client*: ClientConfig

const
  DefaultConfig* =
    """
[lucem]
discord_rpc = true
loading_screen = true
notify_server_region = true

[tweaks]
oldOof = false
font = ""
moon = ""
sun = ""

[client]
fps = 60
fflags = """ &
    "\"\"\"\"\"\""

  ConfigLocation* {.strdefine: "LucemConfigLocation".} = "$1/.config/lucem/"

proc save*(config: Config) {.inline.} =
  writeFile(ConfigLocation % [getHomeDir()] / "config.toml", Toml.encode(config))

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

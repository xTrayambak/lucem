import std/[os, logging, strutils]
import toml_serialization
import ./[argparser, sugar]

type WindowingBackend* {.pure.} = enum
  X11
  Wayland

func `$`*(backend: WindowingBackend): string {.inline.} =
  case backend
  of WindowingBackend.Wayland: "Wayland"
  of WindowingBackend.X11: "X11"

proc autodetectWindowingBackend*(): WindowingBackend {.inline.} =
  case getEnv("XDG_SESSION_TYPE")
  of "wayland":
    return WindowingBackend.Wayland
  of "x11":
    return WindowingBackend.X11
  else:
    warn "lucem: XDG_SESSION_TYPE was set to \"" & getEnv("XDG_SESSION_TYPE") &
      "\"; defaulting to X11"
    return WindowingBackend.X11

type
  Renderer* {.pure.} = enum
    Vulkan
    OpenGL

  APKConfig* = object
    version*: string = ""

  LucemConfig* = object
    discord_rpc*: bool = false
    notify_server_region*: bool = true
    loading_screen*: bool = true
    polling_delay*: uint = 100

  ClientConfig* = object
    fps*: int = 60
    launcher*: string = ""
    renderer*: Renderer = Renderer.Vulkan
    backend: string
    telemetry*: bool = false
    fflags*: string
    apkUpdates*: bool = true

  Tweaks* = object
    oldOof*: bool = false
    moon*: string = ""
    sun*: string = ""
    font*: string = ""
    excludeFonts*: seq[string] = @["RobloxEmoji.ttf", "TwemojiMozilla.ttf"]
  
  DaemonConfig* = object
    port*: uint = 9898

  OverlayConfig* = object
    width*: uint = 600
    height*: uint = 200
    headingSize*: float = 32f
    descriptionSize*: float = 18f
    font*: string = ""
    anchors*: string = "top-right"

  Config* = object
    apk*: APKConfig
    lucem*: LucemConfig
    tweaks*: Tweaks
    client*: ClientConfig
    overlay*: OverlayConfig
    daemon*: DaemonConfig

proc backend*(config: Config): WindowingBackend =
  if config.client.backend.len < 1:
    debug "lucem: backend name was not set, defaulting to autodetection"
    return autodetectWindowingBackend()

  case config.client.backend.toLowerAscii()
  of "wayland", "wl", "waeland":
    return WindowingBackend.Wayland
  of "x11", "xorg", "bloat", "garbage":
    return WindowingBackend.X11
  else:
    warn "lucem: invalid backend name \"" & config.client.backend &
      "\"; using autodetection"
    return autodetectWindowingBackend()

const
  DefaultConfig* =
    """
[lucem]
discord_rpc = true
notify_server_region = true
loading_screen = true
polling_delay = 0

[tweaks]
oldOof = true
moon = ""
sun = ""
font = ""
excludeFonts = ["RobloxEmoji.ttf", "TwemojiMozilla.ttf"]

[daemon]
port = 9898

[overlay]
width = 600
height = 200
headingSize = 32
descriptionSize = 18
anchors = "top-right"

[client]
fps = 9999
launcher = ""
telemetry = false
fflags = "\n"
apkUpdates = true
"""

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

  try:
    Toml.decode(config, Config)
  except TomlFieldReadingError as exc:
    warn "lucem: unable to read configuration: " & exc.msg
    warn "lucem: falling back to internal default configuration: your changes will NOT be respected!"
    Toml.decode(DefaultConfig, Config)

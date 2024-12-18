## Sober configuration manager
## literally 1984
import std/[os, logging, json, tables]
import pkg/jsony
import ./common

type
  SoberFFlags* = Table[string, JsonNode]

  SoberConfig* = object
    fflags*: SoberFFlags
    bring_back_oof*: bool = false
    discord_rpc_enabled*: bool = true
    touch_mode*: string = "off"
    use_opengl*: bool = false

proc getSoberConfigPath*: string {.inline.} =
  getHomeDir() / ".var" / "app" / SOBER_APP_ID / "config" / "sober" / "config.json"

proc getSoberConfig*: SoberConfig =
  let path = getSoberConfigPath()
  debug "lucem: getting sober config file at: " & path

  try:
    return fromJson(readFile(path), SoberConfig)
  except jsony.JsonError as exc:
    warn "lucem: cannot read sober config file: " & exc.msg

proc saveSoberConfig*(config: SoberConfig) {.inline.} =
  writeFile(
    getSoberConfigPath(), toJson config
  )

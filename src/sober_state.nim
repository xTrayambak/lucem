## Manage Sober's state
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging]
import ./[common, argparser, config]
import jsony

type
  StateV1* = object
    app_version*: string = "2.642.635"
    bring_back_oof*: bool = false
    brought_back_oof*: bool = false
    enable_discord_rpc*: bool = false
    fixed_assets*: bool = false
    fullscreen*: bool = true

  StateV2* = object
    has_seen_onboarding*: bool = false
    r1_enabled*: bool = false

  SoberState* = object
    v1*: StateV1 = default(StateV1)
    v2*: StateV2 = default(StateV2)

func getSoberStatePath*(): string {.inline.} =
  getHomeDir() / ".var" / "app" / SOBER_APP_ID / "data" / "sober" / "state"

proc loadSoberState*(): SoberState =
  ## Load Sober's state JSON file.
  ## This function is guaranteed to succeed.
  debug "lucem: loading sober's internal state"
  if not fileExists(getSoberStatePath()):
    error "lucem: sober has not been launched before as the internal state file could not be found!"
    error "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)

  template deserializationFailure() =
    warn "lucem: failed to deserialize sober's internal state: " & exc.msg
    warn "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)

  template readFailure() =
    warn "lucem: failed to read sober's internal state: " & exc.msg
    warn "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)

  template unknownFailure() =
    warn "lucem: an unknown error occured during reading sober's internal state: " &
      exc.msg
    warn "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)

  try:
    return fromJson(readFile(getSoberStatePath()), SoberState)
  except JsonError as exc:
    deserializationFailure
  except OSError as exc:
    readFailure
  except IOError as exc:
    readFailure
  except ValueError as exc:
    deserializationFailure
  except CatchableError as exc:
    unknownFailure

proc patchSoberState*(input: Input, config: Config) =
  var state = loadSoberState()

  if not input.enabled("use-sober-rpc", "S"):
    debug "lucem: disabling sober's builtin RPC module"
    state.v1.enableDiscordRpc = false
  else:
    warn "lucem: you have explicitly stated that you wish to use Sober's Discord RPC feature."
    warn "lucem: do not report any RPC bugs that arise from this to us, report them to the VinegarHQ team instead."
    state.v1.enableDiscordRpc = true

  if not input.enabled("use-sober-patching", "P"):
    debug "lucem: disabling sober's builtin patching"
    state.v1.bringBackOof = false
    state.v1.broughtBackOof = false
  else:
    warn "lucem: you have explicitly stated that you wish to use Sober's oof sound patcher."
    warn "lucem: we already provide this feature, but if you choose to use Sober's patcher, do not report any bugs that arise from this to us."

  state.v2.r1_enabled = config.client.apkUpdates
  if state.v2.r1_enabled:
    debug "lucem: enabling apk updates"
  else:
    debug "lucem: disabling apk updates"

  writeFile(getSoberStatePath(), toJson(state))

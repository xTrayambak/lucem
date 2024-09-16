## Manage Sober's state
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging]
import ./[common, argparser]
import jsony

type
  StateV1* = object
    appVersion*: string = "2.642.635"
    bringBackOof*: bool = false
    broughtBackOof*: bool = false
    enableDiscordRpc*: bool = false
    fixedAssets*: bool = false
    fullscreen*: bool = true

  StateV2* = object
    hasSeenOnboarding*: bool = false
    r1Enabled*: bool = false

  SoberState* = object
    v1*: StateV1 = default(StateV1)
    v2*: StateV2 = default(StateV2)

func getSoberStatePath*: string {.inline.} =
  getHomeDir() / ".var" / "app" / SOBER_APP_ID / "data" / "sober" / "state"

proc loadSoberState*: SoberState {.raises: [].} =
  ## Load Sober's state JSON file.
  ## This function is guaranteed to succeed.
  debug "lucem: loading sober's internal state"
  if not fileExists(getSoberStatePath()):
    error "lucem: sober has not been launched before as the internal state file could not be found!"
    error "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)

  template deserializationFailure =
    warn "lucem: failed to deserialize sober's internal state: " & exc.msg
    warn "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)

  template readFailure =
    warn "lucem: failed to read sober's internal state: " & exc.msg
    warn "lucem: falling back to lucem's preferred configuration"
    return default(SoberState)
  
  try:
    return fromJson(readFile(getSoberStatePath()), SoberState)
  except JsonError as exc: deserializationFailure
  except OSError as exc: readFailure
  except IOError as exc: readFailure
  except ValueError as exc: deserializationFailure

proc patchSoberState*(input: Input): SoberState =
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
## ipinfo.io wrapper
## Copyright (C) 2024 Trayambak Rai
import std/[logging]
import ../[cache_calls, sugar, http]
import jsony

type
  IPInfoResponse* = ref object
    ip*: string
    city*: string
    country*: string
    region*: string
    loc*: string
    org*: string
    postal*: string
    timezone*: string
    readme*: string

proc getIPInfo*(ip: string): Option[IPInfoResponse] {.inline.} =
  if (let cached = findCacheSingleParam[IPInfoResponse]("ipinfo.getIPInfo", ip, 8765'u64); *cached):
    return cached
    
  try:
    info "ipinfo: fetching IP data for " & ip
    let body = httpGet("https://ipinfo.io/" & ip & "/json")
    debug "ipinfo: response length: " & $body.len & "; parsing JSON"
    debug body

    let payload = fromJson(body, IPInfoResponse)
    cacheSingleParam("ipinfo.getIPInfo", ip, payload)

    return some(payload)
  except JsonError as exc:
    error "ipinfo: failed to parse JSON: " & exc.msg
  except CatchableError as exc:
    error "ipinfo: caught an exception: " & exc.msg

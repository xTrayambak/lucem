## ipinfo.io wrapper
## Copyright (C) 2024 Trayambak Rai
import std/[logging, httpclient]
import ../sugar
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
  try:
    info "ipinfo: fetching IP data for " & ip
    let resp = newHttpClient(userAgent = "curl/8.8.0").get("https://ipinfo.io/" & ip & "/json")
    debug "ipinfo: response length: " & $resp.body.len & "; parsing JSON"
    debug resp.body

    return some(
      fromJson(resp.body, IPInfoResponse)
    )
  except JsonError as exc:
    error "ipinfo: failed to parse JSON: " & exc.msg
  except CatchableError as exc:
    error "ipinfo: caught an exception: " & exc.msg

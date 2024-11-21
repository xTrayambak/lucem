## Shared protocol between lucem client and daemon
## Copyright (C) 2024 Trayambak Rai
import std/[json, options, logging, base64]
import pkg/[jsony, netty]
# import pkg/simdutf/base64

type
  Magic* = enum
    mgOnGameJoin
    mgOnServerIp

  Packet* = object
    magic*: Magic
    arguments*: seq[JsonNode]

proc getDecodedString*(node: JsonNode): string {.inline.} =
  node
    .getStr()
    .decode()

proc getPacket*(message: Message): Option[Packet] =
  try:
    return some(
      fromJson(message.data, Packet)
    )
  except JsonParsingError as exc:
    warn "proto: unable to reinterpret JSON as packet: " & exc.msg
    warn "proto: buffer is as follows:"
    echo message.data

proc serialize*(packet: Packet): string =
  var pckt: Packet
  pckt.magic = packet.magic
  for arg in packet.arguments:
    pckt.arguments &= (
      case arg.kind
      of JString:
        newJString(encode(arg.getStr()))
      else: arg
    )

  pckt.toJson

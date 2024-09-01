## FFlag "parser"
## Copyright (C) 2024 Trayambak Rai
import std/[json, logging, strutils]
import ./config

type
  FFlagParseError* = object of ValueError

proc parseFFlags*(config: Config, fflags: JsonNode) =
  if config.client.fflags.len > 0:
    for flag in config.client.fflags.split('\n'):
      let splitted = flag.split('=')

      if splitted.len < 2:
        if flag.len > 0:
          error "lucem: error whilst parsing FFlag (" & flag &
            "): only got key, no value to complete the pair was found."
          raise newException(FFlagParseError, "Error whilst parsing FFlag (" & flag & "). Only got key, no value to complete the pair was found.")
        else:
          continue

      if splitted.len > 2:
        error "lucem: error whilst parsing FFlag (" & flag &
          "): got more than two splits, key and value were already found."
        raise newException(FFlagParseError, "Error whilst parsing FFlag (" & flag & "). Got more than two splits, key and value were already found!")

      let
        key = splitted[0]
        val = splitted[1]

      if val.startsWith('"') and val.endsWith('"'):
        fflags[key] = newJString(val)
      elif val in ["true", "false"]:
        fflags[key] = newJBool(parseBool(val))
      else:
        var allInt = false

        for c in val:
          if c in {'0' .. '9'}:
            allInt = true
          else:
            allInt = false
            break

        if allInt:
          fflags[key] = newJInt(parseInt(val))
        else:
          warn "lucem: cannot handle FFlag (key=$1, val=$2); ignoring." % [key, val]
          raise newException(FFlagParseError, "Cannot handle FFlag pair of key (" & key & ") and value (" & val & ')')

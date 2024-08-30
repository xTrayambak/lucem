## Cache API calls so that we don't look stupid
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging, json, times]
import ./[sugar, meta]
import jsony

type
  CacheStruct* = object
    version*: string
    createdAt*: float64

    payload*: string

proc createCacheDir {.inline.} =
  debug "cache_calls: creating cache directory"
  discard existsOrCreateDir(getCacheDir() / "lucem")

proc clearCache* =
  debug "cache_calls: clearing cache"

  for file in walkDirRec(getCacheDir() / "lucem"):
    if fileExists(file):
      debug "cache_calls: remove file: " & file
      removeFile(file)
    elif dirExists(file):
      debug "cache_calls: remove directory: " & file
      removeDir(file)

proc cacheSingleParam*[T](call: string, parameter: string, obj: T) =
  createCacheDir()

  let 
    path = getCacheDir() / "lucem" / call & ".json"
    serialized = toJson obj

  var entries = 
    if not fileExists(path):
      debug "cache_calls: first call in entry \"" & call & '"'
      newJObject()
    else:
      fromJson(readFile(path))

  debug "cache_calls: caching for param \"" & parameter & '"'
  debug "cache_calls: payload: " & serialized

  entries[parameter] = %* CacheStruct(version: Version, createdAt: epochTime(), payload: serialized)

  writeFile(path, $(%* entries))

proc findCacheSingleParam*[T](call: string, parameter: string, expectsFreshness: uint64): Option[T] =
  debug "cache_calls: finding cached data for param \"" & parameter & '"'
  createCacheDir()

  let path = getCacheDir() / "lucem" / call & ".json"
  if not fileExists(path):
    debug "cache_calls: cache file not found: " & path
    return
  
  try:
    debug "cache_calls: deserializing cache struct: " & path
    let
      ctime = epochTime()
      index = fromJson(readFile(path))
    
    if not index.contains(parameter):
      debug "cache_calls: cache struct MISSED!"
      return

    let struct = index[parameter].to(CacheStruct)
    if (ctime - struct.createdAt) > float64(expectsFreshness * 60 * 60):
      let diff = ctime - struct.createdAt
      debug "cache_calls: cache struct MISSED due to age! (" & $diff & " seconds older than threshold): " & path
    else:
      debug "cache_calls: cache struct HIT! " & path
      
      try:
        debug "cache_calls: decoding cache struct inner payload: " & struct.payload
        return fromJson(struct.payload, T).some()
      except jsony.JsonError as exc:
        error "cache_calls: error whilst decoding cache struct's inner payload: " & path
        error "cache_calls: " & struct.payload & " (" & exc.msg & ')'
  except jsony.JsonError as exc:
    error "cache_calls: error whilst decoding cache struct: " & path
    error "cache_calls: " & readFile(path) & "\n (" & exc.msg & ')'
    return

## File utilities
## Copyright (C) 2024 Trayambak Rai
import std/[os]

proc isAccessible*(file: string): bool =
  if not fileExists(file):
    return false

  let perms = getFilePermissions(file)

  if fpGroupRead notin perms and fpUserRead notin perms:
    return false

  try:
    discard readFile(file)
  except CatchableError:
    return false

  return true

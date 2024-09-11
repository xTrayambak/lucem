## Determines where the Sober log file has to be stored.
## Copyright (C) 2024 Trayambak Rai
import std/[os]

proc getSoberLogPath*: string {.inline.} =
  let tmp = getEnv("XDG_RUNTIME_DIR", "/tmp")

  if not dirExists(tmp / "lucem"):
    createDir(tmp / "lucem")

  tmp / "lucem" / "sober.log"

## Determines where the Sober log file has to be stored.
## Copyright (C) 2024 Trayambak Rai
import std/[os]

proc getLucemDir*: string {.inline.} =
  let tmp = getEnv("XDG_RUNTIME_DIR", "/tmp")

  if not dirExists(tmp / "lucem"):
    createDir(tmp / "lucem")

  tmp / "lucem"

proc getSoberLogPath*: string {.inline.} =
  getLucemDir() / "sober.log"

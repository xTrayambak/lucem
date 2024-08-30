## Edit the Lucem configuration file
## Copyright (C) 2024 Trayambak Rai
import std/[os, logging, osproc]

proc editConfiguration*(editor: string, quitOnSuccess: bool = true) =
  if execCmd(editor & ' ' & getConfigDir() / "lucem" / "config.toml") != 0:
    error "lucem: the editor (" & editor & ") exited with an unsuccessful exit code."
    quit(1)
  else:
    if quitOnSuccess:
      quit(0)

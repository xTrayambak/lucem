## Worker types
## In Lucem, the worker is just a separate thread that does all blocking tasks to
## ensure that the GTK4 rendering thread does not get blocked.
##
## Copyright (C) 2025 Trayambak Rai (xtrayambak@disroot.org)

type
  Comm* = ref Channel[WorkerOp]

  WorkerOp* {.pure, size: sizeof(uint8).} = enum
    FetchPatchIndex
    Exit

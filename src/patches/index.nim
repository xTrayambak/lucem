## Patch index types
##
## Copyright (C) 2025 Trayambak Rai (xtrayambak@disroot.org)

const PatchIndexUrl* {.strdefine: "LucemPatchIndexUrl".} =
  "https://raw.githubusercontent.com/equinoxhq/patch-store/refs/heads/master/index.json"

type
  PatchEntry* = object
    title*: string
    url*: string

  PatchIndex* = seq[PatchEntry]

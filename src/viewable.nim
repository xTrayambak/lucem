import pkg/owlkettle
import worker/launcher, config
import patches/index

type SettingsState* {.pure.} = enum
  General
  Patches

viewable SettingsMenu:
  collapsed:
    bool = true

  worker:
    LaunchedWorker

  patches:
    index.PatchIndex

  state:
    SettingsState
  selected:
    int

  config:
    Config

export SettingsMenu, SettingsMenuState

import pkg/owlkettle, pkg/owlkettle/adw, pkg/[chronicles, pretty]
import bindings/libadwaita
import meta, viewable

logScope:
  topics = "patch store"

proc openPatchStore*(app: SettingsMenuState) =
  debug "Opening patch store"
  print app.patches

  discard app.open:
    gui:
      Window:
        title = "Patch Store"
        defaultSize = (500, 700)
        AdwSpinner()

        HeaderBar {.addTitlebar.}:
          style = [HeaderBarFlat]

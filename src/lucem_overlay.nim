import std/[logging, strutils, importutils]
import ./[argparser, sugar]
import pkg/[siwin, opengl, nanovg, colored_logger, vmath]
import pkg/siwin/platforms/wayland/[window, windowOpengl]

privateAccess(WindowWaylandOpengl)
privateAccess(WindowWaylandObj)
privateAccess(WindowWayland)
privateAccess(Window)

type
  Overlay* = object
    heading*: string
    description*: string
    expireTime*: float
    icon*: Option[string]
    closed*: bool

    vg*: NVGContext
    wl*: WindowWaylandOpengl
    size*: IVec2 = ivec2(600, 200)

proc draw*(overlay: var Overlay) =
  debug "overlay: redrawing surface"
  glClearColor(255, 255, 255, 255)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  overlay.vg.roundedRect(0, 0, overlay.size.x.cfloat, overlay.size.y.cfloat, 16f)
  overlay.vg.fillColor(rgba(0.1, 0.1, 0.1, 0.5))

proc initOverlay*(input: Input) {.noReturn.} =
  var overlay: Overlay
  for opt in [
      "heading",
      "description",
      "expire-time"
  ]:
    if (let maybeOpt = input.flag(opt); *maybeOpt):
      case opt
      of "heading": overlay.heading = &maybeOpt
      of "description": overlay.description = &maybeOpt
      of "expire-time": overlay.expireTime = parseFloat(&maybeOpt)
    else:
      error "overlay: expected flag: " & opt
      quit(1)

  if (let oIcon = input.flag("icon"); *oIcon):
    overlay.icon = oIcon

  debug "overlay: creating surface"
  overlay.wl = newOpenglWindowWayland(
    kind = WindowWaylandKind.LayerSurface,
    layer = Layer.Overlay,
    size = overlay.size,
    namespace = "lucem"
  )
  overlay.wl.setKeyboardInteractivity(LayerInteractivityMode.None)
  overlay.wl.setAnchor(@[LayerEdge.Right, LayerEdge.Top])
  overlay.wl.setExclusiveZone(1)

  #[debug "overlay: loading OpenGL"
  loadExtensions()

  debug "overlay: creating NanoVG instance"
  nvgInit(glGetProc)
  overlay.vg = nvgCreateContext({
    nifAntialias
  })
  
  overlay.wl.firstStep(makeVisible = true)
  while not overlay.closed:
    overlay.wl.step()

    if overlay.wl.redrawRequested:
      overlay.draw()]#

  quit(0)

proc main =
  addHandler(newColoredLogger())
  let input = parseInput()

  initOverlay(input)

when isMainModule: main()

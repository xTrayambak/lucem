## Lucem Overlay
## Copyright (C) 2024 Trayambak Rai

import std/[os, logging, strutils, importutils, base64, times]
import ./[argparser, sugar, config, internal_fonts]
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
    config*: Config

    vg*: NVGContext
    wl*: WindowWaylandOpengl
    size*: IVec2 = ivec2(600, 200)

    lastEpoch*: float
    timeSpent*: float

    headingFont*: Font

proc draw*(overlay: var Overlay) =
  debug "overlay: redrawing surface"
  glViewport(0, 0, overlay.size.x, overlay.size.y)
  glClearColor(0, 0, 0, 0)
  glClear(GL_COLOR_BUFFER_BIT or
    GL_DEPTH_BUFFER_BIT or
    GL_STENCIL_BUFFER_BIT)

  overlay.vg.beginFrame(overlay.size.x.cfloat, overlay.size.y.cfloat, 1f) # TODO: fractional scaling support
  overlay.vg.roundedRect(0, 0, overlay.size.x.cfloat - 16f, overlay.size.y.cfloat, 16f)
  overlay.vg.fillColor(rgba(0.3, 0.3, 0.3, 0.8))
  overlay.vg.fill()
  
  overlay.vg.fontFace("heading")
  overlay.vg.textAlign(haLeft, vaTop)
  overlay.vg.fontSize(overlay.config.overlay.headingSize)
  overlay.vg.fillColor(white(255))
  discard overlay.vg.text(16f, 16f, overlay.heading)
  
  overlay.vg.fontFace("heading")
  overlay.vg.textAlign(haLeft, vaTop)
  overlay.vg.fontSize(overlay.config.overlay.descriptionSize)
  overlay.vg.fillColor(white(255))
  discard overlay.vg.text(16f, 64f, overlay.description)

  # TODO: icon rendering, even though we don't use them yet
  # but it'd be useful for the future

  overlay.vg.endFrame()

proc initOverlay*(input: Input) {.noReturn.} =
  var overlay: Overlay
  for opt in [
      "heading",
      "description",
      "expire-time"
  ]:
    if (let maybeOpt = input.flag(opt); *maybeOpt):
      case opt
      of "heading": overlay.heading = decode(&maybeOpt)
      of "description": overlay.description = decode(&maybeOpt)
      of "expire-time": overlay.expireTime = parseFloat(&maybeOpt)
    else:
      error "overlay: expected flag: " & opt
      quit(1)

  if (let oIcon = input.flag("icon"); *oIcon):
    overlay.icon = oIcon
  
  debug "overlay: got all arguments, parsing config"
  var config = parseConfig(input)

  debug "overlay: creating surface"
  overlay.size = ivec2(config.overlay.width.int32, config.overlay.height.int32)
  overlay.wl = newOpenglWindowWayland(
    kind = WindowWaylandKind.LayerSurface,
    layer = Layer.Overlay,
    size = overlay.size,
    namespace = "lucem"
  )
  overlay.wl.setKeyboardInteractivity(LayerInteractivityMode.None)
  var anchors: seq[LayerEdge]
  for value in config.overlay.anchors.split('-'):
    debug "overlay: got anchor: " & value
    case value.toLowerAscii()
    of "left", "l": anchors &= LayerEdge.Left
    of "right", "r": anchors &= LayerEdge.Right
    of "top", "up", "u": anchors &= LayerEdge.Top
    of "bottom", "down", "d": anchors &= LayerEdge.Bottom
    else:
      warn "overlay: unhandled anchor: " & value

  overlay.wl.setAnchor(anchors)
  overlay.wl.setExclusiveZone(10000)

  overlay.config = move(config)

  debug "overlay: loading OpenGL"
  loadExtensions()

  debug "overlay: creating NanoVG instance"
  nvgInit(glGetProc)
  overlay.vg = nvgCreateContext({
    nifAntialias
  })
  var data = 
    if (config.overlay.font.len > 0 and fileExists(config.overlay.font)):
      cast[seq[byte]](readFile(config.overlay.font))
    else:
      cast[seq[byte]](IbmPlexSans)

  overlay.headingFont = overlay.vg.createFontMem(
    "heading",
    data
  )
  overlay.lastEpoch = epochTime()
  overlay.timeSpent = 0f

  overlay.wl.eventsHandler.onRender = proc(event: RenderEvent) =
    overlay.draw()

  overlay.wl.eventsHandler.onTick = proc(event: TickEvent) =
    let epoch = epochTime()
    let elapsed = epoch - overlay.lastEpoch

    overlay.timeSpent += elapsed
    overlay.lastEpoch = epoch

    debug "overlay: " & $overlay.timeSpent & "s / " & $overlay.expireTime & 's'

    if overlay.timeSpent >= overlay.expireTime:
      info "overlay: Completed lifetime. Closing!"
      overlay.wl.close()

  overlay.wl.run()
  quit(0)

proc main =
  addHandler(newColoredLogger())
  let input = parseInput()

  initOverlay(input)

when isMainModule: main()

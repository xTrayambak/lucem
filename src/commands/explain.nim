## Provide docs for the TOML configuration
## Copyright (C) 2024 Trayambak Rai
import std/[logging, strutils, terminal]
import ../argparser

type
  QuestionKind* = enum
    Command
    RuntimeFlag
    Configuration

  Question* = object
    case kind*: QuestionKind
    of Command:
      command*: string
    of RuntimeFlag:
      flag*: string
    of Configuration:
      category*: string
      name*: string

proc explainCommand*(question: Question) =
  assert question.kind == Command
  case question.command
  of "run":
    stdout.styledWriteLine(
      repeat(' ', int(terminalWidth() / 2)), "lucem ", fgGreen, "run", resetStyle
    )
    stdout.styledWriteLine(styleBright, "NAME", resetStyle)
    stdout.write("\trun - run the Roblox client\n\n")
    stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
    stdout.styledWriteLine(
      "\tThis command runs the Roblox client alongside Lucem's event watcher thread."
    )
  else:
    error "lucem: no documentation exists for command \"" & question.command & '"'
    quit(1)

proc explainConfig*(question: Question) =
  assert question.kind == Configuration
  template noDocs() {.dirty.} =
    error "lucem: no documentation exists for " & question.category & ':' & question.name
    quit(1)

  case question.category
  of "apk":
    stdout.styledWriteLine(
      styleBright, "NOTICE", resetStyle, ": ", styleUnderscore,
      "this category is now deprecated and serves no purpose.", resetStyle,
    )
    return
  of "lucem":
    case question.name
    of "discord_rpc":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "lucem",
        resetStyle,
        ":",
        fgYellow,
        "discord_rpc",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t", "When set to ", fgBlue, "true", resetStyle,
        ", Lucem will show the Roblox game you're currently playing via Discord's rich presence system.",
      )
    of "notify_server_region":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "lucem",
        resetStyle,
        ":",
        fgYellow,
        "notify_server_region",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t", "When set to ", fgBlue, "true", resetStyle,
        ", Lucem will show you the location of the server you're connected to.",
      )
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "PRIVACY", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "Lucem makes an API call to ipinfo.io, who may or may not store your IP address for telemetry (we can never be sure). Lucem never contacts any other server other than that of ipinfo's when the location is being fetched. Subsequent API calls are omitted if the IP is found in the local cache that Lucem maintains to save on bandwidth.",
      )
    of "loading_screen":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "lucem",
        resetStyle,
        ":",
        fgYellow,
        "loading_screen",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t", "When set to ", fgBlue, "true", resetStyle,
        ", Lucem will show a loading screen when Sober is initializing Roblox.",
      )
      stdout.write '\n'
    of "polling_delay":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "lucem",
        resetStyle,
        ":",
        fgYellow,
        "polling_delay",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "unsigned integer", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "100", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This value dictates how much time Lucem's event watcher thread sleeps for after polling Sober's log file, in seconds. This barely impacts performance even when set to zero, this simply exists to allow people with ",
        styleItalic, "very", resetStyle, " weak CPUs to save on resources.",
      )
    else:
      noDocs
  of "tweaks":
    case question.name
    of "oldoof":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "tweaks",
        resetStyle,
        ":",
        fgYellow,
        "oldOof",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting lets you bring back the old \"Oof!\" sound, which was recently replaced to the \"Eurgh\" sound by Roblox due to copyright issues.",
        "\n\tYou can revert this by setting the value to ", fgGreen, "false",
        resetStyle, ".",
      )
    of "moon":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "tweaks",
        resetStyle,
        ":",
        fgYellow,
        "moon",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "string", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "Not set by default.", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting lets you override Roblox's moon texture, granted that the game you're playing doesn't use a custom one.",
        "\n\tYou can revert the changes by leaving this option empty (or not defining it at all)",
      )
    of "sun":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "tweaks",
        resetStyle,
        ":",
        fgYellow,
        "sun",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "string", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "Not set by default.", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting lets you override Roblox's sun texture, granted that the game you're playing doesn't use a custom one.",
        "\n\tYou can revert the changes by leaving this option empty (or not defining it at all)",
      )
    of "font":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "tweaks",
        resetStyle,
        ":",
        fgYellow,
        "font",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "string", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "Not set by default.", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t", "This setting lets you override all of Roblox's fonts with your own.",
        "\n\tYou can revert the changes by leaving this option empty (or not defining it at all)",
      )
    else:
      noDocs
  of "client":
    case question.name
    of "fps":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "client",
        resetStyle,
        ":",
        fgYellow,
        "fps",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "integer", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "60", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting lets you override all of Roblox's default framerate cap of 60 to anything you want, or disable it altogether.",
      )
    of "launcher":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "client",
        resetStyle,
        ":",
        fgYellow,
        "launcher",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "string", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "Not set by default.", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting lets you run Roblox (Sober) with a particular launcher, like ",
        styleBright, "gamemoderun", resetStyle, ".",
      )
    of "backend":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "client",
        resetStyle,
        ":",
        fgYellow,
        "backend",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "string", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine(
        "\t", fgGreen, "Autodetected by Lucem using the ", resetStyle, styleBright,
        "XDG_SESSION_TYPE", resetStyle, fgGreen, " environment variable.", resetStyle,
      )
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting lets you force Roblox (Sober) to either run with the Wayland windowing backend or the X11 windowing backend.",
        "\n\tIf you leave this empty, Lucem automatically detects which backend would be the best for you.",
        "\n\tValid options are:\n", fgRed, "\t-", resetStyle, styleBright, " x11\n",
        resetStyle, fgRed, "\t-", resetStyle, styleBright, " wayland\n", resetStyle,
      )
    of "telemetry":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "client",
        resetStyle,
        ":",
        fgYellow,
        "telemetry",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "false", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This setting attempts to disable most of the telemetry FFlags that the Roblox client exposes. It does not guarantee to make your Roblox experience 100% private, but it is recommended to be set to ",
        fgGreen, "false", resetStyle, " in order to disable these flags.",
      )
    of "fflags":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "client",
        resetStyle,
        ":",
        fgYellow,
        "fflags",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "string of key-value pairs", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "Empty by default.", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This string lets you define FFlags that will be applied to Roblox upon launch. You must use the key-value syntax like this:",
        fgRed, "-", resetStyle, " ", fgGreen, "FFlagName", resetStyle, styleBright, "=",
        resetStyle, fgYellow, "\"my string value\"", resetStyle, fgRed, "-", resetStyle,
        " ", fgGreen, "FFlagName", resetStyle, styleBright, "=", resetStyle, fgGreen,
        "1337", resetStyle, fgRed, "-", resetStyle, " ", fgGreen, "FFlagName",
        resetStyle, styleBright, "=", resetStyle, fgBlue, "false", resetStyle,
        "If you do not understand this, it's best to use the GUI FFlag editor that the Lucem shell provides, as it instantly validates everything and shows you",
        " friendly error messages if you make a mistake.",
      )
    of "apkupdates":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen,
        "client",
        resetStyle,
        ":",
        fgYellow,
        "apkUpdates",
        resetStyle,
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine(
        "\t",
        "This is a shorthand way of modifying Sober's state to check for Roblox APK updates upon startup. It is recommended that you keep this enabled.",
      )
    else:
      noDocs
  else:
    error "lucem: no documentation exists for category \"" & question.category & '"'
    quit(1)

proc explain*(question: Question) {.inline.} =
  case question.kind
  of Configuration:
    explainConfig(question)
  of Command:
    explainCommand(question)
  else:
    discard

proc generateQuestion*(input: Input): Question =
  template showErrorAndDie() =
    stderr.styledWriteLine(
      styleUnderscore, "Usage", resetStyle, ": lucem ", fgGreen, "explain ", resetStyle,
      "<", styleItalic, "kind", resetStyle, "> <", styleItalic, "arguments", resetStyle,
      ">",
    )
    stderr.write '\n'

    stderr.styledWriteLine(
      styleBright, "where ", resetStyle, fgYellow, "kind", resetStyle, styleBright,
      " is", resetStyle, ":",
    )
    stderr.styledWriteLine(fgRed, "* ", resetStyle, styleBright, "command", resetStyle)
    stderr.styledWriteLine(fgRed, "* ", resetStyle, styleBright, "flag", resetStyle)
    stderr.styledWriteLine(fgRed, "* ", resetStyle, styleBright, "config", resetStyle)
    stderr.write '\n'

    stderr.styledWriteLine(
      styleBright, "where ", resetStyle, fgYellow, "arguments", resetStyle, styleBright,
      " can be", resetStyle, ":",
    )
    stderr.styledWriteLine(
      fgRed, "* ", resetStyle, fgGreen, "command", resetStyle, ": ", styleBright,
      "<command name> (the command to explain)",
    )
    stderr.styledWriteLine(
      fgRed, "* ", resetStyle, fgGreen, "flag", resetStyle, ": ", styleBright,
      "<flag name> (the flag to explain)",
    )
    stderr.styledWriteLine(
      fgRed, "* ", resetStyle, fgGreen, "config", resetStyle, ": ", styleBright,
      "<category> <name> (eg, lucem discord_rpc)",
    )
    quit(1)

  if input.arguments.len < 1:
    showErrorAndDie

  let kind =
    case input.arguments[0].toLowerAscii()
    of "command":
      Command
    of "flag":
      RuntimeFlag
    of "config", "configuration":
      Configuration
    else:
      showErrorAndDie
      Command

  var question = Question(kind: kind)

  case kind
  of Command:
    if input.arguments.len < 2:
      showErrorAndDie
    question.command = input.arguments[1].toLowerAscii()
  of RuntimeFlag:
    if input.arguments.len < 2:
      showErrorAndDie
    question.flag = input.arguments[1].toLowerAscii()
  of Configuration:
    if input.arguments.len < 3:
      showErrorAndDie
    question.category = input.arguments[1].toLowerAscii()
    question.name = input.arguments[2].toLowerAscii()

  question

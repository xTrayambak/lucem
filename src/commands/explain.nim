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
      repeat(' ', int(terminalWidth() / 2)),
      "lucem ", fgGreen, "run", resetStyle
    )
    stdout.styledWriteLine(styleBright, "NAME", resetStyle)
    stdout.write("\trun - run the Roblox client\n\n")
    stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
    stdout.styledWriteLine("\tThis command runs the Roblox client alongside Lucem's event watcher thread.")
  else:
    error "lucem: no documentation exists for command \"" & question.command & '"'
    quit(1)

proc explainConfig*(question: Question) =
  assert question.kind == Configuration
  case question.category
  of "apk":
    stdout.styledWriteLine(styleBright, "NOTICE", resetStyle, ": ", styleUnderscore, "this category is now deprecated and serves no purpose.", resetStyle)
    return
  of "lucem":
    case question.name
    of "discord_rpc":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen, "lucem", resetStyle, ":", fgYellow, "discord_rpc", resetStyle
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine("\t", "When set to ", fgBlue, "true", resetStyle, ", Lucem will show the Roblox game you're currently playing via Discord's rich presence system.")
    of "notify_server_region":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen, "lucem", resetStyle, ":", fgYellow, "notify_server_region", resetStyle
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine("\t", "When set to ", fgBlue, "true", resetStyle, ", Lucem will show you the location of the server you're connected to.")
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "PRIVACY", resetStyle)
      stdout.styledWriteLine("\t", "Lucem makes an API call to ipinfo.io, who may or may not store your IP address for telemetry (we can never be sure). Lucem never contacts any other server other than that of ipinfo's when the location is being fetched. Subsequent API calls are omitted if the IP is found in the local cache that Lucem maintains to save on bandwidth.")
    of "loading_screen":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen, "lucem", resetStyle, ":", fgYellow, "loading_screen", resetStyle
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgBlue, "true", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine("\t", "When set to ", fgBlue, "true", resetStyle, ", Lucem will show a loading screen when Sober is initializing Roblox.")
      stdout.write '\n'
    of "polling_delay":
      stdout.styledWriteLine(
        repeat(' ', int(terminalWidth() / 2)),
        fgGreen, "lucem", resetStyle, ":", fgYellow, "polling_delay", resetStyle
      )

      stdout.styledWriteLine(styleBright, "TYPE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "boolean", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DEFAULT VALUE", resetStyle)
      stdout.styledWriteLine("\t", fgGreen, "0", resetStyle)
      stdout.write '\n'

      stdout.styledWriteLine(styleBright, "DESCRIPTION", resetStyle)
      stdout.styledWriteLine("\t", "This value dictates how much time Lucem's event watcher thread sleeps for after polling Sober's log file, in seconds. This barely impacts performance even when set to zero, this simply exists to allow people with ", styleItalic, "very", resetStyle, " weak CPUs to save on resources.")
    else:
      error "lucem: no documentation exists for " & question.category & ':' & question.name
      quit(1)
  else:
    error "lucem: no documentation exists for category \"" & question.category & '"'
    quit(1)

proc explain*(question: Question) {.inline.} =
  case question.kind
  of Configuration:
    explainConfig(question)
  of Command:
    explainCommand(question)
  else: discard

proc generateQuestion*(input: Input): Question =
  template showErrorAndDie =
    stderr.styledWriteLine(styleUnderscore, "Usage", resetStyle, ": lucem ", fgGreen, "explain ", resetStyle, "<", styleItalic, "kind", resetStyle, "> <", styleItalic, "arguments", resetStyle, ">")
    stderr.write '\n'

    stderr.styledWriteLine(styleBright, "where ", resetStyle, fgYellow, "kind", resetStyle, styleBright, " is", resetStyle, ":")
    stderr.styledWriteLine(fgRed, "* ", resetStyle, styleBright, "command", resetStyle)
    stderr.styledWriteLine(fgRed, "* ", resetStyle, styleBright, "flag", resetStyle)
    stderr.styledWriteLine(fgRed, "* ", resetStyle, styleBright, "config", resetStyle)
    stderr.write '\n'

    stderr.styledWriteLine(styleBright, "where ", resetStyle, fgYellow, "arguments", resetStyle, styleBright, " can be", resetStyle, ":")
    stderr.styledWriteLine(fgRed, "* ", resetStyle, fgGreen, "command", resetStyle, ": ", styleBright, "<command name> (the command to explain)")
    stderr.styledWriteLine(fgRed, "* ", resetStyle, fgGreen, "flag", resetStyle, ": ", styleBright, "<flag name> (the flag to explain)")
    stderr.styledWriteLine(fgRed, "* ", resetStyle, fgGreen, "config", resetStyle, ": ", styleBright, "<category> <name> (eg, lucem discord_rpc)")
    quit(1)

  if input.arguments.len < 1: showErrorAndDie

  let kind = 
    case input.arguments[0].toLowerAscii()
    of "command": Command
    of "flag": RuntimeFlag
    of "config", "configuration": Configuration
    else: showErrorAndDie; Command

  var question = Question(kind: kind)
  
  case kind
  of Command:
    if input.arguments.len < 2: showErrorAndDie
    question.command = input.arguments[1].toLowerAscii()
  of RuntimeFlag:
    if input.arguments.len < 2: showErrorAndDie
    question.flag = input.arguments[1].toLowerAscii()
  of Configuration:
    if input.arguments.len < 3: showErrorAndDie
    question.category = input.arguments[1].toLowerAscii()
    question.name = input.arguments[2].toLowerAscii()

  question

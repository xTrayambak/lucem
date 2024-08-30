## notify-send wrapper
## Copyright (C) 2024 Trayambak Rai
import std/[os, osproc, logging, strutils]
import ./sugar

proc notify*(
  heading: string,
  description: string,
  expireTime: uint64 = 240000,
  icon: Option[string] = none(string)
) =
  debug "notifications: preparing notify-send command"
  debug "notifications: heading = $1, description = $2, expireTime = $3" % [
    heading, description, $expireTime
  ]

  let exe = findExe("notify-send")
  if exe.len < 1:
    warn "notifications: notify-send was not found; ignoring."
    return

  var cmd = exe & ' '
  cmd &= '"' & heading & "\" "
  cmd &= '"' & description & "\" "
  cmd &= "--expire-time=" & $expireTime & ' '
  cmd &= "--app-name=Lucem "

  if *icon:
    debug "notifications: icon was specified: " & &icon
    cmd &= "--icon=" & &icon
  else:
    debug "notifications: icon was not specified."
  
  let code = execCmd(cmd)
  if code == 0:
    debug "notifications: notify-send exited successfully."
  else:
    warn "notifications: notify-send exited with abnormal exit code (" & $code & ')'
    warn "notifications: command was: " & cmd

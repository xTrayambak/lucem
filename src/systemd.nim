## professional lucemd systemd service installer
## Copyright (C) 2024 Trayambak Rai
import std/[os, strutils, logging, osproc]
import ./meta

const
  SystemdServiceTemplate = """
[Unit]
Description=Lucem $1
After=network.target

[Service]
ExecStart=$2
Restart=on-failure

[Install]
WantedBy=default.target
"""

proc installSystemdService* =
  info "lucem: installing systemd service"
  let service = SystemdServiceTemplate % [
    Version, getAppDir() / "lucemd"
  ]
  let servicesDir = getConfigDir() / "systemd" / "user"

  if not dirExists(servicesDir):
    discard existsOrCreateDir(getConfigDir() / "systemd")
    discard existsOrCreateDir(servicesDir)

  writeFile(servicesDir / "lucem.service", service)
  if execCmd(findExe("systemctl") & " enable lucem.service --user --now") != 0:
    error "lucem: failed to install systemd service for daemon!"

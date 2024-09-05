# Package

version = "1.1.1"
author = "xTrayambak"
description = "A small wrapper over Sober that provides quality of life improvements"
license = "GPL-2.0-only"
srcDir = "src"
bin = @["lucem"]

# Dependencies

requires "nim >= 2.0.0"
requires "colored_logger >= 0.1.0"
requires "jsony >= 1.1.5"
requires "toml_serialization >= 0.2.12"
requires "pretty >= 0.1.0"
requires "discord_rpc >= 0.2.0"
requires "owlkettle >= 3.0.0"

task installLucem, "Install Lucem (I love Nimble)":
  exec "nim c --define:release --out:lucem src/lucem.nim"
  exec "sudo mv lucem /usr/bin/"

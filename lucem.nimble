# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "A small wrapper over Sober"
license       = "MIT"
srcDir        = "src"
bin           = @["lucem"]


# Dependencies

requires "nim >= 2.0.8"
requires "colored_logger >= 0.1.0"

requires "jsony >= 1.1.5"
requires "toml_serialization >= 0.2.12"
requires "pretty >= 0.1.0"
requires "regex >= 0.25.0"
requires "discord_rpc >= 0.2.0"
# Package

version = "2.0.0"
author = "xTrayambak"
description = "A small wrapper over Sober that provides quality of life improvements"
license = "MIT"
srcDir = "src"
backend = "cpp"
bin = @["lucem", "lucemd"]

# Dependencies

requires "nim >= 2.0.0"
requires "colored_logger >= 0.1.0"
requires "jsony >= 1.1.5"
requires "toml_serialization >= 0.2.12"
requires "pretty >= 0.1.0"
requires "discord_rpc >= 0.2.0"
requires "owlkettle >= 3.0.0"
requires "nimgl >= 1.3.2"
requires "netty >= 0.2.1"

requires "simdutf >= 5.5.0"

requires "curly >= 1.1.1"
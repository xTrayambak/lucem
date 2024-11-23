# Package

version = "2.0.1"
author = "xTrayambak"
description = "A small wrapper over Sober that provides quality of life improvements"
license = "MIT"
srcDir = "src"
backend = "c"
bin = @["lucem", "lucemd", "lucem_overlay"]

# Dependencies

requires "nim >= 2.0.0"
requires "colored_logger >= 0.1.0"
requires "jsony >= 1.1.5"
requires "toml_serialization >= 0.2.12"
requires "pretty >= 0.1.0"
requires "owlkettle >= 3.0.0"
requires "nimgl >= 1.3.2"
requires "netty >= 0.2.1"
requires "curly >= 1.1.1"
requires "nanovg >= 0.4.0"
requires "siwin#9ce9aa3efa84f55bbf3d29ef0517b2411d08a357"
requires "opengl >= 1.2.9"

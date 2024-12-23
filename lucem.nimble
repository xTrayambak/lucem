# Package

version = "2.0.3"
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

after install:
  exec "$HOME/.nimble/bin/lucem init"

  echo "\e[1mPssst, hey you!\e[0m"
  echo "\e[1;34mYes, you!\e[0m"
  echo "\e[1mThanks for installing Lucem!"
  echo "If you run `lucem` in the terminal and no command is found, try running the command below:\e[0m"
  echo "\e[1:32mexport PATH=\"$HOME/.nimble/bin:$PATH\"\e[0m"

# Lucem 2.1.0 is here!
Yay. \
This changelog contains every feature from 2.0.2 to 2.1.0

## Fixed Bugs
* The Flatpak command that'd install Sober would get stuck on a confirmation (2.0.2)
* `lucemd` no longer causes CPU spikes (2.0.3)
* `lucem_overlay` lets your compositor blur its surface (2.0.3)
* Added support for the new Sober configuration interface (2.0.3)
* Fixed botched symbolic icons in the settings shell (2.0.4)
* Fixed arbitrary daemon sleep time (2.0.4)
* Don't emit `--opengl` flag, use configuration instead (2.0.4)
* Lock FPS to 60 by default, preventing coil whine (2.1.0)

## Additions
* Added autoupdater, this checks for updates every time Lucem is run. (2.1.0)
* You can now update Lucem by running `lucem update`. (2.1.0)
* Added update alert that shows up every time a new release is available. (2.1.0)
* Overhauled Lucem shell to make it nicer to use (2.1.0)
* Added new Lucem icon (2.0.4)

## Installation
Run `nimble install https://github.com/xTrayambak/lucem` in your terminal. Remember, this requires a Nim toolchain with version 2.0 or higher.

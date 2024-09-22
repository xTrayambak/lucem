# Lucem 1.1.2 is here!
Yay.

This release brings the `lucem explain` command to help people who prefer the TOML configuration file to understand what the options do.

# What's Changed?
Lucem now stands at around 2.3K lines of code. This update did a whole lot of housekeeping to make Lucem more maintainable in the future since the original program was very silly and fixed some problems very weirdly.

## Bug Fixes
* Serialization issue, this might've been causing Sober to be rendered unusable until it is force resetted in some very specific scenarios, see issue #8
* We no longer spam `flatpak ps` to check if Sober is running, which'd cause the system to run out of memory if you played for long durations (4-5 hours), depending on how much RAM you have.
* Temporarily disabled the loading screen for everyone as the new Sober update seems to completely break it.

## New Features
* You can now directly force Sober to use either X11 or Wayland with the `client:backend` TOML configuration entry.
* You can now list all compatible GPUs with `lucem list-gpus`.
* Lucem now verifies that you have a GPU that supports Vulkan upon startup. This can be bypassed with the `--dont-check-vulkan` flag.

# Thank you to all of these people :3
* The Sober team for creating Sober (plox open source it so that I can rewrite it in Nim :3)

# Installation
Run `nimble install https://github.com/xTrayambak/lucem` in your terminal. Remember, this requires a Nim toolchain with version 2.0 or higher.

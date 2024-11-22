# Lucem 2.0.0 is here!
Yay.

**NOTICE**: Please run `lucem init` upon installing this release!

This release rewrites a huge part of Lucem by splitting it up into three components - the lucem CLI you all know (and love? hate? I don't know!) to be more modular.

# What's Changed?
Lucem stands at 2.4K lines of code.

## New Features
* Lucem now allows you to change the renderer with the `client:renderer` backend. Correct values for this are `opengl` or `vulkan`.
* Lucem now has an overlay on platforms that support it (KDE, Hyprland, Sway, Cosmic, or basically anything that isn't GNOME)
* Lucem now defaults to using Sober's RPC implementation as it is better. `lucem:discord_rpc` still works as intended.

# Thank you to all of these people :3
* The Sober team for creating Sober (plox open source it so that I can rewrite it in Nim :3)
* AshtakaOof for beta-testing the early rewrite builds

# Installation
Run `nimble install https://github.com/xTrayambak/lucem` in your terminal. Remember, this requires a Nim toolchain with version 2.0 or higher.

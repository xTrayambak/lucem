# Lucem
Lucem is a small wrapper over [Sober](https://sober.vinegarhq.org) to provide some QoL improvements. \
Please keep in mind that while Lucem is fully open source software, Sober is proprietary for a very good reason, that being to preserve RoL from 9-year-old skiddies.

# Disclaimer, in big bold letters.
Lucem only automates downloading the Roblox APK from `apkpure.net`. It does not allow you to bypass the (reasonable and justified) restrictions the Vinegar team has put on Sober's ability to load APKs that are modified.

The previous instance of Roblox on Linux via WINE was banned because skids found out about the lax anticheat on Linux and began developing cheats that targetted RoL. We do *NOT* want to get it banned again.

If you really cheat on Roblox, I'd say you should reconsider your life decisions than anything. \
**Lucem is not associated with the VinegarHQ team or Roblox, nor is it endorsed by them!**

# Features
- Rich presence
- Providing a nifty configuration file (located at `~/.config/lucem/config.toml`)
- (Semi-automatically) downloading and managing the Roblox APK
- Managing Sober

# Installation
Lucem requires a working Nim toolchain which can be installed via [choosenim](https://nim-lang.org/install_unix.html)

Run the following commands to compile Lucem.
```command
# git clone https://github.com/xTrayambak/lucem.git
# cd lucem
# nimble install -d:release
```

# Usage
## Initializing Sober and Roblox
Run this command:

```command
# lucem init
```

You will be guided as to how you can download the latest Roblox APK

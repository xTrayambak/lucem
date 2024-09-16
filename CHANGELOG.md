# Lucem 1.1.1 is here!
Yay.

This was a fairly small release because I had my exams in between. Sorry.

# What's Changed?
Lucem now stands at around 1.6K lines of code. This update did a whole lot of housekeeping to make Lucem more maintainable in the future since the original program was very silly and fixed some problems very weirdly.

## Resource Usage
* Lucem now consumes waaaay less resources when you've been playing for a long time, and it's more conservative with how it uses memory.
* There is now an option to tweak how frequently the event watcher thread is polling the log file to check for new state updates. This shouldn't affect performance for most people, but if your CPU is *really* weak, this might help (Lucem uses 1% of my CPU when there's no delay anyways). 

## Multi-User Support
I highly doubt anyone has a multi-user setup here, but Lucem now redirects all Sober logs to your `XDG_RUNTIME_DIR`, allowing for multiple people to play on the same machine at once with different user accounts. This is generally `/run/user/1000/lucem/sober.log` on systemd-based distributions.

## Sober Update
Lucem is confirmed to be working as intended with the new Sober release. We're automatically disabling the new features like Discord RPC and the old oof sound patch because we have those built in. Unfortunately, due to my exams, I wasn't able to implement BloxstrapRPC in time. Expect that to come very soon with Lucem 1.2 :^)

To prevent Lucem from disabling those features, run it with the `--use-sober-rpc` and `--use-sober-patching` flags.

## Better Documentation
Lucem has fewer unexplainable crashes which'd require you to know how it works under the hood.

# Thank you to all of these people :3
* The VinegarHQ team for creating Sober (plox open source it so that I can rewrite it in Nim :3)
* @reflexran for fixing some compiler warnings

# Installation
Run `nimble install https://github.com/xTrayambak/lucem` in your terminal. Remember, this requires a Nim toolchain with version 2.0 or higher.

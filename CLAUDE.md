# CARNIVAL · anchor

A recipe that runs Road Rash 30th Anniversary Edition (Steam, Windows) on an Apple silicon Mac. One script, one README. Made 19 nov 2026.

## read first

1. [STATE.md](STATE.md)
2. [DECISIONS.md](DECISIONS.md)
3. [README.md](README.md) · the steps and the cause of each fix

## laws

- **Never commit the wrapper,** game files, Steam files or a sign-in. The repo holds text only.
- **The downloads ask first.** One y/n after a list. A new download gets its own row in that list with maker, licence and link.
- **A script never types a password.** The Steam sign-in is the person's, in SteamCMD. SteamCMD runs with its own home in the folder (`steamhome`).
- **Delete only what is ours.** An app needs the bundle id `local.carnival.roadrash`. `remove` deletes a fixed list of names; a new file the flow writes joins that list.
- **Markers keep fingerprints.** `.consent` (the download list), `.tuned` (`prefix` and its helpers), `.sha` (each pin). Change one and old installs run that step again. When a pin changes, delete `adopt`.
- **Never delete under a running game.** Engine and libraries change only through `swap`. Tests use `CARNIVAL_ROOT`, `CARNIVAL_APP` and `HOME` in scratch, and a stub `open`.
- **Each claim says if it is tested.** The README's `tested on` and `limits` tables are the record. Update them with every change.
- **Never kill a process while Nevil plays.** Two stops on 19 nov 2026 closed his sign-in and his game.
- **Public on GitHub since 20 nov 2026 (CW-11).** The repo holds the recipe only, never the game.
- Global laws apply: no em dashes · lowercase headers · facts or an `owed ·` slot · CREDITS.md stays complete.

## the test Mac

| thing | value |
|---|---|
| the one flow's folder | `~/.carnival` (engine, libraries, prefix, game, SteamCMD and its home with the sign-in, a copy of the script, `play.log`) |
| the app | `/Applications/Road Rash.app` → `~/.carnival/carnival.sh play` |

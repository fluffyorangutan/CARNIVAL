# crimewave · anchor

A recipe that runs Road Rash 30th Anniversary Edition (Steam, Windows) on an Apple silicon Mac. One script, one README. Made 19 nov 2026.

## read first

1. [STATE.md](STATE.md)
2. [DECISIONS.md](DECISIONS.md)
3. [README.md](README.md) · the steps and the cause of each fix

## laws

- **Never commit the wrapper,** game files, Steam files or a sign-in. The repo holds text only.
- **Each download asks first.** A new download in the script gets its own y/n line with maker, licence and link.
- **Each claim says if it is tested.** The README's `tested on` and `limits` tables are the record. Update them with every change.
- **Never kill a process while Nevil plays.** Two stops on 19 nov 2026 closed his sign-in and his game.
- **Not pushed.** A push to a public remote is Nevil's call, each time.
- Global laws apply: no em dashes · lowercase headers · facts or an `owed ·` slot · CREDITS.md stays complete.

## the test Mac

| thing | value |
|---|---|
| wrapper | `~/Applications/Sikarugir/crimewave.app` |
| SteamCMD | `~/steamcmd` |
| launcher | `~/Applications/Road Rash.app` → `~/steamcmd/play_roadrash.sh` (made before this repo) |

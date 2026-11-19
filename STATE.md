# state · CARNIVAL

> Last written 19 nov 2026 (the app in /Applications, `CARNIVAL.command`, CW-08). Before that 19 nov 2026 (named CARNIVAL, pushed private, CW-07).

## now

| thing | status |
|---|---|
| `./carnival.sh` from an empty `~/.carnival` | ran with no clicks on the test Mac · 19 nov 2026 |
| `/Applications/Road Rash.app` | the flow wrote it and the game started from it · 19 nov 2026 · icon from the game's exe |
| `CARNIVAL.command` from an empty folder | opened as a double-click does, 19 nov 2026, 23:24 · the y/n, libraries, engine, Windows folder, SteamCMD and the sign-in passed · stopped by Nevil in the game download, 3.3 GB in · owed · the end of the download, the app, the game start |
| picture, sound, full screen from the new app | yes · Nevil, 19 nov 2026 |
| `check` · a "no" at the y/n | tested |
| `update` · `remove` · the Rosetta line · the password and code path | not tested |
| remote | GitHub · private · `CARNIVAL` |

## next

- Finish the retest, on Nevil's word ("test later, need internet", 19 nov 2026). The half-done run is in `~/.carnival.partial`. Steps: game closed · `mv ~/.carnival ~/.carnival.keep` · move `/Applications/Road Rash.app` into the keep folder · `mv ~/.carnival.partial ~/.carnival` · `open CARNIVAL.command`. After a pass, ask before the keep folder is deleted.
- A second Mac.

## blocked on nevil

| # | thing | what is needed |
|---|---|---|
| 1 | going public | the repo is private on GitHub. His word to make it public. |

## handoff notes

- Wine commands need the variables in `wine_env`. `nohup` strips the `DYLD` one.
- In zsh, `$0` inside a function is the function's name. The script reads its own path once, at the top, as `SELF`.
- `game_running` matches any `RoadRash95.exe`, from this folder or from an old wrapper.
- Making a Sikarugir wrapper waits while another wrapper runs (seen 19 nov 2026, 32 minutes). The one flow does not use the Creator.
- The test Mac moved from `~/.crimewave` to `~/.carnival` on 19 nov 2026. The app start that looked dead after the move was the check itself: the test line held the game's name, and `game_running` read it as the game. Fixed in CW-08.
- In a test line, never write the game's exe name in full. Use a pattern such as `roadrash9[5]`.

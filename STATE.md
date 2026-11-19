# state · CARNIVAL

> Last written 19 nov 2026 (the app in /Applications, `CARNIVAL.command`, CW-08). Before that 19 nov 2026 (named CARNIVAL, pushed private, CW-07).

## now

| thing | status |
|---|---|
| `./carnival.sh` from an empty `~/.carnival` | ran with no clicks on the test Mac · 19 nov 2026 |
| `/Applications/Road Rash.app` | the flow wrote it and the game started from it · 19 nov 2026 · icon from the game's exe |
| `CARNIVAL.command` | ran from a shell, all parts in place · owed · a double-click in Finder · owed · a run from an empty folder |
| picture, sound, full screen from the new app | yes · Nevil, 19 nov 2026 |
| `check` · a "no" at the y/n | tested |
| `update` · `remove` · the Rosetta line · the password and code path | not tested |
| remote | GitHub · private · `CARNIVAL` |

## next

- The retest from an empty folder: Nevil quits the game, `~/.carnival` moves aside, a double-click on `CARNIVAL.command` runs all steps.
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

# state · CARNIVAL

> Last written 20 nov 2026 (the review fixes CW-09, the small points and `--from` CW-10, the live rebuild). Before that 19 nov 2026 (CW-08).

## now

| thing | status |
|---|---|
| `/Applications/Road Rash.app` | rebuilt with the new script · 20 nov 2026 · started the game process in 7 s, then closed by Claude for the test · ready to play |
| `~/.carnival` | every `check` row yes · engine and libraries adopted (no download) · Windows folder set again · 20 nov 2026 |
| the review fixes (CW-09, CW-10) | 5 skeptics, 4 judges, 112 tests, then a 24-check gate in scratch: all passed · 20 nov 2026 |
| a flow from an empty folder | passed in scratch with the real downloads and `--from` · 171 s · the Steam download itself not run |
| `--from FOLDER` | tested from the live `~/.carnival` · 20 nov 2026 |
| picture, sound, full screen | the app opens · Nevil, 20 nov 2026 · picture, sound and full screen not re-confirmed after the rebuild |
| `update` with the password and code | owed · the new SteamCMD home is empty, so the next `update` asks for both once |
| a Mac without developer tools | simulated only |
| remote | GitHub · private · `CARNIVAL` · the CW-09 and CW-10 commit pushed · 20 nov 2026 |

## next

- Nevil: his save file from before is not in the app. The old folders held none. Treated as fine (Nevil, 20 nov 2026).
- A second Mac: `./carnival.sh --from` a copy of `~/.carnival` on a drive, or the Steam sign-in.

## blocked on nevil

| # | thing | what is needed |
|---|---|---|
| 1 | going public | the repo is private on GitHub. His word to make it public. |

## handoff notes

- Wine commands need the variables in `wine_env`. `nohup` strips the `DYLD` one.
- In zsh, `$0` inside a function is the function's name. The script reads its own path once, at the top, as `SELF`.
- `game_running` reads `ps -o comm`. This engine starts each Windows program from `winetemp-*/<File>.exe`, so the name is the exe's, capitals kept (tested 20 nov 2026).
- SteamCMD obeys `HOME`. The script runs it with `HOME=~/.carnival/steamhome`.
- The live game folder is `drive_c/games/roadrash` on disk (lower case); APFS ignores case, so `Games/RoadRash` works.
- Test only in scratch: `HOME`, `CARNIVAL_ROOT` and `CARNIVAL_APP` all in scratch, and a stub `open` first in `PATH`. A folder with files and no `.consent` is refused, so give a test folder a `.consent`.
- A backup of the live registry files and the old app, from before the rebuild, is in Claude's scratchpad (`live_backup`). A reboot clears it.
- In a test line, never write the game's exe name in full. Use a pattern such as `roadrash9[5]`.

# state · CARNIVAL

> Last written 20 nov 2026 (the game in 11 pieces on Proton CW-12, the wineserver wait fix CW-13). Before that: the review fixes CW-09, CW-10.

## now

| thing | status |
|---|---|
| `/Applications/Road Rash.app` | rebuilt with the new script · 20 nov 2026 · started the game process in 7 s, then closed by Claude for the test · ready to play |
| `~/.carnival` | every `check` row yes · engine and libraries adopted (no download) · Windows folder set again · 20 nov 2026 |
| the review fixes (CW-09, CW-10) | 5 skeptics, 4 judges, 112 tests, then a 24-check gate in scratch: all passed · 20 nov 2026 |
| a flow from an empty folder | passed in scratch with the real downloads and `--from` · 171 s · the Steam download itself not run |
| `--from FOLDER` | tested from the live `~/.carnival` and from the 11 Proton pieces joined in a scratch home · 20 nov 2026 |
| picture, sound, full screen | the app opens · Nevil, 20 nov 2026 · picture, sound and full screen not re-confirmed after the rebuild |
| `update` with the password and code | owed · the new SteamCMD home is empty, so the next `update` asks for both once |
| a Mac without developer tools | simulated only |
| the Windows-folder wait (CW-13) | fixed and tested in scratch · NOT pushed yet, so the one-line install on GitHub still has the old wait · 20 nov 2026 |
| remote | GitHub · PUBLIC since 20 nov 2026 · `fluffyorangutan/CARNIVAL` · all commits pushed except the ones named in `git status` |

## next

- Nevil: his save file from before is not in the app. The old folders held none. Treated as fine (Nevil, 20 nov 2026).
- Push the CW-13 fix, so the one-line install and the Proton note fetch the fixed script. Then the second Mac (M1 Pro): two ways owed. (1) the one line from the README, with Steam. (2) the line in the Proton note, no Steam. Report the last lines, picture and sound.

## blocked on nevil

| # | thing | what is needed |
|---|---|---|

## handoff notes

- The game copy for `--from` sits in Proton Drive, folder `Road Rash`: `pieces/` (11 files, plain) and `READ ME.txt` (CW-12). The Proton Drive app stalled on the 3.2 GB file; rclone (`proton:` remote, `--protondrive-replace-existing-draft=true`) uploaded the pieces. macOS blocks listing the sync folder. Never put it in the repo.

- Wine commands need the variables in `wine_env`. `nohup` strips the `DYLD` one.
- In zsh, `$0` inside a function is the function's name. The script reads its own path once, at the top, as `SELF`.
- `game_running` reads `ps -o comm`. This engine starts each Windows program from `winetemp-*/<File>.exe`, so the name is the exe's, capitals kept (tested 20 nov 2026).
- SteamCMD obeys `HOME`. The script runs it with `HOME=~/.carnival/steamhome`.
- The live game folder is `drive_c/games/roadrash` on disk (lower case); APFS ignores case, so `Games/RoadRash` works.
- Test only in scratch: `HOME`, `CARNIVAL_ROOT` and `CARNIVAL_APP` all in scratch, and a stub `open` first in `PATH`. A folder with files and no `.consent` is refused, so give a test folder a `.consent`.
- A backup of the live registry files and the old app, from before the rebuild, is in Claude's scratchpad (`live_backup`). A reboot clears it.
- In a test line, never write the game's exe name in full. Use a pattern such as `roadrash9[5]`.

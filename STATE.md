# state · crimewave

> Last written 19 nov 2026 , later still (icon, old setup deleted, CW-06). Before that 19 nov 2026 (the repo made).

## now

| thing | status |
|---|---|
| `./crimewave.sh` from an empty `~/.crimewave` | ran with no clicks on the test Mac · 19 nov 2026 |
| `Road Rash.app` | starts the game process, no Steam process · icon from the game's exe |
| picture, sound, full screen from the new app | yes · Nevil, 19 nov 2026 |
| `check` · a "no" at the y/n | tested |
| `update` · `remove` · the Rosetta line · the password and code path | not tested |
| remote | none · local commits only |

## next

- A second Mac.

## blocked on nevil

| # | thing | what is needed |
|---|---|---|
| 2 | going public | his word to make a GitHub repo and push. |
| 3 | the repo name | `crimewave` is his wrapper name. His yes or another name. |

## handoff notes

- Wine commands need the variables in `wine_env`. `nohup` strips the `DYLD` one.
- In zsh, `$0` inside a function is the function's name. The script reads its own path once, at the top, as `SELF`.
- `game_running` matches any `RoadRash95.exe`, from this folder or from an old wrapper.
- Making a Sikarugir wrapper waits while another wrapper runs (seen 19 nov 2026, 32 minutes). The one flow does not use the Creator.

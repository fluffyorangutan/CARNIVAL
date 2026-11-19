# state · crimewave

> Last written 19 nov 2026 (the repo made, first commit).

## now

| thing | status |
|---|---|
| the game on the test Mac | plays, picture and sound · Nevil, 19 nov 2026 |
| `crimewave.sh check` | tested |
| `crimewave.sh tools` · `tune` · `game` | written from the commands run by hand · not run as written |
| `crimewave.sh play` | same logic as the test Mac's launcher · direct start not re-tested after the `gdi` fix |
| remote | none · local commits only |

## next

- One clean run from step 1, on a new wrapper name, to test the order (Windows 7 before Steam's first start).
- Check the intro and cut-scene videos.

## blocked on nevil

| # | thing | what is needed |
|---|---|---|
| 1 | the licence | MIT is Claude's pick (CW-02). His yes or another licence. |
| 2 | going public | his word to make a GitHub repo and push. |
| 3 | the repo name | `crimewave` is his wrapper name. His yes or another name. |

## handoff notes

- Wine commands need the four variables in `wine_env`. `nohup` strips the `DYLD` one.
- Sikarugir Creator and Launcher are not open source, by the Sikarugir README. The README table says so.

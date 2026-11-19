# decisions · CARNIVAL

Append only. Numbered `CW-nn` (from the first name, crimewave). Newest first.

## CW-08 · the app lives in /Applications, one file starts the flow · 19 nov 2026

**Ruled by Nevil, 19 nov 2026:** "Yes, move it · and test · and pack it all up · and retest · so that it is a single click complete flow".

**What it means here.** The script writes `/Applications/Road Rash.app`. A user who cannot write there gets `~/Applications`. An app this script wrote in the old place is deleted. `CARNIVAL.command` is the one file to double-click; it runs `carnival.sh` in Terminal.

**What stays with the person, Claude's line.** The y/n and the Steam sign-in (CW-03, CW-04). The double-click does not remove them.

**Flagged for record only.** `game_running` read the full command line, so a shell line that held the game's name counted as the game. It now reads the program name only.

## CW-07 · the name is CARNIVAL, the repo is private on GitHub · 19 nov 2026

**Ruled by Nevil, 19 nov 2026:** "push it to github, private srill · name: CARNIVAL".

**What it means here.** The repo, the folder `_yussuf/CARNIVAL`, the script `carnival.sh` and the home folder `~/.carnival` take the name. Entries below keep the old words: `crimewave.sh`, `~/.crimewave`. Private on GitHub; public is a new ruling.

**Ruled by Claude, his to veto.** The game's files never ship in the repo, private or public. Each person's copy comes from their own Steam account through SteamCMD.

## CW-06 · the icon is read from the game, the old setup is deleted · 19 nov 2026

**His words, 19 nov 2026.** "icon will be the roadrash icon right?" · "isn't the newer better? why keep old?? maybe just for record" · then "Yes, delete it".

**What it means here.** `icon.py` reads the icon out of the person's own `RoadRash95.exe`; the repo holds no icon, because Electronic Arts owns it. The first way's files are deleted from the test Mac (two Sikarugir wrappers, `~/steamcmd`, Sikarugir Creator, its cache; 7 GB freed). The record of the first way is commit `504edb5`.

**Flagged for record only.** The script is for this one game. `gdi`, the registry entry and the start with no Steam app do not carry to other games.

## CW-05 · MIT, ruled · 19 nov 2026

**Ruled by Nevil, 19 nov 2026:** "MIT yes". CW-02 was Claude's pick; it is now his ruling.

## CW-04 · one flow, no clicks, no Steam app · 19 nov 2026

**His words, 19 nov 2026.** "this needs to work automatcally, without human intervension · from click to opening roadrash on steam · one streamline flow" · "to having roadrash added as an app on their mac whcih opens in full screen, and not have to see any of the background works or see the steam logo even".

**What it means here.** `./crimewave.sh` with no argument runs all steps. The Sikarugir Creator, the wrapper and the Steam app are out: the script downloads the engine and the Template's libraries by link, makes the Wine prefix itself, and the game starts without the Steam app (tested 19 nov 2026). It writes `~/Applications/Road Rash.app`.

**What stays with the person, Claude's line.** One y/n before the downloads (CW-03, now one question for the whole list). The Steam sign-in, typed into SteamCMD by the person. A script does not type a password.

**Flagged for record only.** Full screen is the game's own default; the script does not set it. Confirmed by Nevil, 19 nov 2026: full screen, picture, sound.

## CW-03 · each download asks, then the script links to the game · 19 nov 2026

**His words, 19 nov 2026.** "can I have them consent to downloading the other 2? and then link to the steam game?"

**What it means here.** `tools` asks y/n before Rosetta 2, Sikarugir Creator, SteamCMD and the Steam installer. Each line names the maker, the licence and the link. Then it offers to open the store page. The repo holds none of these files.

## CW-02 · MIT · 19 nov 2026

**Claude's pick, his to veto.** He asked how to make it open source. MIT is the short one: all people may use and change the work. No ruling from him yet.

## CW-01 · the recipe gets a repo, the wrapper never ships · 19 nov 2026

**Ruled by Nevil, 19 nov 2026:** "make the repo".

**What it means here.** A folder at `_yussuf/crimewave`, its own repo. It holds the script and the steps. The wrapper app holds the game, the Steam client and his sign-in, so it stays on his Mac.

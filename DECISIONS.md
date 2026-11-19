# decisions · crimewave

Append only. Numbered `CW-nn`. Newest first.

## CW-04 · one flow, no clicks, no Steam app · 19 nov 2026

**His words, 19 nov 2026.** "this needs to work automatcally, without human intervension · from click to opening roadrash on steam · one streamline flow" · "to having roadrash added as an app on their mac whcih opens in full screen, and not have to see any of the background works or see the steam logo even".

**What it means here.** `./crimewave.sh` with no argument runs all steps. The Sikarugir Creator, the wrapper and the Steam app are out: the script downloads the engine and the Template's libraries by link, makes the Wine prefix itself, and the game starts without the Steam app (tested 19 nov 2026). It writes `~/Applications/Road Rash.app`.

**What stays with the person, Claude's line.** One y/n before the downloads (CW-03, now one question for the whole list). The Steam sign-in, typed into SteamCMD by the person. A script does not type a password.

**Flagged for record only.** Full screen is the game's own default; the script does not set it. Not confirmed by eye yet.

## CW-03 · each download asks, then the script links to the game · 19 nov 2026

**His words, 19 nov 2026.** "can I have them consent to downloading the other 2? and then link to the steam game?"

**What it means here.** `tools` asks y/n before Rosetta 2, Sikarugir Creator, SteamCMD and the Steam installer. Each line names the maker, the licence and the link. Then it offers to open the store page. The repo holds none of these files.

## CW-02 · MIT · 19 nov 2026

**Claude's pick, his to veto.** He asked how to make it open source. MIT is the short one: all people may use and change the work. No ruling from him yet.

## CW-01 · the recipe gets a repo, the wrapper never ships · 19 nov 2026

**Ruled by Nevil, 19 nov 2026:** "make the repo".

**What it means here.** A folder at `_yussuf/crimewave`, its own repo. It holds the script and the steps. The wrapper app holds the game, the Steam client and his sign-in, so it stays on his Mac.

# decisions · CARNIVAL

Append only. Numbered `CW-nn` (from the first name, crimewave). Newest first.


## CW-12 · a private copy of the game in Proton Drive, for --from · 20 nov 2026

**Ruled by Nevil, 20 nov 2026:** "A, plain zip, with a .txt file with the --from line also in it". His aim: fewer Steam points of failure.

**What it means here.** The game folder from `~/.carnival` (3.2 GB, zipped) sits in his Proton Drive, folder `Road Rash`, as 11 pieces in `pieces/` (10 of 300 MB, one of 262 MB), with `READ ME.txt`. Proton encrypts it; no passcode on top. The note holds one line: fetch the recipe, join the pieces, check the SHA-256, unzip, run `carnival.sh --from`. The line stops with `pieces · checksum wrong` if a piece is missing or cut.

**Why pieces.** One 3.2 GB file failed twice through rclone's Proton backend (a block rejected as empty, speed falling to 50 KiB/s), and the Proton Drive app left a stuck draft. Plain 300 MB pieces uploaded with 3 tries each, up to four at once. rclone's own `chunker` could split too, but the new Mac would then need rclone. Plain pieces need nothing (Nevil asked, 20 nov 2026; kept the plain pieces).

**Tested.** All 11 sizes on Proton match the local pieces. The pieces were downloaded back, joined, and the SHA-256 equals the zip's (`6a3fdc91…b352b5`). The note's exact line ran in a scratch home with the pieces in `~/Downloads/pieces`: no Steam, every `check` row yes, `game files · from a copy`, the app made. That run took 3713 s because of CW-13.

**Never in the repo.** The game is Electronic Arts' work and the repo is public (CW-11). `.gitignore` already blocks `*.exe`. The pieces are for his own Macs only, as the README limit says.

**Flagged for record only.** macOS blocks listing the Proton sync folder, so the upload was done and checked with `rclone` (`proton:` remote). A shared Mac load (the Xbox download, other sessions' jobs) slowed it.


## CW-13 · the Windows-folder step no longer waits for ever · 20 nov 2026

**Found by Claude, 20 nov 2026.** Two runs of the flow hung for 2 hours and 1 hour at the Windows folder step. The script ran `wineserver -w`, which has no time limit. Two helper processes (`services.exe`, `explorer.exe`) stayed alive, so it never returned. Stopping that wineserver by hand made the script finish with all three settings intact.

**What it means here.** `wine_idle` waits 60 s at most, then stops the wineserver the clean way (`wineserver -k`, which saves the registry), then goes on. `settings_ok` still reads all three settings back, so a bad state still stops the flow. The helper joins the `.tuned` fingerprint, so an old install sets its Windows folder once more. Tested: a fake wineserver that never ends returns after 67 s; one that ends returns at once; the full 19-line gate passed.

**Flagged for record only.** The cause of the helpers staying alive is not known. It showed on a heavily loaded Mac. A `timeout` binary cannot wrap wine commands: it strips the `DYLD` variable.


## CW-11 · the repo is public, one line installs it · 20 nov 2026

**Ruled by Nevil, 20 nov 2026:** "let's try both" (the zip and the public one-line way).

**What it means here.** The repo `fluffyorangutan/CARNIVAL` is public on GitHub. History was scanned first: no token, no Steam id, no real email (the author is a private relay address). A second Mac gets the files with one line: `curl` the GitHub tarball, `tar` it into `~/CARNIVAL`, run `carnival.sh`. All four tools ship with macOS, so no developer tools are needed. The `archive/refs/heads/main.tar.gz` link gave a web page right after the change, so the line uses `tarball/main`. A zip of the tracked files (`git archive`) is the fallback for AirDrop.

**Flagged for record only.** The game, the Steam files and any sign-in still never ship (CW-01, CW-07). Public means the recipe only.

## CW-10 · the small points, the judges' finds, and --from · 20 nov 2026

**Ruled by Nevil, 20 nov 2026:** "also fix the small ones" · "yes build the --from option too" · "you have bypass permissions on so just go ahead and do all the tests you need".

**What it means here.**
- `Y` and `Yes` count as yes. Apple silicon is read from the hardware (`hw.optional.arm64`), so a Terminal under Rosetta passes. A user who is not an admin stops at `Rosetta 2 · admin`. Stop lines are labels and data, no sentences (`game running`, `declined`, `game · not installed · SteamCMD 5`).
- Found by the skeptics and confirmed by the judges: `update` also checks SteamCMD's exit code, because a failed sign-in leaves the old record at fully installed. The engine and libraries are replaced only through `swap`, which checks for a running game right before it deletes. A Mac without Rosetta always sees the y/n. Folders from before CW-09 with the pinned engine version are adopted, not downloaded again. The old-app cleanup compares folders, not names. `remove` takes only apps whose launcher starts this folder, and lists each one before the y/n. A folder of other files is never filled. The app checks run before the downloads.
- `./carnival.sh --from FOLDER` copies the game from the person's own copy (a game folder, or a whole `~/.carnival`) and skips SteamCMD and the sign-in. `update` still goes through Steam.

**Ruled by Claude, his to veto.** The y/n on the live rebuild was answered by Claude on his "go ahead" (20 nov 2026): the same pinned downloads he agreed to on 19 nov, and none was downloaded. The live app was started once to test it and closed with `wineserver -k` while he slept.

## CW-09 · the seven holes from the review, fixed · 20 nov 2026

**Ruled by Nevil, 19 nov 2026:** "Fix all 7".

**What it means here.**
1. An app is deleted only if it is ours: the path ends in `.app` and its Info.plist holds `local.carnival.roadrash`. Another app at the app path stops the flow. `remove` deletes a fixed list of names in the folder, needs `.consent` there, and never takes the home folder.
2. SteamCMD runs with its own home, `~/.carnival/steamhome`. Its data and the saved sign-in stay in the folder, and `remove` takes them.
3. The icon uses Python from `xcode-select -p`. `/usr/bin/python3` is Apple's stub, and on a Mac without developer tools it opens an install window.
4. The Windows folder reads back all three settings (`gdi`, Windows 7, the game's registry entry) before its marker is written.
5. The game counts as installed when SteamCMD's record says `StateFlags 4` and the exe is there. `update` stops when SteamCMD fails (exit code, CW-10) or does not finish. A start from the app writes `~/.carnival/play.log`.
6. Markers keep fingerprints: `.consent` of the download list, `.tuned` of the `prefix` step, `.sha` of each pin. A changed step runs again. The flow stops while the game runs, because it can now replace the engine.
7. The app's launcher carries `CARNIVAL_ROOT`.

**Ruled by Claude, his to veto.** The sign-in from earlier runs stays in `~/Library/Application Support/Steam`. The script never deletes that folder, because a Mac Steam app may own it. On the test Mac it is SteamCMD's only, so deleting it is his call. The first full run after this change asks the y/n again and sets the Windows folder again, once, because the old markers hold no fingerprint. (The 268 MB download again was dropped in CW-10: old folders are adopted.)

**Flagged for record only.** The small points from the review were left open here and fixed in CW-10.

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

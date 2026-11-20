# CARNIVAL

Road Rash 30th Anniversary Edition is a Windows game on Steam. One double-click puts it on an Apple silicon Mac as an app.

**You bring the game.** Buy it on Steam: https://store.steampowered.com/app/2448570/ . The repo holds no game files, no Steam files and no sign-in.

## use

**On a Mac with nothing on it,** paste this one line into Terminal. It downloads the recipe into `~/CARNIVAL` and runs it. It needs only tools that ship with macOS.

```bash
mkdir -p ~/CARNIVAL && curl -fsSL https://github.com/fluffyorangutan/CARNIVAL/tarball/main | tar -xz --strip-components=1 -C ~/CARNIVAL && zsh ~/CARNIVAL/carnival.sh
```

Not tested on a second Mac yet. The download and unpack were tested in a scratch folder on 20 nov 2026.

**With the files already on the Mac,** double-click `CARNIVAL.command`. Terminal opens and runs the flow. The same from a shell:

```bash
./carnival.sh
```

It asks two things. All other steps run by themselves.

| it asks | when |
|---|---|
| one y/n, after a list of each download with maker, licence and link | first run · again when the list changes |
| your Steam sign-in name, then password and code from SteamCMD | first game download · later downloads ask the name only, because SteamCMD keeps the sign-in in `~/.carnival/steamhome` · not asked with `--from` |

Then it makes `/Applications/Road Rash.app` and opens the game. After that, open the app. A Mac user who cannot write to `/Applications` gets `~/Applications/Road Rash.app`. If another app already has that name, the flow stops and leaves that app alone.

| command | what |
|---|---|
| `./carnival.sh` | the whole flow · safe to run again, it skips what is done · stops while the game runs |
| `./carnival.sh --from FOLDER` | the whole flow, with the game copied from your own copy instead of Steam · FOLDER is a game folder or a whole `~/.carnival` from another Mac |
| `./carnival.sh play` | start the game |
| `./carnival.sh update` | download the game again with SteamCMD · stops if SteamCMD fails or does not finish |
| `./carnival.sh check` | show the state · changes nothing |
| `./carnival.sh remove` | after a y/n, delete what the flow made in `~/.carnival` (the sign-in too) and each app that starts this folder · your own files in the folder stay |

## what it does

1. Rosetta 2, if missing.
2. Downloads the Wine engine `WS12WineCX24.0.7_7` and the libraries from Sikarugir Template 1.0.27. Both are checked against a SHA-256. Each folder keeps its SHA-256, so a newer pin downloads again.
3. Downloads SteamCMD for Mac. It gets its own home, `~/.carnival/steamhome`, so its data and your sign-in stay in the folder.
4. Makes a Windows folder (a Wine prefix) in `~/.carnival/prefix`. Sets Windows 7, the renderer `gdi` and the game's registry entry, then reads all three back.
5. SteamCMD downloads the Windows game files, 3.4 GB, with your sign-in. The game counts as installed when SteamCMD's own record says fully installed. With `--from`, the files are copied from your own copy and Steam is not used.
6. Writes `Road Rash.app`, with the icon from your own game files. It starts `RoadRash95.exe` in Wine. Each start from the app writes `~/.carnival/play.log`.

The Steam app is not installed and does not run. The game starts without it.

## tested on

| thing | value |
|---|---|
| Mac | M1 Pro |
| macOS | 27.2.1 |
| engine | WS12WineCX24.0.7_7 |
| date | 19 nov 2026 · the review fixes 20 nov 2026 |
| Macs tested | 1 |

| what | result |
|---|---|
| a "no" at the y/n | stops, nothing downloaded |
| steps 1 to 6 from an empty `~/.carnival` | ran with no clicks · Rosetta was already there, so that line is not tested |
| sign-in | SteamCMD used a saved sign-in · the password and code path is SteamCMD's own, not re-tested in this flow |
| the app | starts the game process, no Steam process |
| picture, sound, full screen from the new app | yes · Nevil, 19 nov 2026 |
| the app in `/Applications` | the flow wrote it and the game started from it · 19 nov 2026 |
| `CARNIVAL.command` from an empty folder | the y/n, the downloads of step 2 and 3, step 4 and the sign-in passed · the run was stopped in the game download · the rest is owed |
| the review fixes (CW-09, CW-10), in a scratch folder | from an empty folder with the real downloads and `--from`: the y/n, engine, libraries, SteamCMD, Windows folder, app, icon · a second run asks nothing · another app at the app path stops and stays · `update` after a failed sign-in stops · an old install asks the y/n once and downloads nothing · a running game stops `all` and `remove` · `Yes` and `n` at the y/n · a folder of other files is refused · `remove` keeps your own file · 20 nov 2026 |
| the app from a scratch build, and the live app after the rebuild | each started the game process (8 s, 7 s), wrote `play.log`, and a second click started no second copy · closed after the test · 20 nov 2026 |
| the live rebuild | `./carnival.sh` on `~/.carnival`: no download, the Windows folder set again, the app written again, every `check` row yes · 20 nov 2026 |
| SteamCMD's own home | a copy of SteamCMD wrote its data under the home it was given, and `~/Library/Application Support/Steam` did not change · 20 nov 2026 |
| a Mac with no developer tools | simulated only (xcode-select made to fail): the icon is skipped and no install window opens |
| the sign-in in the new SteamCMD home, with password and code | owed · the next `update` asks for both once |
| a second Mac | owed |

## why each setting is there

| problem | cause | fix |
|---|---|---|
| black screen with music | the game draws with DirectDraw, and Wine's OpenGL path shows black on this Mac | `Software\Wine\Direct3D` · `renderer` = `gdi` |
| the game quits at once | SteamCMD does not run the game's install script, so a registry entry is missing | the script writes `Electronic Arts\RoadRash 95` · `path` · `language` |
| Wine crashes with exit 136, or cannot load `libinotify` | Wine needs its sync variables and the library folder | `wine_env` in the script sets them on each call |
| Windows 7 | the first working setup ran on it | kept · Windows 10 is not tested for the game |

## the first way, kept for the record

The first working setup used the Steam app inside a Sikarugir wrapper. It needed clicks and had more faults: Steam error 0x3008 on macOS 27, "Failed unpacking chunk" in Steam's own download, a microphone prompt that came back, and a wrapper build that waits while another wrapper runs. It is in the git history, commit `504edb5`. Its files were deleted from the test Mac on 19 nov 2026.

## limits

- **A downloaded copy.** macOS can block a `.command` file that came from a browser download. Not tested. `./carnival.sh` in Terminal is the other way in.
- **Updates.** Run `./carnival.sh update`.
- **Steam features.** The Steam app does not run, so the Steam overlay, cloud saves and achievements are not expected to work. Not checked.
- **Videos.** The intro and cut-scene videos are not checked.
- **The app icon.** The script reads it from the game's own `RoadRash95.exe` (48 by 48, scaled with hard pixels). It needs Python from Xcode or from Apple's command line tools. Without them the app has no icon, no install window opens, and the app still works.
- **Space.** The game is 3.4 GB. The engine and libraries are 268 MB as downloads. owed · the size on disk.
- **A sign-in from before 20 nov 2026.** Runs before then saved the Steam sign-in in `~/Library/Application Support/Steam`. The script does not touch that folder, because the Mac Steam app uses it too.
- **The first run of a changed script.** A step whose pin, list or settings changed runs again once: the y/n, the engine and libraries download (268 MB), or the Windows folder.
- **Outside the folder.** SteamCMD swaps its launchd job `com.valvesoftware.steamclean` and can write crash reports to `/tmp/dumps`. `remove` does not take those.
- **`--from`.** For your own copy on your own Macs only. Never share the game files.

## never share the folder

`~/.carnival` holds the game and your Steam sign-in. Share this repo, not the folder.

## how open is it

| part | open source |
|---|---|
| this repo | yes · MIT |
| Wine, the engine | yes · LGPL-2.1 |
| the libraries from the Sikarugir Template | owed · a licence per library |
| Rosetta 2 | no · Apple |
| SteamCMD | no · Valve |
| the game | no · Electronic Arts |

Names, licences and links: [CREDITS.md](CREDITS.md).

Road Rash is a trademark of Electronic Arts. Steam is a trademark of Valve. This repo is not connected to either company.

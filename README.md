# CARNIVAL

Road Rash 30th Anniversary Edition is a Windows game on Steam. One double-click puts it on an Apple silicon Mac as an app.

**You bring the game.** Buy it on Steam: https://store.steampowered.com/app/2448570/ . The repo holds no game files, no Steam files and no sign-in.

## use

Double-click `CARNIVAL.command`. Terminal opens and runs the flow. The same from a shell:

```bash
./carnival.sh
```

It asks two things. All other steps run by themselves.

| it asks | when |
|---|---|
| one y/n, after a list of each download with maker, licence and link | first run |
| your Steam sign-in name, then password and code from SteamCMD | first run · later runs use SteamCMD's saved sign-in |

Then it makes `/Applications/Road Rash.app` and opens the game. After that, open the app. A Mac user who cannot write to `/Applications` gets `~/Applications/Road Rash.app`.

| command | what |
|---|---|
| `./carnival.sh` | the whole flow · safe to run again, it skips what is done |
| `./carnival.sh play` | start the game |
| `./carnival.sh update` | download the game again with SteamCMD |
| `./carnival.sh check` | show the state · changes nothing |
| `./carnival.sh remove` | delete `~/.carnival` and the app, after a y/n |

## what it does

1. Rosetta 2, if missing.
2. Downloads the Wine engine `WS12WineCX24.0.7_7` and the libraries from Sikarugir Template 1.0.27. Both are checked against a SHA-256.
3. Downloads SteamCMD for Mac.
4. Makes a Windows folder (a Wine prefix) in `~/.carnival/prefix`. Sets Windows 7, the renderer `gdi` and the game's registry entry.
5. SteamCMD downloads the Windows game files, 3.4 GB, with your sign-in.
6. Writes `Road Rash.app`, with the icon from your own game files. It starts `RoadRash95.exe` in Wine.

The Steam app is not installed and does not run. The game starts without it.

## tested on

| thing | value |
|---|---|
| Mac | M1 Pro |
| macOS | 27.2.1 |
| engine | WS12WineCX24.0.7_7 |
| date | 19 nov 2026 |
| Macs tested | 1 |

| what | result |
|---|---|
| a "no" at the y/n | stops, nothing downloaded |
| steps 1 to 6 from an empty `~/.carnival` | ran with no clicks · Rosetta was already there, so that line is not tested |
| sign-in | SteamCMD used a saved sign-in · the password and code path is SteamCMD's own, not re-tested in this flow |
| the app | starts the game process, no Steam process |
| picture, sound, full screen from the new app | yes · Nevil, 19 nov 2026 |
| the app in `/Applications` | the flow wrote it and the game started from it · 19 nov 2026 |
| `CARNIVAL.command` | ran from a shell on a Mac with all parts in place · a double-click in Finder and a run from an empty folder are owed |
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
- **The app icon.** The script reads it from the game's own `RoadRash95.exe` (48 by 48, scaled with hard pixels). It needs `/usr/bin/python3`, which comes with Apple's command line tools. Without it the app has no icon and still works.
- **Space.** The game is 3.4 GB. The engine and libraries are 268 MB as downloads. owed · the size on disk.

## never share the folder

`~/.carnival` holds the game. Share this repo, not the folder.

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

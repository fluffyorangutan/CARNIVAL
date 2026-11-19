# crimewave

Road Rash 30th Anniversary Edition is a Windows game on Steam. This is the recipe that runs it on an Apple silicon Mac.

**You bring the game.** Buy it on Steam: https://store.steampowered.com/app/2448570/ . The repo holds no game files, no Steam files and no sign-in.

## tested on

| thing | value |
|---|---|
| Mac | M1 Pro |
| macOS | 27.2.1 |
| Sikarugir Creator | 1.0.2 · template 1.0.27 |
| engine | WS12WineCX24.0.7_7 |
| date | 19 nov 2026 |
| Macs tested | 1 |

It worked once, on one Mac. Other Macs are not tested.

## what you need

- An Apple silicon Mac.
- Homebrew: https://brew.sh
- A Steam account that owns the game.
- Free space: the game is 3.4 GB and Steam is 446.5 MB. owed · the size of the engine and template.

## steps

Six steps. Steps 2 and 4 are by hand, in the Sikarugir windows.

**1 · get the tools.** The script asks before each download.

```bash
./crimewave.sh tools
```

It asks for: Rosetta 2 (if missing) · Sikarugir Creator · SteamCMD · the Steam for Windows installer. Then it offers to open the game's store page.

**2 · make the wrapper, by hand.**

1. Open Sikarugir Creator.
2. Click Download Template.
3. Click Change. Pick the engine `WS12WineCX24.0.7_7`.
4. Click Create. Name it `crimewave`.
5. A Configure window opens. Close it.

**3 · set the wrapper.**

```bash
./crimewave.sh tune
```

It sets Windows 7, sets the renderer to `gdi`, and signs the Configure app. Then it opens the Configure window again.

**4 · install Steam, by hand.**

1. In the Configure window, click Install Software.
2. Click Choose Setup Executable. Pick `SteamSetup.exe` in Downloads.
3. Click Install in the Steam window. Keep the folder `C:\Program Files (x86)\Steam`.
4. If Steam opens, sign in once, then quit Steam. Close the Configure window.

**5 · get the game.** You type your own Steam sign-in name, password and code.

```bash
./crimewave.sh game
```

**6 · play.**

```bash
./crimewave.sh play
```

To see the state of the setup at any time, with no changes made:

```bash
./crimewave.sh check
```

## why each fix is there

| problem | cause | fix |
|---|---|---|
| Steam shows error 0x3008 and no window | the current Steam client fails under Wine on macOS 27 | Windows version set to Windows 7, so Steam installs an older client |
| the download stops, "Failed unpacking chunk" in `content_log.txt` | the older client cannot unpack this game | SteamCMD for Mac downloads the Windows files |
| the game quits at once | SteamCMD does not run the game's install script, so a registry entry is missing | the script writes `Electronic Arts\RoadRash 95` · `path` · `language` |
| black screen with music | the game draws with DirectDraw, and Wine's OpenGL path shows black | `Software\Wine\Direct3D` · `renderer` = `gdi` |
| the microphone prompt comes back after each answer | the Configure app inside the wrapper is not signed | ad-hoc `codesign` on `Configure.app` |
| Steam does not start after a forced stop | leftover Wine processes, or a `.crash` file in the Steam folder | quit all Wine processes of the wrapper · `play` deletes `.crash` |

## limits

- **Not tested in this order.** On the test Mac, Steam was installed and run on Windows 10 first, then the wrapper was set to Windows 7. The steps above set Windows 7 first. owed · one clean run from step 1.
- **`tune` and `game` are not tested as written.** The same commands were run by hand, one by one. `check` is tested. `play` is the same script that the test Mac's launcher runs; its direct start was not re-tested after the `gdi` fix.
- **Updates.** Steam inside the wrapper cannot download game updates. Run `./crimewave.sh game` again.
- **The older Steam client.** Steam ended Windows 7 support. This client may stop one day.
- **Videos.** The intro and cut-scene videos are not checked.
- **A wrapper with another name.** Set `CRIMEWAVE_WRAPPER=name` before the command.

## never share the wrapper

`crimewave.app` holds the game, the Steam client and your Steam sign-in. Share this repo, not the app.

## how open is it

| part | open source |
|---|---|
| this repo | yes · MIT |
| Wine, the engine | yes · LGPL-2.1 |
| Sikarugir `Configure.app` | yes · LGPL-2.1 |
| Sikarugir Creator and Launcher | no, by the Sikarugir README |
| Rosetta 2 | no · Apple |
| Steam, SteamCMD | no · Valve |
| the game | no · Electronic Arts |

Names, licences and links: [CREDITS.md](CREDITS.md).

Road Rash is a trademark of Electronic Arts. Steam is a trademark of Valve. This repo is not connected to either company.

#!/bin/zsh
# CARNIVAL · Road Rash 30th Anniversary Edition (Steam, Windows) on an Apple silicon Mac
# MIT · LICENSES/MIT.txt · written by Claude (AI) on Nevil Hitesh's ask · 19–20 nov 2026
# use: double-click CARNIVAL.command, or
#      ./carnival.sh                    one flow: tools, game, app, play
#      ./carnival.sh --from FOLDER      the same, the game copied from your own copy instead of Steam
#      ./carnival.sh play | update | check | remove

set -u
SELF="${0:A}"

ROOT="${${CARNIVAL_ROOT:-$HOME/.carnival}:a}"
# the app goes in /Applications. a Mac user who cannot write there gets ~/Applications.
OLDAPP="${HOME:a}/Applications/Road Rash.app"
if [[ -n "${CARNIVAL_APP:-}" ]]; then APPDIR="$CARNIVAL_APP"
elif [[ -w /Applications ]]; then APPDIR="/Applications/Road Rash.app"
else APPDIR="$OLDAPP"; fi
APPDIR="${APPDIR:a}"
FW="$ROOT/Frameworks"
WINE="$ROOT/wine"
PFX="$ROOT/prefix"
CMD="$ROOT/steamcmd"
# SteamCMD keeps its data and the saved sign-in in $HOME/Library/Application Support/Steam.
# here it gets its own home in the folder: remove takes the sign-in, and a Mac Steam app is not touched.
# two things stay outside: its launchd job com.valvesoftware.steamclean, and crash reports in /tmp/dumps.
STEAMHOME="$ROOT/steamhome"
GAME="$PFX/drive_c/Games/RoadRash"
APPID=2448570
BUNDLE_ID="local.carnival.roadrash"
STORE="https://store.steampowered.com/app/$APPID/"
FROM=""

ENGINE_URL="https://github.com/Sikarugir-App/Engines/releases/download/v1.0/WS12WineCX24.0.7_7.tar.xz"
ENGINE_SHA="203f9e9fd6c2cc77e6525d798a434ced326145db34a356355e05659d3445fd1c"
ENGINE_VERSION="WineCX 24.0.7 (revision 6)"
TEMPLATE_URL="https://github.com/Sikarugir-App/Template/releases/download/v1.0/Template-1.0.27.tar.xz"
TEMPLATE_SHA="dd0778f7b553d63df9b0f4e2cda3f3c6c005aabb75588c84d604afe80cdedbb9"
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz"

# the download list for the y/n: what · maker · licence · size, then the link.
# a new download is a new row here. the y/n keeps a fingerprint of this list, so a new row asks again.
ROWS=(
  "Wine engine WS12WineCX24.0.7_7 · Wine project, CodeWeavers, Sikarugir-App · LGPL-2.1 · 172 MB" "$ENGINE_URL"
  "libraries from Sikarugir Template 1.0.27 · Sikarugir-App · 96 MB" "$TEMPLATE_URL"
  "SteamCMD · Valve · Steam Subscriber Agreement" "$STEAMCMD_URL"
  "Road Rash 30th Anniversary Edition · Electronic Arts · your own Steam copy · 3.4 GB" "$STORE"
)

say() { print -- "$1"; }
stop() { print -- "stopped · $1"; exit 1; }
ask() { local a; read "a?$1 · y/n: "; [[ "$a" == [yY]* ]]; }

# every wine call needs these. without them wine crashes or cannot load its libraries.
wine_env() {
  export WINEPREFIX="$PFX"
  export DYLD_FALLBACK_LIBRARY_PATH="$FW:$WINE/lib"
  export WINEMSYNC=1 WINEESYNC=1 WINEDEBUG=-all
}
w() { "$WINE/bin/wine" "$@"; }
# reads the program name only. a shell line that holds the name does not count.
# the engine starts each Windows program from a link named after its exe, so the name is the exe's.
game_running() { ps -axo comm= | grep -q 'RoadRash95\.exe$'; }
apple_silicon() { [[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" == 1 ]]; }
rosetta() { arch -x86_64 /usr/bin/true 2>/dev/null; }

# a marker file keeps a fingerprint of its step. a newer script that changes the step
# no longer matches the marker, so that step runs again. an empty fingerprint never matches.
fingerprint() { print -rn -- "$1" | shasum -a 256 | cut -c1-16; }
consent_fp() { fingerprint "${(F)ROWS} $ENGINE_SHA $TEMPLATE_SHA"; }
# the Windows folder step: prefix and every helper it uses
tune_fp() { fingerprint "${functions[prefix]}${functions[reg_import]}${functions[wine_env]}${functions[w]}${functions[regval]}${functions[settings_ok]} $ENGINE_SHA $TEMPLATE_SHA"; }
tuned() { local f="$(tune_fp)"; [[ -n "$f" && "$(cat "$PFX/.tuned" 2>/dev/null)" == "$f" ]] && settings_ok; }
# a downloaded folder keeps the SHA-256 it came from. a new pin or a broken folder fetches again.
pinned() { [[ "$(cat "$1/.sha" 2>/dev/null)" == "$2" ]]; }
libs_ok() { pinned "$FW" "$TEMPLATE_SHA"; }
engine_ok() { pinned "$WINE" "$ENGINE_SHA" && [[ -x "$WINE/bin/wine" ]]; }
# folders from before the .sha marker (CW-09) came from these same pins. they are adopted, not fetched again.
# delete these two lines when a pin changes.
adopt() {
  [[ -d "$FW" && ! -e "$FW/.sha" && -f "$ROOT/.consent" ]] && print -r -- "$TEMPLATE_SHA" > "$FW/.sha"
  [[ -x "$WINE/bin/wine" && ! -e "$WINE/.sha" && "$(cat "$WINE/version" 2>/dev/null)" == "$ENGINE_VERSION" ]] \
    && print -r -- "$ENGINE_SHA" > "$WINE/.sha"
}
# installed: SteamCMD's own record says fully installed (StateFlags 4), or the game came with --from,
# and the exe is there. a cut download is not installed.
installed() {
  [[ -f "$GAME/RoadRash95.exe" ]] || return 1
  [[ -f "$GAME/.from" ]] || grep -q '"StateFlags"[[:space:]]*"4"' "$GAME/steamapps/appmanifest_$APPID.acf" 2>/dev/null
}
# an app this script wrote: the path ends in .app and its bundle id is exactly ours. no other app is ever deleted.
ours() {
  [[ "$1" == *.app && -f "$1/Contents/Info.plist" ]] || return 1
  [[ "$(plutil -extract CFBundleIdentifier raw -o - "$1/Contents/Info.plist" 2>/dev/null)" == "$BUNDLE_ID" ]]
}
# ours, and its launcher starts this folder
mine() { ours "$1" && grep -qF -e "${(qq)ROOT}/carnival.sh" -e "\"$ROOT/carnival.sh\"" "$1/Contents/MacOS/roadrash" 2>/dev/null; }
# the folder holds a CARNIVAL install, or nothing yet. a folder of other files is never filled or emptied.
our_folder() { [[ -f "$ROOT/.consent" || ! -e "$ROOT" || -z "$(ls -A "$ROOT" 2>/dev/null)" ]]; }

# one value from a registry file: the file, the key as Wine writes it, the value name
regval() {
  K="[$2]" V="\"$3\"=" awk 'index(tolower($0), tolower(ENVIRON["K"])) == 1 { s = 1; next }
    /^\[/ { s = 0 } s && index($0, ENVIRON["V"]) == 1 { print substr($0, length(ENVIRON["V"]) + 1); exit }' "$1" 2>/dev/null | tr -d '\r'
}
# the Windows folder's settings, read back from its registry files. no wine needed.
winver() { regval "$PFX/system.reg" 'Software\\Microsoft\\Windows NT\\CurrentVersion' CurrentVersion | cut -d'"' -f2; }
renderer() { regval "$PFX/user.reg" 'Software\\Wine\\Direct3D' renderer | cut -d'"' -f2; }
ea_entry() { [[ "$(regval "$PFX/system.reg" 'Software\\Wow6432Node\\Electronic Arts\\RoadRash 95' path)" == '"C:\\Games\\RoadRash"' ]]; }
settings_ok() { [[ "$(renderer)" == gdi && "$(winver)" == 6.1 ]] && ea_entry; }

# SteamCMD, with its home in the folder
steamcmd() {
  [[ -x "$CMD/steamcmd.sh" ]] || stop "SteamCMD · missing"
  mkdir -p "$STEAMHOME" && (cd "$CMD" && HOME="$STEAMHOME" ./steamcmd.sh "$@")
}

fetch() { # url sha file
  curl -fL --proto '=https' --progress-bar -o "$3" "$1" || stop "download · failed · $1"
  [[ "$(shasum -a 256 "$3" | cut -d' ' -f1)" == "$2" ]] || stop "checksum · $1"
}

reg_import() {
  local f="$PFX/drive_c/cw.reg"
  printf 'REGEDIT4\r\n\r\n%s\r\n' "$1" > "$f"
  w regedit /S 'C:\cw.reg'
  rm -f "$f"
}

# replaces a folder with a new one. never under a running game.
swap() { # new old
  game_running && stop "game running"
  rm -rf "$2" || stop "folder · $2"
  [[ ! -e "$2" ]] || stop "folder · $2"
  mv "$1" "$2" || stop "folder · $2"
}

consent() {
  our_folder || stop "other folder · $ROOT"
  local fp="$(consent_fp)" c i
  c="$(cat "$ROOT/.consent" 2>/dev/null)"
  # Rosetta is not in the fingerprint, so a Mac without it always sees the list
  [[ -n "$fp" && "${c%% *}" == "$fp" ]] && rosetta && return
  say "downloads"
  rosetta || say "  Rosetta 2 · Apple · Apple software licence"
  for (( i = 1; i < ${#ROWS}; i += 2 )); do
    say "  ${ROWS[i]}"
    say "    ${ROWS[i+1]}"
  done
  [[ -n "$FROM" ]] && say "  game files · copied from · $FROM"
  say "folders"
  say "  $ROOT"
  say "  $APPDIR"
  ask "go" || stop "declined"
  mkdir -p "$ROOT" && print -r -- "$fp $(date '+%Y-%m-%d %H:%M')" > "$ROOT/.consent" || stop "folder · $ROOT"
}

tools() {
  if ! rosetta; then
    id -Gn | tr ' ' '\n' | grep -qx admin || stop "Rosetta 2 · admin"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license || stop "Rosetta 2 · failed"
  fi
  adopt
  if ! libs_ok; then
    say "libraries"
    local t="$ROOT/tmp_template"
    rm -rf "$t" && mkdir -p "$t"
    fetch "$TEMPLATE_URL" "$TEMPLATE_SHA" "$t/t.tar.xz"
    tar -xf "$t/t.tar.xz" -C "$t" || stop "libraries · unpack"
    local fw=("$t"/*.app/Contents/Frameworks(N))
    (( ${#fw} == 1 )) || stop "libraries · unpack"
    swap "$fw[1]" "$FW"
    print -r -- "$TEMPLATE_SHA" > "$FW/.sha"
    rm -rf "$t"
  fi
  if ! engine_ok; then
    say "engine"
    local t="$ROOT/tmp_engine"
    rm -rf "$t" && mkdir -p "$t"
    fetch "$ENGINE_URL" "$ENGINE_SHA" "$t/e.tar.xz"
    tar -xf "$t/e.tar.xz" -C "$t" || stop "engine · unpack"
    [[ -d "$t/wswine.bundle" ]] || stop "engine · unpack"
    swap "$t/wswine.bundle" "$WINE"
    print -r -- "$ENGINE_SHA" > "$WINE/.sha"
    rm -rf "$t"
  fi
  if [[ ! -x "$CMD/steamcmd.sh" ]]; then
    say "SteamCMD"
    local t="$ROOT/tmp_steamcmd"
    rm -rf "$t" && mkdir -p "$t"
    curl -fsSL --proto '=https' -o "$t/s.tar.gz" "$STEAMCMD_URL" || stop "SteamCMD · download"
    tar -xzf "$t/s.tar.gz" -C "$t" || stop "SteamCMD · unpack"
    rm -f "$t/s.tar.gz"
    [[ -x "$t/steamcmd.sh" ]] || stop "SteamCMD · unpack"
    rm -rf "$CMD" && mv "$t" "$CMD" || stop "folder · $CMD"
    steamcmd +quit >/dev/null 2>&1
  fi
}

prefix() {
  tuned && return
  say "Windows folder"
  wine_env
  mkdir -p "$PFX"
  WINEDLLOVERRIDES="mscoree,mshtml=" w wineboot -u || stop "Windows folder · wineboot"
  w winecfg -v win7
  # DirectDraw through OpenGL shows black on macOS 27. gdi draws in software.
  reg_import '[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"renderer"="gdi"'
  # the entry Steam's own install script would write
  reg_import '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\Electronic Arts\RoadRash 95]
"path"="C:\\Games\\RoadRash"
"language"="English"'
  "$WINE/bin/wineserver" -w
  # all three settings are read back. if one is missing, no marker is written and the next run tries again.
  settings_ok || stop "Windows folder · $(renderer) · $(winver)"
  local f="$(tune_fp)"
  [[ -n "$f" ]] && print -r -- "$f" > "$PFX/.tuned"
}

# the game from the person's own copy: a game folder, or a whole CARNIVAL folder from another Mac
game_from() {
  local src=""
  if [[ -f "$FROM/RoadRash95.exe" ]]; then src="$FROM"
  elif [[ -f "$FROM/prefix/drive_c/Games/RoadRash/RoadRash95.exe" ]]; then src="$FROM/prefix/drive_c/Games/RoadRash"
  else stop "from · $FROM"; fi
  src="${src:A}"
  [[ "$src" -ef "$GAME" ]] && stop "from · $FROM"
  say "game · from · $src"
  mkdir -p "$GAME:h"
  rm -rf "$GAME"
  # a clone on the same disk is instant. from another disk it is a copy.
  cp -cR "$src/" "$GAME" 2>/dev/null || { rm -rf "$GAME"; ditto "$src" "$GAME"; } || stop "from · copy"
  rm -rf "$GAME/steamapps/downloading" "$GAME/steamapps/temp"
  print -r -- "$src · $(date '+%Y-%m-%d %H:%M')" > "$GAME/.from"
  installed || stop "game · not installed"
}

game() { # $1 = force
  installed && [[ "${1:-}" != force ]] && return
  game_running && stop "game running"
  if [[ -n "$FROM" && "${1:-}" != force ]]; then game_from; return; fi
  say "game · Steam sign-in · $STORE"
  local u r; read "u?Steam sign-in name: "
  steamcmd +@sSteamCmdForcePlatformType windows \
    +force_install_dir "$GAME" +login "$u" +app_update $APPID validate +quit
  r=$?
  # a failed sign-in leaves the old record at fully installed, so SteamCMD's own exit code counts too
  (( r == 0 )) && installed || stop "game · not installed · SteamCMD $r"
  rm -f "$GAME/.from"
}

app_free() {
  [[ "$APPDIR" == *.app ]] || stop "app path · $APPDIR"
  [[ -e "$APPDIR" ]] && ! ours "$APPDIR" && stop "other app · $APPDIR"
  return 0
}

app() {
  say "app"
  app_free
  [[ "$SELF" -ef "$ROOT/carnival.sh" ]] || cp "$SELF" "$ROOT/carnival.sh" || stop "script · copy"
  chmod +x "$ROOT/carnival.sh"
  rm -rf "$APPDIR" && mkdir -p "$APPDIR/Contents/MacOS" || stop "app · $APPDIR"
  # the app carries the folder, so an install in another folder still finds its game
  cat > "$APPDIR/Contents/MacOS/roadrash" <<EOF || stop "app · $APPDIR"
#!/bin/zsh
export CARNIVAL_ROOT=${(qq)ROOT}
exec ${(qq)ROOT}/carnival.sh play
EOF
  chmod +x "$APPDIR/Contents/MacOS/roadrash"
  cat > "$APPDIR/Contents/Info.plist" <<EOF || stop "app · $APPDIR"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Road Rash</string>
<key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
<key>CFBundleExecutable</key><string>roadrash</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleIconFile</key><string>icon</string>
<key>LSUIElement</key><true/>
</dict></plist>
EOF
  mine "$APPDIR" && [[ -x "$APPDIR/Contents/MacOS/roadrash" ]] || stop "app · $APPDIR"
  icon
  # an app this script wrote in the old place goes. the same folder under another name is not the old place.
  if [[ ! "$OLDAPP" -ef "$APPDIR" ]] && ours "$OLDAPP"; then
    rm -rf "$OLDAPP"
  fi
}

# the icon comes from the person's own game files. the repo holds no icon.
# /usr/bin/python3 is only Apple's stub: without developer tools it opens an install window.
# so the real python3 is found through xcode-select, and a Mac without one skips the icon.
icon() {
  local py="${SELF:h}/icon.py" t="$ROOT/tmp_icon" dev
  [[ -f "$py" && ! "$py" -ef "$ROOT/icon.py" ]] && cp "$py" "$ROOT/icon.py" 2>/dev/null
  dev="$(xcode-select -p 2>/dev/null)"
  [[ -n "$dev" && -x "$dev/usr/bin/python3" && ! "$dev/usr/bin/python3" -ef /usr/bin/python3 && -f "$ROOT/icon.py" ]] \
    || { say "icon · skipped"; return; }
  rm -rf "$t" && mkdir -p "$t" "$APPDIR/Contents/Resources"
  "$dev/usr/bin/python3" -I "$ROOT/icon.py" png "$GAME/RoadRash95.exe" "$t/i.png" 2>/dev/null \
    && sips -p 512 512 "$t/i.png" --out "$t/i512.png" >/dev/null 2>&1 \
    && sips -s format icns "$t/i512.png" --out "$APPDIR/Contents/Resources/icon.icns" >/dev/null 2>&1 \
    || say "icon · skipped"
  rm -rf "$t"
  touch "$APPDIR"
}

play() {
  # a second click while the game runs changes nothing, the log included
  game_running && exit 0
  # from the app there is no Terminal. the output goes to play.log, so a failed start leaves a record.
  [[ -t 1 || ! -d "$ROOT" ]] || exec >"$ROOT/play.log" 2>&1
  [[ -f "$GAME/RoadRash95.exe" ]] || stop "not installed"
  wine_env
  cd "$GAME" && exec "$WINE/bin/wine" RoadRash95.exe
}

# read only. changes nothing.
check() {
  row() { print -- "${(r:18:)1} $2"; }
  yn() { [[ $1 -eq 0 ]] && print yes || print no; }
  row "folder" "$ROOT"
  libs_ok; row "libraries" "$(yn $?)"
  engine_ok; row "engine" "$(yn $?) · $(cat "$WINE/version" 2>/dev/null)"
  [[ -x "$CMD/steamcmd.sh" ]]; row "SteamCMD" "$(yn $?)"
  tuned; row "Windows folder" "$(yn $?)"
  # 6.1 is Windows 7 · 6.3 is Windows 10
  row "Windows version" "$(winver)"
  row "renderer" "$(renderer)"
  ea_entry; row "registry entry" "$(yn $?)"
  installed; row "game files" "$(yn $?)$([[ -f "$GAME/.from" ]] && print ' · from a copy')"
  mine "$APPDIR"; row "app" "$(yn $?) · $APPDIR"
  game_running; row "game running" "$(yn $?)"
}

# deletes only what this script made. other files in the folder stay, and then the folder stays too.
remove() {
  [[ -n "$ROOT" && "${ROOT:A}" != "${HOME:A}" && "${ROOT:A}" != / ]] || stop "folder · $ROOT"
  local f=0 apps=() a
  [[ -f "$ROOT/.consent" ]] && f=1
  mine "$APPDIR" && apps+=("$APPDIR")
  [[ ! "$OLDAPP" -ef "$APPDIR" ]] && mine "$OLDAPP" && apps+=("$OLDAPP")
  (( f || ${#apps} )) || stop "other folder · $ROOT"
  (( f )) && say "$ROOT"
  for a in "${apps[@]}"; do say "$a"; done
  ask "delete" || stop "declined"
  game_running && stop "game running"
  for a in "${apps[@]}"; do rm -rf "$a"; done
  if (( f )); then
    rm -rf "$ROOT"/{Frameworks,wine,prefix,steamcmd,steamhome,tmp_template,tmp_engine,tmp_steamcmd,tmp_icon,carnival.sh,icon.py,play.log,.consent,.DS_Store}
    rmdir "$ROOT" 2>/dev/null
  fi
  say "removed"
}

all() {
  apple_silicon || stop "not Apple silicon"
  # the flow can replace the engine and it rewrites the app, so it does not run under a game
  game_running && stop "game running"
  app_free
  consent
  tools
  prefix
  game
  app
  say "done · $APPDIR"
  open "$APPDIR"
}

if [[ "${1:-}" == --from ]]; then
  [[ -n "${2:-}" ]] || stop "from · folder"
  FROM="${2:a}"
  shift 2
fi
case "${1:-all}" in
  all|play|check|remove) "${1:-all}" ;;
  update) game force ;;
  *) say "use: ./carnival.sh [--from FOLDER] [play | update | check | remove]" ;;
esac

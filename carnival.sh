#!/bin/zsh
# CARNIVAL · Road Rash 30th Anniversary Edition (Steam, Windows) on an Apple silicon Mac
# MIT · LICENSES/MIT.txt · written by Claude (AI) on Nevil Hitesh's ask · 19 nov 2026
# use: double-click CARNIVAL.command, or
#      ./carnival.sh            one flow: tools, game, app, play
#      ./carnival.sh play | update | check | remove

set -u
SELF="${0:A}"

ROOT="${CARNIVAL_ROOT:-$HOME/.carnival}"
# the app goes in /Applications. a Mac user who cannot write there gets ~/Applications.
OLDAPP="$HOME/Applications/Road Rash.app"
if [[ -n "${CARNIVAL_APP:-}" ]]; then APPDIR="$CARNIVAL_APP"
elif [[ -w /Applications ]]; then APPDIR="/Applications/Road Rash.app"
else APPDIR="$OLDAPP"; fi
FW="$ROOT/Frameworks"
WINE="$ROOT/wine"
PFX="$ROOT/prefix"
CMD="$ROOT/steamcmd"
GAME="$PFX/drive_c/Games/RoadRash"
APPID=2448570
STORE="https://store.steampowered.com/app/$APPID/"

ENGINE_URL="https://github.com/Sikarugir-App/Engines/releases/download/v1.0/WS12WineCX24.0.7_7.tar.xz"
ENGINE_SHA="203f9e9fd6c2cc77e6525d798a434ced326145db34a356355e05659d3445fd1c"
TEMPLATE_URL="https://github.com/Sikarugir-App/Template/releases/download/v1.0/Template-1.0.27.tar.xz"
TEMPLATE_SHA="dd0778f7b553d63df9b0f4e2cda3f3c6c005aabb75588c84d604afe80cdedbb9"
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz"

say() { print -- "$1"; }
stop() { print -- "stopped · $1"; exit 1; }
ask() { local a; read "a?$1 · y/n: "; [[ "$a" == y* ]]; }

# every wine call needs these. without them wine crashes or cannot load its libraries.
wine_env() {
  export WINEPREFIX="$PFX"
  export DYLD_FALLBACK_LIBRARY_PATH="$FW:$WINE/lib"
  export WINEMSYNC=1 WINEESYNC=1 WINEDEBUG=-all
}
w() { "$WINE/bin/wine" "$@"; }
# reads the program name only. a shell line that holds the name does not count.
game_running() { ps -axo comm= | grep -q 'RoadRash95\.exe$'; }

fetch() { # url sha file
  curl -fL --proto '=https' --progress-bar -o "$3" "$1" || stop "download failed · $1"
  [[ "$(shasum -a 256 "$3" | cut -d' ' -f1)" == "$2" ]] || stop "checksum does not match · $1"
}

reg_import() {
  local f="$PFX/drive_c/cw.reg"
  printf 'REGEDIT4\r\n\r\n%s\r\n' "$1" > "$f"
  w regedit /S 'C:\cw.reg'
  rm -f "$f"
}

consent() {
  [[ -f "$ROOT/.consent" ]] && return
  say "downloads"
  arch -x86_64 /usr/bin/true 2>/dev/null || say "  Rosetta 2 · Apple · Apple software licence"
  say "  Wine engine WS12WineCX24.0.7_7 · Wine project, CodeWeavers, Sikarugir-App · LGPL-2.1 · 172 MB"
  say "    $ENGINE_URL"
  say "  libraries from Sikarugir Template 1.0.27 · Sikarugir-App · 96 MB"
  say "    $TEMPLATE_URL"
  say "  SteamCMD · Valve · Steam Subscriber Agreement"
  say "    $STEAMCMD_URL"
  say "  Road Rash 30th Anniversary Edition · Electronic Arts · your own Steam copy · 3.4 GB"
  say "    $STORE"
  say "folders"
  say "  $ROOT"
  say "  $APPDIR"
  ask "go" || stop "no downloads made"
  mkdir -p "$ROOT" && date "+%Y-%m-%d %H:%M" > "$ROOT/.consent"
}

tools() {
  if ! arch -x86_64 /usr/bin/true 2>/dev/null; then
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license || stop "Rosetta 2 install failed"
  fi
  if [[ ! -d "$FW" ]]; then
    say "libraries"
    local t="$ROOT/tmp_template"
    rm -rf "$t" && mkdir -p "$t"
    fetch "$TEMPLATE_URL" "$TEMPLATE_SHA" "$t/t.tar.xz"
    tar -xf "$t/t.tar.xz" -C "$t" || stop "template unpack failed"
    mv "$t"/*.app/Contents/Frameworks "$FW" || stop "no Frameworks in the template"
    rm -rf "$t"
  fi
  if [[ ! -x "$WINE/bin/wine" ]]; then
    say "engine"
    local t="$ROOT/tmp_engine"
    rm -rf "$t" && mkdir -p "$t"
    fetch "$ENGINE_URL" "$ENGINE_SHA" "$t/e.tar.xz"
    tar -xf "$t/e.tar.xz" -C "$t" || stop "engine unpack failed"
    mv "$t/wswine.bundle" "$WINE" || stop "no wine in the engine"
    rm -rf "$t"
  fi
  if [[ ! -x "$CMD/steamcmd.sh" ]]; then
    say "SteamCMD"
    mkdir -p "$CMD"
    curl -fsSL --proto '=https' -o "$CMD/s.tar.gz" "$STEAMCMD_URL" || stop "SteamCMD download failed"
    tar -xzf "$CMD/s.tar.gz" -C "$CMD" && rm -f "$CMD/s.tar.gz"
    (cd "$CMD" && ./steamcmd.sh +quit >/dev/null 2>&1)
  fi
}

prefix() {
  [[ -f "$PFX/.tuned" ]] && return
  say "Windows folder"
  wine_env
  mkdir -p "$PFX"
  WINEDLLOVERRIDES="mscoree,mshtml=" w wineboot -u || stop "wineboot failed"
  w winecfg -v win7
  # DirectDraw through OpenGL shows black on macOS 27. gdi draws in software.
  reg_import '[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"renderer"="gdi"'
  # the entry Steam's own install script would write
  reg_import '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\Electronic Arts\RoadRash 95]
"path"="C:\\Games\\RoadRash"
"language"="English"'
  "$WINE/bin/wineserver" -w
  grep -q '"renderer"="gdi"' "$PFX/user.reg" || stop "the registry did not take the settings"
  touch "$PFX/.tuned"
}

game() { # $1 = force
  [[ -f "$GAME/RoadRash95.exe" && "${1:-}" != force ]] && return
  game_running && stop "quit the game first"
  say "game · Steam sign-in · the account must own the game · $STORE"
  local u; read "u?Steam sign-in name: "
  (cd "$CMD" && ./steamcmd.sh +@sSteamCmdForcePlatformType windows \
    +force_install_dir "$GAME" +login "$u" +app_update $APPID validate +quit)
  [[ -f "$GAME/RoadRash95.exe" ]] || stop "the game did not download"
}

app() {
  say "app"
  [[ "$SELF" == "$ROOT/carnival.sh" ]] || cp "$SELF" "$ROOT/carnival.sh" || stop "could not copy the script"
  chmod +x "$ROOT/carnival.sh"
  rm -rf "$APPDIR"
  mkdir -p "$APPDIR/Contents/MacOS"
  cat > "$APPDIR/Contents/MacOS/roadrash" <<EOF
#!/bin/zsh
exec "$ROOT/carnival.sh" play
EOF
  chmod +x "$APPDIR/Contents/MacOS/roadrash"
  cat > "$APPDIR/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Road Rash</string>
<key>CFBundleIdentifier</key><string>local.carnival.roadrash</string>
<key>CFBundleExecutable</key><string>roadrash</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleIconFile</key><string>icon</string>
<key>LSUIElement</key><true/>
</dict></plist>
EOF
  icon
  # an app this script wrote in the old place goes. no other app is touched.
  if [[ "$OLDAPP" != "$APPDIR" ]] && grep -q 'local.carnival.roadrash' "$OLDAPP/Contents/Info.plist" 2>/dev/null; then
    rm -rf "$OLDAPP"
  fi
}

# the icon comes from the person's own game files. the repo holds no icon.
icon() {
  local py="${SELF:h}/icon.py" t="$ROOT/tmp_icon"
  [[ -f "$py" ]] && cp "$py" "$ROOT/icon.py" 2>/dev/null
  [[ -x /usr/bin/python3 && -f "$ROOT/icon.py" ]] || { say "icon · skipped"; return; }
  rm -rf "$t" && mkdir -p "$t" "$APPDIR/Contents/Resources"
  /usr/bin/python3 "$ROOT/icon.py" png "$GAME/RoadRash95.exe" "$t/i.png" 2>/dev/null \
    && sips -p 512 512 "$t/i.png" --out "$t/i512.png" >/dev/null 2>&1 \
    && sips -s format icns "$t/i512.png" --out "$APPDIR/Contents/Resources/icon.icns" >/dev/null 2>&1 \
    || say "icon · skipped"
  rm -rf "$t"
  touch "$APPDIR"
}

play() {
  [[ -f "$GAME/RoadRash95.exe" ]] || stop "not installed · run ./carnival.sh"
  game_running && exit 0
  wine_env
  cd "$GAME" && exec "$WINE/bin/wine" RoadRash95.exe >/dev/null 2>&1
}

# read only. changes nothing.
check() {
  row() { print -- "${(r:18:)1} $2"; }
  yn() { [[ $1 -eq 0 ]] && print yes || print no; }
  row "folder" "$ROOT"
  [[ -d "$FW" ]]; row "libraries" "$(yn $?)"
  [[ -x "$WINE/bin/wine" ]]; row "engine" "$(yn $?) · $(cat "$WINE/version" 2>/dev/null)"
  [[ -x "$CMD/steamcmd.sh" ]]; row "SteamCMD" "$(yn $?)"
  [[ -f "$PFX/.tuned" ]]; row "Windows folder" "$(yn $?)"
  # 6.1 is Windows 7 · 6.3 is Windows 10
  row "Windows version" "$(grep -A12 -i '^\[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\] ' "$PFX/system.reg" 2>/dev/null | grep -m1 '^"CurrentVersion"=' | cut -d'"' -f4)"
  row "renderer" "$(grep -m1 '^"renderer"=' "$PFX/user.reg" 2>/dev/null | cut -d'"' -f4)"
  grep -qi 'Electronic Arts\\\\RoadRash 95' "$PFX/system.reg" 2>/dev/null; row "registry entry" "$(yn $?)"
  [[ -f "$GAME/RoadRash95.exe" ]]; row "game files" "$(yn $?)"
  [[ -x "$APPDIR/Contents/MacOS/roadrash" ]]; row "app" "$(yn $?) · $APPDIR"
  game_running; row "game running" "$(yn $?)"
}

remove() {
  [[ -n "$ROOT" && "$ROOT" != "$HOME" && "$ROOT" != "/" ]] || stop "bad folder"
  say "$ROOT"
  say "$APPDIR"
  ask "delete both" || stop "nothing deleted"
  game_running && stop "quit the game first"
  rm -rf "$ROOT" "$APPDIR"
  say "removed"
}

all() {
  [[ "$(uname -m)" == arm64 ]] || stop "needs an Apple silicon Mac"
  consent
  tools
  prefix
  game
  app
  say "done · $APPDIR"
  open "$APPDIR"
}

case "${1:-all}" in
  all|play|check|remove) "${1:-all}" ;;
  update) game force ;;
  *) say "use: ./carnival.sh [play | update | check | remove]" ;;
esac

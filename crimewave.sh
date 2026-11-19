#!/bin/zsh
# crimewave · Road Rash 30th Anniversary Edition (Steam, Windows) on an Apple silicon Mac
# MIT · LICENSES/MIT.txt · written by Claude (AI) on Nevil Hitesh's ask · 19 nov 2026
# use: ./crimewave.sh tools | tune | game | play | check

set -u

NAME="${CRIMEWAVE_WRAPPER:-crimewave}"
APP="$HOME/Applications/Sikarugir/$NAME.app"
C="$APP/Contents"
S="$C/SharedSupport"
PFX="$S/prefix"
STEAM="$PFX/drive_c/Program Files (x86)/Steam"
GAME="$STEAM/steamapps/common/RoadRash"
CMD="$HOME/steamcmd"
APPID=2448570
STORE="https://store.steampowered.com/app/$APPID/"
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz"
STEAMSETUP_URL="https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"

ask() { local a; read "a?$1 · y/n: "; [[ "$a" == y* ]]; }
stop() { print -- "stopped · $1"; exit 1; }

# every wine call needs these four. without them wine crashes or cannot load its libraries.
wine_env() {
  export WINEPREFIX="$PFX"
  export DYLD_FALLBACK_LIBRARY_PATH="$C/Frameworks:$S/wine/lib"
  export WINEMSYNC=1 WINEESYNC=1 WINEDEBUG=-all
}
w() { "$S/wine/bin/wine" "$@"; }

need_wrapper() { [[ -d "$PFX" ]] || stop "no wrapper at $APP"; }
wine_running() { pgrep -f "$NAME.app/Contents/SharedSupport/wine" >/dev/null; }
steam_running() { pgrep -f 'Steam\\steam.exe' >/dev/null; }

# import registry text into the wrapper
reg_import() {
  local f="$PFX/drive_c/cw.reg"
  printf 'REGEDIT4\r\n\r\n%s\r\n' "$1" > "$f"
  w regedit /S 'C:\cw.reg'
  sleep 4
  rm -f "$f"
}

set_program() {
  /usr/libexec/PlistBuddy -c "Set :'Program Name and Path' '/Program Files (x86)/Steam/steam.exe'" "$C/Info.plist"
}

# 1 · the tools. each download asks first.
tools() {
  [[ "$(uname -m)" == arm64 ]] || stop "needs an Apple silicon Mac"
  command -v brew >/dev/null || stop "needs Homebrew · https://brew.sh"

  if ! arch -x86_64 /usr/bin/true 2>/dev/null; then
    ask "Rosetta 2 · Apple · accepts Apple's software licence" || stop "Rosetta 2 is needed"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi

  if [[ ! -d "/Applications/Sikarugir Creator.app" ]]; then
    ask "Sikarugir Creator · Homebrew cask Sikarugir-App/sikarugir · the cask removes the macOS quarantine flag from it" || stop "Sikarugir is needed"
    brew trust Sikarugir-App/sikarugir 2>/dev/null
    brew install --cask Sikarugir-App/sikarugir/sikarugir || stop "Sikarugir install failed"
  fi

  if [[ ! -x "$CMD/steamcmd.sh" ]]; then
    ask "SteamCMD · Valve · Steam Subscriber Agreement · $STEAMCMD_URL" || stop "SteamCMD is needed"
    mkdir -p "$CMD"
    curl -fsSL --proto '=https' -o "$CMD/steamcmd_osx.tar.gz" "$STEAMCMD_URL" || stop "SteamCMD download failed"
    tar -xzf "$CMD/steamcmd_osx.tar.gz" -C "$CMD"
    (cd "$CMD" && ./steamcmd.sh +quit)
  fi

  if [[ ! -f "$HOME/Downloads/SteamSetup.exe" ]]; then
    ask "Steam for Windows installer · Valve · Steam Subscriber Agreement · $STEAMSETUP_URL" || stop "the Steam installer is needed"
    curl -fL --proto '=https' -o "$HOME/Downloads/SteamSetup.exe" "$STEAMSETUP_URL" || stop "Steam installer download failed"
  fi

  print -- "the game · $STORE"
  ask "open the Steam store page in the browser" && open "$STORE"
  print -- "tools · done · next: README step 2"
}

# 3 · the wrapper settings. Steam and the wrapper must be closed.
tune() {
  need_wrapper
  wine_running && stop "close Steam and the wrapper first"
  wine_env
  w winecfg -v win7
  reg_import '[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"renderer"="gdi"'
  "$S/wine/bin/wineserver" -w
  codesign --force --deep -s - "$C/Configure.app"
  print -- "tune · done · Windows 7 · renderer gdi · Configure.app signed"
  open "$C/Configure.app"
}

# 5 · the game files. Steam must be closed. you type your own Steam login.
game() {
  need_wrapper
  [[ -f "$STEAM/steam.exe" ]] || stop "Steam is not installed in the wrapper"
  [[ -x "$CMD/steamcmd.sh" ]] || stop "SteamCMD is missing · run tools"
  wine_running && stop "close Steam and the wrapper first"

  local u; read "u?Steam sign-in name: "
  (cd "$CMD" && ./steamcmd.sh +@sSteamCmdForcePlatformType windows \
    +force_install_dir "$GAME" +login "$u" +app_update $APPID validate +quit)
  [[ -f "$GAME/RoadRash95.exe" ]] || stop "the download did not finish"

  # hand the install record to the Steam inside the wrapper
  local acf="$GAME/steamapps/appmanifest_$APPID.acf"
  if [[ -f "$acf" ]]; then
    mkdir -p "$STEAM/steamapps"
    awk '{print} /"Universe"/{print "\t\"LauncherPath\"\t\t\"C:\\\\Program Files (x86)\\\\Steam\\\\steam.exe\""}' \
      "$acf" > "$STEAM/steamapps/appmanifest_$APPID.acf"
    mv "$GAME/steamapps" "$CMD/leftover_steamapps_$(date +%s)"
  fi

  # the entry Steam's own install script would write
  wine_env
  reg_import '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\Electronic Arts\RoadRash 95]
"path"="C:\\Program Files (x86)\\Steam\\steamapps\\common\\RoadRash"
"language"="English"'
  "$S/wine/bin/wineserver" -w

  print -- $APPID > "$GAME/steam_appid.txt"
  set_program
  print -- "game · done · next: ./crimewave.sh play"
}

# 6 · start Steam if needed, then the game
play() {
  need_wrapper
  [[ -f "$GAME/RoadRash95.exe" ]] || stop "the game is not installed · run game"
  if ! steam_running; then
    rm -f "$STEAM/.crash"
    open "$APP"
    for i in {1..60}; do pgrep -f 'steamwebhelper.exe' >/dev/null && break; sleep 2; done
    sleep 15
  fi
  pgrep -f 'RoadRash95.exe' >/dev/null && exit 0
  wine_env
  cd "$GAME" && w RoadRash95.exe >/dev/null 2>&1 &
}

# read only. changes nothing.
check() {
  row() { print -- "${(r:22:)1} $2"; }
  yn() { [[ $1 -eq 0 ]] && print yes || print no; }
  [[ -d "$PFX" ]]; row "wrapper" "$(yn $?) · $APP"
  [[ -d "$PFX" ]] || return
  # 6.1 is Windows 7 · 10.0 is Windows 10
  row "Windows version" "$(grep -A12 -i '^\[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\] ' "$PFX/system.reg" 2>/dev/null | grep -m1 '^"CurrentVersion"=' | cut -d'"' -f4)"
  row "renderer" "$(grep -m1 '^"renderer"=' "$PFX/user.reg" 2>/dev/null | cut -d'"' -f4)"
  codesign --verify --deep --strict "$C/Configure.app" 2>/dev/null; row "Configure.app signed" "$(yn $?)"
  [[ -f "$STEAM/steam.exe" ]]; row "Steam installed" "$(yn $?)"
  [[ -f "$GAME/RoadRash95.exe" ]]; row "game files" "$(yn $?)"
  row "install record" "$(grep -m1 StateFlags "$STEAM/steamapps/appmanifest_$APPID.acf" 2>/dev/null | cut -d'"' -f4)"
  grep -qi 'Electronic Arts\\\\RoadRash 95' "$PFX/system.reg" 2>/dev/null; row "registry entry" "$(yn $?)"
  [[ -x "$CMD/steamcmd.sh" ]]; row "SteamCMD" "$(yn $?)"
  steam_running; row "Steam running" "$(yn $?)"
}

case "${1:-}" in
  tools|tune|game|play|check) "$1" ;;
  *) print -- "use: ./crimewave.sh tools | tune | game | play | check" ;;
esac

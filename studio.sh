#!/bin/bash

export WINEPREFIX="${HOME}/.local/share/invison_studio"

INVISION_INSTALLER_NAME="invision_setup-1.20.0.exe"
INVISON_SETUP="${WINEPREFIX}/${INVISION_INSTALLER_NAME}"
INVISION_DL_URL="https://projects.invisionapp.com/studio/releases/download/windows/"
INVISION_RUN_CMD="${WINEPREFIX}/drive_c/users/${USER}/AppData/Local/Invision Studio/studio.exe"

WINE_RESOLUTION="${WINE_RESOLUTION:-1920x1080}"
WINE="/app/bin/wine"

XORG_LOG="/var/log/Xorg.0.log"

VERSION_NUM="1.20.0"
VERSION_FILE="${WINEPREFIX}/com.invisionapp.Studio.version"

declare -ra WINE_PACKAGES=(directx9 usp10 msls31 corefonts tahoma win7 dotnet46)
declare -ra WINE_SETTINGS=('csmt=on' 'glsl=disabled')

echo "########################################################"
echo "## Invision Studio Unofficial Flatpak v${VERSION_NUM} ##"
echo "########################################################"
echo

# Set video memory by checking xorg
set_video_memory(){
  if [[ ! -z "${VIDEO_MEMORY}" ]]; then
    echo "Using explicitly set VMEM of ${VIDEO_MEMORY}"
  elif  [ -f "${XORG_LOG}" ]; then

    # Get Video Memory from Xorg logs
    local xorg_vmem
    xorg_vmem="$(sed -rn 's/.*memory: ([0-9]*).*kbytes/\1/gpI' ${XORG_LOG})"

    if [[ ! -z "${xorg_vmem}" ]]; then
        VIDEO_MEMORY=$((${xorg_vmem} / 1024))
        echo "Setting video memory to ${VIDEO_MEMORY}"
    else
      echo "Unable to find video memory in ${XORG_LOG}."
      echo "Leaving video card memory at default settings."
      echo "To set value explicitly, set the VIDEO_MEMORY environment variable"
      return 1
    fi

  else
    echo "Unable to read Xorg logs from ${XORG_LOG}."
    echo "Leaving video card memory at default settings."
    return 1
  fi

      tmpfile=$(mktemp VideoMemory.XXXXX.reg)

      cat <<EOF > "${tmpfile}"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\\Software\\Wine\\Direct3D]
"VideoMemorySize"="${VIDEO_MEMORY}"

EOF

  "${WINE}" regedit "${tmpfile}" >/dev/null 2>&1
  rm "${tmpfile}"
  return 0
}

set_wine_settings(){
  local my_documents="${WINEPREFIX}/drive_c/users/${USER}/My Documents"

  echo "Installing wine requirements."
  winetricks --unattended "${WINE_PACKAGES[@]}"

  echo "Setting wine settings."
  winetricks --unattended "${WINE_SETTINGS[@]}"

  # Symlink points to wrong location, fix it
  if [[ "$(readlink "${my_documents}")" != "${XDG_DOCUMENTS_DIR}" ]]; then
    echo "Setting game directory to ${XDG_DOCUMENTS_DIR}"
    mv "${my_documents}" "${my_documents}.bak.$(date +%F)"
    ln -s "${XDG_DOCUMENTS_DIR}" "${my_documents}"
  fi

  echo
}

# Run only if Invision Studio isn't installed
first_run(){
  set_wine_settings

  echo "${VERSION_NUM}" > "${VERSION_FILE}"

  if [ ! -f "${INVISON_SETUP}" ]; then
    echo "Downloading Invision Studio installer."
    wget -O "${INVISION_SETUP}" "${INVISION_DL_URL}"
  fi
  echo "Running Invision Studio installer."
  "${WINE}" "${INVISION_SETUP}"
}

is_updated(){
  if [ -f "${VERSION_FILE}" ]; then
    last_version="$(cat ${VERSION_FILE})"
  else
    last_version="0"
  fi

  echo "${VERSION_NUM}" > "${VERSION_FILE}"

  if [[ "${VERSION_NUM}" == "${last_version}" ]]; then
    return 0
  else
    return 1
  fi
}

# Main function
startup(){

  set_video_memory

  if [ ! -d "${WINEPREFIX}/drive_c/users/${USER}/AppData/Local/Invision Studio" ]; then
     echo "Ruh roh! Invision Studio is not installed."
     first_run
 else
   if ! is_updated; then
     echo "Looks like we're not up to date. Re-running Wine Settings."
     set_wine_settings
     fi
 fi


  echo "Setting resolution to ${WINE_RESOLUTION}"
  echo "If resolution was changed from default, game may need restarting"
  winetricks --unattended vd="${WINE_RESOLUTION}" >/dev/null

  echo ; echo "Starting Path of Exile..."
  "${WINE}" "${POE_RUN_CMD}" dbox  -no-dwrite -noasync
}

startup
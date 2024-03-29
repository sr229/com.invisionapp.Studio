#!/bin/sh

export WINEPREFIX="${HOME}/.local/share/invison_studio"

INVISION_INSTALLER_NAME="invision_setup-1.20.0.exe"
INVISON_SETUP="${WINEPREFIX}/${INVISION_INSTALLER_NAME}"
INVISION_DL_URL="https://projects.invisionapp.com/studio/releases/download/windows/"
INVISION_RUN_CMD="${WINEPREFIX}/drive_c/users/${USER}/AppData/Local/Invision Studio/studio.exe"

VERSION_NUM="1.20.0"
VERSION_FILE="${WINEPREFIX}/com.invisionapp.Studio.version"

echo "########################################################"
echo "## Invision Studio Unofficial Flatpak v${VERSION_NUM} ##############"
echo "########################################################"
echo

set_wine_settings() {
  my_documents="${WINEPREFIX}/drive_c/users/${USER}/My Documents"

  echo "WORKAROUND: set registry for dotnet452"
  wine reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\Version" /v 6.1.7601.17592 /t REG_SZ /d "foo" /f

  echo "Installing wine requirements."
  winetricks --force -q  directx9 usp10 msls31 corefonts tahoma dotnet452 vcrun2015 winxp

  # Switch back to Windows 10 - Invision only supports Windows 10
  winetricks -q win10

  # Symlink points to wrong location, fix it
  if [[ "$(readlink "${my_documents}")" != "${XDG_DOCUMENTS_DIR}" ]]; then
    echo "Setting game directory to ${XDG_DOCUMENTS_DIR}"
    mv "${my_documents}" "${my_documents}.bak.$(date +%F)"
    ln -s "${XDG_DOCUMENTS_DIR}" "${my_documents}"
  fi

  echo
}

# Run only if Invision Studio isn't installed
first_run() {
  set_wine_settings

  echo "${VERSION_NUM}" > "${VERSION_FILE}"

  if [ ! -f "${INVISON_SETUP}" ]; then
    echo "Downloading Invision Studio installer."
    wget -O "${INVISION_SETUP}" "${INVISION_DL_URL}"
  fi
  echo "Running Invision Studio installer."
  wine runas /trustlevel:0x20000 "${INVISION_SETUP}"
}

is_updated() {
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
startup() {

  if [ ! -d "${WINEPREFIX}/drive_c/users/${USER}/AppData/Local/Invision Studio" ]; then
     echo "Ruh roh! Invision Studio is not installed."
     first_run
 else
   if ! is_updated; then
     echo "Looks like we're not up to date. Re-running Wine Settings."
     set_wine_settings
     fi
 fi

  echo ; echo "Starting Invision Studio..."
  wine "${INVISION_RUN_CMD}"
}

startup

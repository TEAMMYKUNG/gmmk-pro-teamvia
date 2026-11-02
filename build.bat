@echo off
REM One-step build for GMMK Pro rev1 ANSI teamvia keymap.
REM Needs: git + Docker Desktop. No QMK MSYS, no toolchain install.
set FW=%~dp0qmk_firmware
if not exist "%FW%" (
  echo Cloning QMK firmware...
  git clone --depth 1 --branch master https://github.com/qmk/qmk_firmware.git "%FW%"
  git -C "%FW%" submodule update --init --depth 1
)
if not exist "%FW%\modules\getreuer" (
  echo Cloning community modules (PaletteFx)...
  git clone --depth 1 https://github.com/getreuer/qmk-modules.git "%FW%\modules\getreuer"
)
echo Copying keymap...
if not exist "%FW%\keyboards\gmmk\pro\rev1\ansi\keymaps\teamvia" mkdir "%FW%\keyboards\gmmk\pro\rev1\ansi\keymaps\teamvia"
copy /Y "%~dp0keymap\keymap.c" "%FW%\keyboards\gmmk\pro\rev1\ansi\keymaps\teamvia\" >nul
copy /Y "%~dp0keymap\rules.mk" "%FW%\keyboards\gmmk\pro\rev1\ansi\keymaps\teamvia\" >nul
copy /Y "%~dp0keymap\config.h" "%FW%\keyboards\gmmk\pro\rev1\ansi\keymaps\teamvia\" >nul
copy /Y "%~dp0keymap\keymap.json" "%FW%\keyboards\gmmk\pro\rev1\ansi\keymaps\teamvia\" >nul
echo Compiling via Docker...
docker run --rm -v "%FW%:/qmk_firmware" -w /qmk_firmware qmkfm/qmk_cli qmk compile -kb gmmk/pro/rev1/ansi -km teamvia
copy /Y "%FW%\gmmk_pro_rev1_ansi_teamvia.bin" "%~dp0firmware\" >nul
echo Done. Firmware: firmware\gmmk_pro_rev1_ansi_teamvia.bin

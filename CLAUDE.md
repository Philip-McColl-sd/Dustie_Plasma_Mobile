# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A documentation project plus one installer: how to get KDE Plasma Mobile running on a Raspberry Pi 4B. There's no build, no package manifest and no test suite. The only executable code is `scripts/setup.sh`, and it targets the Pi (Raspberry Pi OS 64-bit Lite, aarch64, Debian-based), not this dev machine (Windows/WSL). Don't run it locally: it modifies `/etc`, sudoers, SDDM config and system QML files, then offers to reboot.

The core idea behind the project: Raspberry Pi OS is Debian-based, and Debian ships `plasma-mobile` packages. Ubuntu, Manjaro ARM, Mobian and postmarketOS were all tried and rejected (the reasons are in `README.md` / `docs/README.md`). Don't suggest switching base distros.

## The live device

The Pi is `halley`, reachable by key-based SSH from WSL: `ssh stardust@192.168.1.138` (`halley.local` mDNS does **not** resolve from WSL2). It runs Debian 13 Trixie (the docs were first written for Bookworm). Read-only inspection over SSH is fine. Changes to root-owned files on the Pi (sudoers, `/usr/local/bin`, SDDM config) get blocked by the auto-mode classifier, so hand the user a script to run instead. Restarting `sddm` or rebooting kills the user's session and the SSH link. When the Pi and `setup.sh` disagree, the Pi is the tested truth: sync the script to match it.

## Checking changes

- Syntax check only: `bash -n scripts/setup.sh` (`shellcheck scripts/setup.sh` if it's installed).
- Real verification means running it on a Pi 4. The script's own Step 11 checks the result (package installed, SDDM present, `graphical.target`, autologin conf, Switch Session button).

## Line endings (important)

The repo is on `/mnt/c` under WSL. Committed files are LF, and `.gitattributes` enforces that. Windows editors can still save CRLF, which makes `git status` show files as modified with no real change (check with `git diff --ignore-cr-at-eol`). A CRLF `setup.sh` breaks when run on the Pi. Don't commit changes that are only line endings.

## How `scripts/setup.sh` is built

It runs as numbered, banner-separated steps (`log_info`/`log_success`/`log_warning`/`error_exit` helpers, `set -e`, must run as a non-root user with sudo). Steps that interact with each other:

- **IPv6 disabled and apt forced to IPv4** (`-o Acquire::ForceIPv4=true` on every install). Project docs treat this as critical for downloads to succeed, so keep it on any new `apt-get` calls.
- **Step 8, lock screen as login:** `/etc/sddm.conf.d/autologin.conf` autologins `plasma-mobile.desktop` with `Relogin=true`. Then `~/.config/autostart/lock-on-login.desktop` runs `loginctl lock-session` about 2s after login, so the user always authenticates on the Plasma Mobile lock screen instead of the SDDM greeter.
- **Step 9, "Switch Session" button:** it builds on Step 8 and overwrites a system file, `/usr/share/plasma/look-and-feel/org.kde.breeze.mobile/contents/logout/Logout.qml` (a `.backup` is kept), from an inline heredoc. The button runs `/usr/local/bin/plasma-mobile-disable-autologin-once.sh` through a passwordless sudoers rule (`/etc/sudoers.d/plasma-mobile-switch-session`, checked with `visudo -c`). That script moves `autologin.conf` into `/root/sddm-conf-backup/` and schedules `systemctl restart sddm`, and only after that does the QML log out. On the next login, the autostart entry runs `lock-and-restore-autologin.sh`, which locks the screen and calls `sudo -n plasma-mobile-restore-autologin.sh` to put the file back. The `[ -f ]` check has to happen inside that root helper because `/root` is mode 700; an earlier inline `Exec=` version also broke because of Desktop Entry quoting. Facts confirmed on hardware, recorded in comments:
  - SDDM still reads a renamed file inside `sddm.conf.d/`, so the file must be moved out of the directory entirely.
  - SDDM caches its config until a full `systemctl restart sddm`.
  - The stock `switchUser()` starts a second Wayland session at the same time as the first, which freezes the Pi's single GPU. That's why the replacement logs out first and starts the new session afterwards.
- Step 9.4 rewrites the `lock-on-login.desktop` written in Step 8, and the sudoers rule lists both helpers. Keep these in sync.
- The undo commands printed at the end of the script must match whatever files Steps 8 and 9 create.

The embedded `Logout.qml` is a modified copy of upstream KDE code (GPL-2.0-or-later SPDX header). Keep the header. Its imports are tied to the installed Plasma Mobile version.

## Docs

- `README.md`: landing page. `docs/README.md`: the full manual guide (Step 8 is the Waveshare SIM7600G-H 4G HAT cellular modem: power-cycle rules, `mmcli` checks, voice call. Data/APN setup is still open). `docs/Installation-Flow-Diagram.md`: troubleshooting flowchart. `docs/Quick-Reference-Card.md`: command cheat sheet.
- The same facts (troubleshooting entries, package list, steps) appear in several of these files and in `setup.sh`. When one changes, update the others. `docs/README.md` has a dated Changelog section.
- `docs/dual_joystick.md` (two KY-023 joysticks over an ADS1118 SPI ADC) and `docs/Get-some-shit-working.md` (casual post-install notes: screenfetch, Brave, Flatpak) are side notes. The Python files that `dual_joystick.md` refers to (`ads1118.py`, `quick_test.py`, etc.) are not in this repo.
- The GitHub repo is `Philip-McColl-sd/Dustie_Plasma_Mobile`; install URLs use `https://raw.githubusercontent.com/Philip-McColl-sd/Dustie_Plasma_Mobile/main/scripts/setup.sh`.
- `setup.sh` has to work when piped through `curl | bash`, so every `read` reads from `< /dev/tty`.
- License: CC BY-SA 4.0.

#!/bin/bash
#
# Copyright 2017, Evan Klitzke <evan@eklitzke.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -eux

BUCKET=
GPGRECIPIENT=
BACKUPFILE=
BACKUPNAME=wallet.dat.gpg

usage() {
  echo "Usage: $0 -b BUCKET -u GPGRECIPIENT"
  exit
}

while getopts ":hb:u:f:" opt; do
  case $opt in
    h)
      usage
      ;;
    b)
      BUCKET="$OPTARG"
      ;;
    u)
      GPGRECIPIENT="$OPTARG"
      ;;
    f)
      BACKUPFILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ -z "$BUCKET" ]; then
  echo "Missing -b option!"
  usage
fi

if [ -z "$GPGRECIPIENT" ]; then
  echo "Missing -u option!"
  usage
fi

if [ -z "$BACKUPFILE" ]; then
  BACKUPFILE=$(mktemp /tmp/wallet-XXXXXX.dat)
fi

GPGBACKUP="${BACKUPFILE}.gpg"

# In normal operation this will be a no-op.
cleanup() {
  rm -f "$BACKUPFILE" "$GPGBACKUP"
}
trap cleanup EXIT

# Create a backup file. Note that this file will have permissions 600, so it is
# OK if it is in /tmp.
bitcoin-cli backupwallet "$BACKUPFILE"

# Encrypt the backup.
test -f "$GPGBACKUP" && rm -f "$GPGBACKUP"
gpg -r "$GPGRECIPIENT" -e "$BACKUPFILE"

# Move the backup to the cloud.
gsutil -q mv "$GPGBACKUP" "${BUCKET%/}"/"${BACKUPNAME}"

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

set -eu

BUCKET=
DATADIR="$HOME/.bitcoin/"
GPGRECIPIENT=
BACKUPFILE=
BACKUPNAME=wallet.dat.gpg
QUIET=0

usage() {
  echo "Usage: $0 [-q] [-d DATADIR] -b BUCKET -u GPGRECIPIENT"
  exit
}

while getopts ":hqb:d:u:f:" opt; do
  case $opt in
    h)
      usage
      ;;
    q)
      QUIET=1
      ;;
    b)
      BUCKET="$OPTARG"
      ;;
    d)
      DATADIR="$OPTARG"
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

# Normalize the data directory name.
DATADIR="${DATADIR%/}"

# In normal operation this will be a no-op.
cleanup() {
  rm -f "$BACKUPFILE" "$GPGBACKUP"
}
trap cleanup EXIT

# If a .cookie file exists, we use RPC to back up the wallet.
if [ -r "${DATADIR}/.cookie" ]; then
  bitcoin-cli backupwallet "$BACKUPFILE"
else
  install -m 600 "${DATADIR}/wallet.dat" "$BACKUPFILE"
fi

# Encrypt the backup.
test -f "$GPGBACKUP" && rm -f "$GPGBACKUP"
gpg -r "$GPGRECIPIENT" -e "$BACKUPFILE"

GSLOCATION="${BUCKET%/}"/"${BACKUPNAME}"

# Move the backup to the cloud.
gsutil -q mv "$GPGBACKUP" "$GSLOCATION"

# Echo where the file was saved to.
if [ "$QUIET" -eq 0 ]; then
  echo "$GSLOCATION"
fi

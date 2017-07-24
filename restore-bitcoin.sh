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
BACKUPNAME=wallet.dat.gpg

usage() {
  echo "Usage: $0 [-q] [-d DATADIR] -b BUCKET"
  exit
}

while getopts ":hb:d:" opt; do
  case $opt in
    h)
      usage
      ;;
    b)
      BUCKET="$OPTARG"
      ;;
    d)
      DATADIR="$OPTARG"
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

GSLOCATION="${BUCKET%/}"/"${BACKUPNAME}"

pushd "${DATADIR}" &>/dev/null
gsutil -q cp "${GSLOCATION}" .
gpg -d "${BACKUPNAME}" > wallet.dat
chmod 600 wallet.dat
rm -f "${BACKUPNAME}"
popd &>/dev/null

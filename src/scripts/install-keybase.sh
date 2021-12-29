#!/usr/bin/env -S bash -e

WORK_DIR=/tmp
if [[ ! -f ${WORK_DIR}/keybase_amd64.deb ]] ; then
  (cd ${WORK_DIR} && curl --silent --remote-name https://prerelease.keybase.io/keybase_amd64.deb)
fi
ar -p ${WORK_DIR}/keybase_amd64.deb data.tar.xz | 
  xz --decompress | 
  sudo tar -C / --strip-components 1 -xf - ./usr/bin/keybase ./usr/lib/systemd/user/keybase.service 
rm ${WORK_DIR}/keybase_amd64.deb

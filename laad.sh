#!/bin/bash

# check the distro's code name && arch
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS=$NAME
  VER=$PRETTY_NAME
  echo "os : $OS"
  echo "version : $VER"
fi

# check required packages
req_pkgs=(curl gnupg apt-transport-https)
for req_pkg in "${req_pkgs[@]}"; do
  if [ dpkg -s $req_pkg ]; then
    echo "required package $req_pkg found!"
  else
    echo "required package $req_pkg not found! Installing ..."
    apt install $req_pkg
  fi
done

# add contrib, non-free, CISOfy, NodeJS, atom.io && slack repositories
contrib_non_free="contrib non-free"
ciso_repo_gpg="https://packages.cisofy.com/keys/cisofy-software-public.key | apt-key add -"
ciso_repo="deb https://packages.cisofy.com/community/lynis/deb/ stable main"
nodejs_8_repo="https://deb.nodesource.com/setup_8.x | bash -"
nodejs_9_repo="https://deb.nodesource.com/setup_9.x | bash -"
atom_repo_gpg="https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add -"
atom_repo="deb https://packagecloud.io/AtomEditor/atom/any/ any main"
slacktechnologies_repo_gpg="https://packagecloud.io/slacktechnologies/slack/gpgkey | apt-key add -"
slacktechnologies_repo="deb https://packagecloud.io/slacktechnologies/slack/debian/ jessie main"

if [ -f /etc/apt/sources.list -eq 0 ]; then
  # explore file and if string notpresent; then add repo
  echo "enter in add repo condition"
  if [ grep "contrib non-free" /etc/apt/sources.list ]; then
    #statements contrib non-free
    echo "'contrib' && 'non-free' repositories found!"
  else
    sed -i '/buster/ s/$/ "${contrib_non_free}"/' /etc/apt/sources.list
  fi

  if [ grep "cisofy" /etc/apt/sources.list ]; then
    echo "CISOfy repository found!"
  else
    curl -sL "${ciso_repo_gpg}" &> /dev/null
    echo "${ciso_repo}" >> /etc/apt/sources.list
  fi

  if [ grep "AtomEditor" /etc/apt/sources.list ]; then
    echo "Atom.io repository found!"
  else
    curl -sL "${atom_repo_gpg}" &> /dev/null
    echo "${atom_repo}" >> /etc/apt/sources.list
  fi

  if [ grep "slacktechnologies" /etc/apt/sources.list ]; then
    echo "Slack Technologies repository found!"
  else
    curl -sL "${slacktechnologies_repo_gpg}" &> /dev/null
    echo "${slacktechnologies_repo}" >> /etc/apt/sources.list
  fi

else
  echo "file 'sources.list' in '/etc/apt/' directory not found! exiting script!"
  exit 1
fi

exit $?

# updating repositories
if [ -eq 0 ]; then
  apt update
fi

exit $?

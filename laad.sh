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
  if [[ `dpkg -s $req_pkg` ]]; then
    echo "required package $req_pkg found!"
  else
    echo "required package $req_pkg not found! Installing ..."
    apt install -y $req_pkg
  fi
done

# add contrib, non-free, CISOfy, NodeJS, atom.io && slack repositories
contrib_non_free="contrib non-free"
ciso_repo_gpg="https://packages.cisofy.com/keys/cisofy-software-public.key"
ciso_repo="deb https://packages.cisofy.com/community/lynis/deb/ stable main"
nodejs_8_repo="https://deb.nodesource.com/setup_8.x"
nodejs_9_repo="https://deb.nodesource.com/setup_9.x"
nodejs_repo_version="node -v"
atom_repo_gpg="https://packagecloud.io/AtomEditor/atom/gpgkey"
atom_repo="deb https://packagecloud.io/AtomEditor/atom/any/ any main"
slacktechnologies_repo_gpg="https://packagecloud.io/slacktechnologies/slack/gpgkey"
slacktechnologies_repo="deb https://packagecloud.io/slacktechnologies/slack/debian/ jessie main"

if [[ -f /etc/apt/sources.list ]]; then
  # explore file and if string notpresent; then add repo
  echo "enter in add repo condition"
  if [[ `grep 'contrib non-free' /etc/apt/sources.list` ]]; then
    #statements contrib non-free
    echo "contrib && non-free repositories found!"
  else
    echo "'contrib' && 'non-free' repositories not found! Adding ..."
    sed -i "/buster/ s/$/ $contrib_non_free/" /etc/apt/sources.list
  fi

  if [[ `grep 'cisofy' /etc/apt/sources.list` ]]; then
    echo "CISOfy repository found!"
  else
    echo "CISOfy repository not found! Adding ..."
    curl -sL $ciso_repo_gpg | apt-key add - &> /dev/null
    echo $ciso_repo >> /etc/apt/sources.list
  fi

  if [[ `grep 'AtomEditor' /etc/apt/sources.list` ]]; then
    echo "Atom.io repository found!"
  else
    echo "Atom.io repository not found! Adding ..."
    curl -sL $atom_repo_gpg | apt-key add - &> /dev/null
    echo $atom_repo >> /etc/apt/sources.list
  fi

  if [[ `grep 'slacktechnologies' /etc/apt/sources.list` ]]; then
    echo "Slack Technologies repository found!"
  else
    echo "Slack Technologies repository not found! Adding ..."
    curl -sL $slacktechnologies_repo_gpg | apt-key add - &> /dev/null
    echo $slacktechnologies_repo >> /etc/apt/sources.list
  fi

  if [[ -f /etc/apt/sources.list.d/nodesource.list ]]; then
    echo "NodeJS repository found!"
  else
    echo "NodeJS repository not found! Adding ..."
    printf "Which version do you want to use? [8.x/9.x] : "
    read -r node_version
    case $node_version in
      "8.x" )
        curl -sL $nodejs_8_repo | bash - &> /dev/null
        ;;
      "9.x" )
        curl -sL $nodejs_9_repo | bash - &> /dev/null
        ;;
      *)
        echo "Nothing was selected ..."
        ;;
    esac
    echo "NodeJS repository added! version is : $node_version"
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

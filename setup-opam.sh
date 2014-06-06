#!/usr/bin/env bash
set -ex

. /vagrant/local-settings

# Initialize the .opam and .bashrc PATH
if [ -d ~/.opam ]; then
    opam update
elif [ -n "$DEFAULT_REPO" ]; then
    opam init -a -y
    opam repo add local ~/opam-repository
else
    opam init -a -y local ~/opam-repository
fi

# Configure a .ocamlinit
cat >> ~/.ocamlinit <<EOF
#use "topfind";;
#thread;;
#camlp4o;;
EOF

eval $(opam config env)

if [ -n "$ALLPKGS" ]; then
    export OPAMCRITERIA="-notuptodate,+new"
fi

if [ ${#PACKAGES[@]} -eq 0 ]; then
    OPAMCMD=upgrade
else
    OPAMCMD=install
fi

depext=($(opam $OPAMCMD "${PACKAGES[@]}" -e ubuntu))
echo Ubuntu depexts: ${depext[@]}
if [ ${#depext[@]} -ne 0 ]; then
  sudo apt-get install -qq -y build-essential m4
  sudo apt-get install -qq -y "${depext[@]}"
fi

opam $OPAMCMD -y "${PACKAGES[@]}"

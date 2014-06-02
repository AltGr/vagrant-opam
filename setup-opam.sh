#!/usr/bin/env bash
set -ex

. /vagrant/local-settings

# Initialize the .opam and .bashrc PATH
opam init -a -y local ~/opam-repository

# Configure an .ocamlinit
cat >> ~/.ocamlinit <<EOF
#use "topfind";;
#thread;;
#camlp4o;;
EOF

eval $(opam config env)

depext=($(opam install "${PACKAGES[@]}" -e ubuntu))
echo Ubuntu depexts: ${depext[@]}
if [ ${#depext[@]} -ne 0 ]; then
  sudo apt-get install -qq -y build-essential m4
  sudo apt-get install -qq -y "${depext[@]}"
fi

opam install -y "${PACKAGES[@]}"

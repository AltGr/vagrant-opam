#!/usr/bin/env bash
set -e

. /vagrant/local-settings

eval $(opam config env)

# Generate OPAM doc in ~/.opam/doc/doc
eval `opam config env`
opam doc -n ${PACKAGES}

# Add extra clauses to .ocamlinit for new packages
cat >> ~/.ocamlinit <<EOF
#require "core.top";;
#require "core.syntax";;
EOF

# Start web server for docs
sudo service nginx start

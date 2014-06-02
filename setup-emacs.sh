#!/usr/bin/env bash
set -ex

. /vagrant/local-settings
eval $(opam config env)

export OPAMYES=1
opam install ocp-index ocp-indent

ln -s /vagrant/ocaml-emacs-settings/.emacs ~
ln -s /vagrant/ocaml-emacs-settings/.emacs.d/ ~

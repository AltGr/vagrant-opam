#!/bin/bash -ue

help () {
    cat <<EOF
Prepare a configuration for building a VM using Vagrant.
Arguments: --locale LOC --[no-]color PACKAGES...

Run before doing 'vagrant create'
EOF
}

LOCALE=C
NOCOLOR=
PACKAGES=()
MAX_PACKAGES=
DEFAULT_REPO=1

while [ $# -gt 0 ]; do
    case $1 in
        --locale)
            shift; if [ $# -eq 0 ]; then help; exit 1; fi
            LOCALE=$1
            ;;
        --no-color) NOCOLOR=1;;
        --color) NOCOLOR=;;
        --max) MAX_PACKAGES=1;;
        --no-default-repo) DEFAULT_REPO=;;
        -*) help; exit 1;;
        *) PACKAGES+=("$1")
    esac
    shift
done

if [ ${#PACKAGES[@]} -eq 0 ]; then
    PACKAGES=(opam-doc merlin utop cohttp js_of_ocaml oasis)
    PACKAGES+=(ssl core_extended async js_of_ocaml core_bench cohttp cryptokit menhir)
fi

if [ -n "$MAX_PACKAGES" ]; then
    export OPAMCRITERIA="-notuptodate,+new"
fi

echo "Will include packages ${PACKAGES[@]}"

cat <<EOF >local-settings
LOCALE=$LOCALE
NOCOLOR=$NOCOLOR
PACKAGES=(${PACKAGES[@]})
ALLPKGS=$MAX_PACKAGES
DEFAULT_REPO=$DEFAULT_REPO
EOF

cleanup-repo () {
    # Removes from the opam-repository all packages which don't have archives
    echo "Available packages in the local repo:"
    for f in packages/*/*; do
        pkg=${f##*/}
        dir=${f%/*}
        if [ -e "archives/${pkg}+opam.tar.gz" ] || [ ! -e "$f/url" ]; then
            echo -n "${pkg} "
        else
            rm -rf "$f"
            rmdir --ignore-fail-on-non-empty ${dir}
        fi
    done
    echo
}

prepare-repo () {
    if [ ! -d opam-repository ]; then
        git clone https://github.com/ocaml/opam-repository
        cd opam-repository
    else
        cd opam-repository
        git reset --hard
        #git clean -fdx
        git pull
    fi
    opam-admin make --resolve ${PACKAGES[@]}
    cleanup-repo
    cd ..
}


prepare-repo
if [ ! -d ocaml-emacs-settings ]; then
    git clone https://github.com/samoht/ocaml-emacs-settings.git
else
    cd ocaml-emacs-settings
    git pull
    cd ..
fi

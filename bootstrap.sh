#!/usr/bin/env bash
set -ue

. /vagrant/local-settings

if [ ! -e "/swapfile" ]; then
    dd if=/dev/zero of=/swapfile bs=1024 count=1048576
    /sbin/mkswap /swapfile
    /sbin/swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi

for v in LANGUAGE LANG LC_ALL; do
    export $v=$LOCALE
done
if ! grep LANGUAGE /etc/profile.d/set_locale; then
    echo "export LANGUAGE=$LANGUAGE" >>/etc/profile.d/set_locale
    echo "export LANG=$LANG" >>/etc/profile.d/set_locale
    echo "export LC_ALL=$LC_ALL" >>/etc/profile.d/set_locale
fi

if [ "$LOCALE" != "C" ]; then
    locale-gen "$LOCALE"
    dpkg-reconfigure locales
fi

apt-get update
apt-get install -y python-software-properties build-essential m4
add-apt-repository ppa:avsm/ppa
apt-get update
apt-get install -y ocaml ocaml-native-compilers camlp4 camlp4-extra opam git libssl-dev emacs vim nginx tuareg-mode auto-complete-el aspcud
sed -i -e 's,/usr/share/nginx/html,/home/vagrant/.opam/doc/doc,g' /etc/nginx/sites-available/default

color () {
  if [ -n "$NOCOLOR" ]; then
    sed 's/%.//g'
  else
    sed 's/%%//g; s/%y/[33;1m/g; s/%o/[0;33m/g; s/%b/[m/g'
  fi
}
color > /etc/motd.tail <<'EOF'
%y     %%  %%  %%  %%    ,,__
%y     %%..%%  %%..%%   / o._)%% %y  ___   ____                _
%y    /%o--%y'/%o--%y\  \-'|%o|  %y / _ \ / ___|__ _ _ __ ___ | |
%y   / %%  %%  %%  %% \_/ / %o|  %y| | | | |   / _` | '_ ` _ \| |
%y .'\ %% \%o__%y\  __.'%o.'%%   %y| |_| | |__| (_| | | | | | | |
%y   %o)%y\ |  %o)%y\ |%%        %y \___/ \____\__,_|_| |_| |_|_|
%y  %o//%y \\ %o//%y \\
%y %o||_%y  \\%o|_%y  \\_%%    %o-- two humps are better than one
%y %o'--'%y '--'%o'%y '--'%b

Run 'utop' to get started with an interactive console.
Documentation is available at http://localhost:8000/
EOF

run-parts /etc/update-motd.d/

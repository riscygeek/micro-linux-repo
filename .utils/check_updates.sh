#!/usr/bin/env bash

export LC_ALL=C

pacman_pkgs="$(pacman -Sl core extra community | awk '!/lib32/{print $2, $3}')"

getver() {
   local ver
   ver="$(sed -n "/^$1 /s/^$1 //p" <<< "$pacman_pkgs"    \
      | sed -e 's/^[0-9]\+://'                           \
            -e 's/-[0-9]\+$//')"

   # Special rules for some packages.
   case "$1" in
   vim|bash|readline)
      awk -F'.' '{printf "%s.%s\n", $1, $2}' <<<"$ver"
      ;;
   mpfr)
      awk -F'.' '{printf "%s.%s.%s\n", $1, $2, $3}' <<<"$ver"
      ;;
   libtool)
      sed 's/+.*$//' <<<"$ver"
      ;;
   iana-etc)
      curl 'https://github.com/Mic92/iana-etc/releases/latest' 2>/dev/null \
         | sed 's@^.*releases/tag/\([^"]\+\)".*$@\1@'
      ;;

   *)
      echo "$ver"
      ;;
   esac
}

ec=0
for dir in $(find -maxdepth 1 -type d -not -iname '.*'); do
   [[ $dir/package.build ]] || continue
   both="$(source "$dir/package.build" && echo "$pkgname:$pkgver")"
   pkgname="$(cut -d':' -f1 <<< "$both")"
   pkgver="$(cut -d':' -f2 <<< "$both")"

   pacman_ver="$(getver "$pkgname")"
   [[ -z $pacman_ver && $pkgname == lib* ]] && pacman_ver="$(getver "${pkgname/lib/}")"

   [[ $pacman_ver && $pacman_ver > $pkgver ]] && ec=1 && echo "$pkgname : $pkgver -> $pacman_ver"
done

exit "$ec"

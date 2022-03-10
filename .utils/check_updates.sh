#!/usr/bin/env bash

export LC_ALL=C

for dir in $(find -maxdepth 1 -type d -not -iname '.*'); do
   [[ $dir/package.build ]] || continue
   both="$(source "$dir/package.build" && echo "$pkgname:$pkgver")"
   pkgname="$(cut -d':' -f1 <<< "$both")"
   pkgver="$(cut -d':' -f2 <<< "$both")"
   pacman_ver="$(pacman -Qi "$pkgname" 2>/dev/null | sed -n '/^Version/s/^[^.]\+:\s//p')"
   pacman_ver="$(sed 's/^[^:]://;s/-[0-9]\+$//;s/+.*$//' <<< "$pacman_ver")"

   [[ $pacman_ver > $pkgver ]] && echo "$pkgname : $pkgver -> $pacman_ver"
done

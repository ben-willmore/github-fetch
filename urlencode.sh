#!/bin/bash

urlencode () {
  proto=$(echo "$1" | grep :// | sed -e's,^\(.*://\).*,\1,g')
  printf "${proto}"
  url="$(echo ${1/$proto/})"
  local l=${#url}
  for (( i = 0 ; i < l ; i++ )); do
    local c=${url:i:1}
    case "$c" in
      [a-zA-Z0-9.~_-]) printf "$c" ;;
      '/') printf / ;;
      ' ') printf + ;;
      *) printf '%%%.2X' "'$c"
    esac
  done
}

urldecode () {
  local data=${1//+/ }
  printf '%b' "${data//%/\\x}"
}

encoded=$(urlencode https://github.com/ben-willmore/portm!@aster)
decoded=$(urldecode $encoded)

echo $encoded
echo $decoded

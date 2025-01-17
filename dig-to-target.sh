#!/bin/bash

github_api () {
  cache_filename=$(echo $1 | tr  '/' '-') 
  if [[ -f "${cache_filename}" ]]; then
    echo found in cache: $1 >&2
    res=$(cat "${cache_filename}")
  else
    echo saving to cache: $1 >&2
    res=$(wget -qO- $1)
    echo $res > "${cache_filename}"
  fi
  code=$?

  n_api_calls=$((n_api_calls+1))
  echo $res
  exit $code
}

dig_to_target () {
    # $1 root API URL for the repo
    # $2 path of target
    # return API URL for target
    url=$1
    last_url=

    bits=$(echo "${2}" | tr '/' '\n')
    echo bits -- $bits

    to_match=
    while IFS= read -r bit; do
      if [[ ${url} != ${last_url} ]]; then
        res="$(github_api $url)"
        if [[ $? != 0 ]]; then
          raise_api_error "API call failed" $1 >&2
        fi
        last_url="${url}"
      fi
      echo b:$bit==
      bit=$(echo "${bit}" | tr -d '\n')
      to_match+="${bit}"
      echo un:--$to_match--
      echo bit:--$bit--
      url=$(echo $res | jq --arg x "${to_match}" -r '.tree[] | select(.path==$x) | .url' 2>/dev/null)
      echo tu:"$url"
      if [[ -z "${url}" ]]; then
        echo "Couldn't find path ${to_match}"
        to_match+='/'
      else
        echo "Found path ${to_match}"
        to_match=
      fi

    done <<< "${bits}"

    echo "${url}"
}

dig_to_target "https://api.github.com/repos/ben-willmore/github-fetch/git/trees/main" "test/subdir/subdir/subdir/subdir"

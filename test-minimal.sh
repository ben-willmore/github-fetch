#!/bin/bash

# need to git clone here to make sure checkout has right version of repo
# add tests for:
# * unicode chars like tilde-n
# * permissions (including directory permissions?)
# * symlinks, files within a symlinked dir
# * the remaining special chars -- *, ...?

ignore_api_limit=false
#cache_flag=
cache_flag='--test'

urldecode () {
  local data=${1//+/ }
  printf '%b' "${data//%/\\x}"
}

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

md5file () {
    md5sum "${1}" | awk '{print $1}'
}

md5dir () {
  find "${1}" -type f -exec md5sum {} + | awk '{print $1}' | sort | md5sum | awk '{print $1}'
}

setup () {
  echo == Test: $1
  rm -rf "${test_dir}"
  mkdir -p "${test_dir}"
  cd "${test_dir}"
}

test_file () {
  if [[ ! -f "${1}" ]] || [[ ! -f "${2}" ]] || [[ $(md5file "${1}") != $(md5file "${2}") ]]; then
    echo Fail
    exit 1
  fi
}

test_dir () {
  if [[ ! -d "${1}" ]] || [[ ! -d "${2}" ]] || [[ $(md5dir "${1}") != $(md5dir "${2}") ]]; then
  echo $1 $2
    echo Fail $(md5dir "${1}") $(md5dir "${2}") 
    exit 1
  fi
}

test_fail () {
  if [[ $? == 0 ]]; then
    echo Should have failed and did not
    exit 1
  else
    echo OK -- failure expected
  fi
}

teardown () {
  cd "${root_dir}"
  rm -rf "${test_dir}"
}

git_checkout () {
  (
   cd "${git_dir}"
   git checkout $1
  )
}

initial_setup () {
  github_fetch="$(pwd)/github-fetch $cache_flag --verbose"

  root_dir="$(pwd)"
  test_dir="$(pwd)/test.tmp"
  git_dir="$(pwd)/git.tmp"
  check_dir="$git_dir/test"

  rm -rf "${git_dir}"
  git clone https://github.com/ben-willmore/github-fetch $git_dir

}

final_cleanup () {
  rm -rf ${test_dir}
  rm -rf ${git_dir}
}

initial_setup

setup "Downloading subdir to current directory"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test
test_dir $test_dir/test $check_dir
#teardown

#final_cleanup

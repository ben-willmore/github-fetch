#!/bin/bash

# need to git clone here to make sure checkout has right version of repo
# add tests for:
# * unicode chars like tilde-n
# * permissions (including directory permissions?)
# * symlinks
# * the remaining special chars -- *, ...?

ignore_api_limit=false
clear_cache=false
cache_flag='--test'

urldecode () {
  local data=${1//+/ }
  printf '%b' "${data//%/\\x}"
}

urlencode () {
  proto=$(echo "$1" | grep :// | sed -e's,^\(.*://\).*,\1,g')
  url="$(echo ${1/$proto/})"
  printf "${proto}"
  local l="${#url}"
  for (( i = 0 ; i < l ; i++ )); do
    local c="${url:i:1}"
    case "$c" in
      # / is missing, becaue that would also translate the separators. Probably we should really
      # separate out the bits of the URL and encode each one. I'm not sure it makes a difference
      # unless you can have / in a git filename. Maybe on windows?
      [:?\#\[\]@!$%\&\'\(\)\*\+\,\;={}\ ]) printf '%%%.2X' "'$c" ;;
      *) printf "$c" ;;
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
  if [[ $clear_cache == true ]]; then
    rm -rf cache/
  fi

  github_fetch="$(pwd)/github-fetch --verbose $cache_flag"
  github_fetch_curl_nocache="$(pwd)/github-fetch --verbose --curl"

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

setup "Downloading single file to non-existent directory -- should fail"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three nonexistent_dir
test_fail
teardown

setup "Downloading dir to non-existent directory -- should fail"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test nonexistent_dir
test_fail
teardown

setup "Downloading single file to current directory"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
test_file $test_dir/three $check_dir/subdir/three
teardown

setup "Downloading single file to current directory -- curl"
git_checkout main
$github_fetch_curl_nocache https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
test_file $test_dir/three $check_dir/subdir/three
teardown

setup "Downloading single file to current directory - blocked, should fail"
git_checkout main
touch three
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
test_fail
teardown

setup "Downloading single file to alternate directory"
git_checkout main
mkdir ./alt_dir
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three "./alt_dir"
test_file $test_dir/alt_dir/three $check_dir/subdir/three
teardown

setup "Downloading whole repo to current directory"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch
test_dir $test_dir/github-fetch/test $check_dir
teardown

setup "Downloading whole repo to current directory -- curl"
git_checkout main
$github_fetch_curl_nocache https://github.com/ben-willmore/github-fetch
test_dir $test_dir/github-fetch/test $check_dir
teardown

setup "Downloading subdir to current directory"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test
test_dir $test_dir/test $check_dir
teardown

setup "Downloading subdir to current directory -- curl"
git_checkout main
$github_fetch_curl_nocache https://github.com/ben-willmore/github-fetch/tree/main/test
test_dir $test_dir/test $check_dir
teardown

setup "Downloading subdir to current directory - blocked, should fail"
git_checkout main
touch test
$github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test
test_fail
teardown

setup "Downloading single file to current directory -- alt branch"
git_checkout testbranch
$github_fetch https://github.com/ben-willmore/github-fetch/blob/testbranch/test/subdir/three
test_file $test_dir/three $check_dir/subdir/three
teardown

setup "Downloading subdir to current directory -- alt branch"
git_checkout testbranch
$github_fetch https://github.com/ben-willmore/github-fetch/tree/testbranch/test
test_dir $test_dir/test $check_dir
teardown

setup "Downloading whole repo to current directory -- alt branch"
git_checkout testbranch
$github_fetch https://github.com/ben-willmore/github-fetch/tree/testbranch
test_dir $test_dir/github-fetch/test $check_dir
teardown

setup "Downloading single file to current directory -- specific commit"
git_checkout b705c8521553926a84609816d3f5ed8814945aee
$github_fetch https://github.com/ben-willmore/github-fetch/blob/b705c8521553926a84609816d3f5ed8814945aee/test/sub%20dir/s%20e%20v%20e%20n
test_file "$test_dir/s e v e n" "$check_dir/sub dir/s e v e n"
teardown

setup "Downloading subdir to current directory -- specific commit"
git_checkout b705c8521553926a84609816d3f5ed8814945aee
$github_fetch https://github.com/ben-willmore/github-fetch/tree/b705c8521553926a84609816d3f5ed8814945aee/test
test_dir $test_dir/test $check_dir
teardown

setup "Downloading whole repo to current directory -- specific commit"
git_checkout b705c8521553926a84609816d3f5ed8814945aee
$github_fetch https://github.com/ben-willmore/github-fetch/tree/b705c8521553926a84609816d3f5ed8814945aee
test_dir $test_dir/github-fetch/test $check_dir
teardown

setup "Deep subdirectory"
git_checkout 17defefbffd7b4a09a607e1997fb6602fd169456
$github_fetch https://github.com/ben-willmore/github-fetch/tree/17defefbffd7b4a09a607e1997fb6602fd169456/test/subdir/subdir/subdir/subdir
test_dir $test_dir/subdir $check_dir/subdir/subdir/subdir/subdir
teardown

# download files with special characters individually
base_url="https://github.com/ben-willmore/github-fetch/blob/main/test/special-chars/"
git_checkout main

find $check_dir/special-chars -maxdepth 1 -type f > test.tmpfile
while IFS= read -r file; do
  set -f
  file=$(IFS= basename "${file}")
  url=${base_url}$(IFS= urlencode "${file}")
  set +f
  setup "Downloading file \"${file}\" with special char in filename"
  $github_fetch "${url}"
  test_file "$test_dir/${file}" "$check_dir/special-chars/${file}"
  teardown
done < test.tmpfile
rm test.tmpfile

if [[ 1 == 1 ]]; then #[[ $ignore_api_limit == true ]]; then
  base_url="https://github.com/ben-willmore/github-fetch/tree/main/test/special-chars/dirs/"
  find $check_dir/special-chars/dirs -mindepth 1 -maxdepth 1 -type d > test.tmpfile

  while IFS= read -r dirname; do
    set -f
    dirname=$(IFS= basename "${dirname}")
    url=${base_url}$(IFS= urlencode "${dirname}")
    set +f
    setup "Downloading dir \"${dirname}\" with special char in dirname"
    $github_fetch "${url}"
    test_dir "$test_dir/${dirname}" "$check_dir/special-chars/dirs/${dirname}"
    teardown
  done < test.tmpfile
  rm test.tmpfile

  base_url="https://github.com/ben-willmore/github-fetch/blob/main/test/special-chars/dirs/"
  find $check_dir/special-chars/dirs -mindepth 1 -maxdepth 1 -type d > test.tmpfile

  while IFS= read -r dirname; do
    set -f
    dirname=$(IFS= basename "${dirname}")
    url=${base_url}$(IFS= urlencode "${dirname}")/testfile
    set +f
    setup "Downloading file from \"${dirname}\" with special char in dirname"
    $github_fetch "${url}"
    test_file "$test_dir/testfile" "$check_dir/special-chars/dirs/${dirname}/testfile"
    teardown
  done < test.tmpfile
  rm test.tmpfile

fi

final_cleanup

#!/bin/bash

# need to git clone here to make sure checkout has right version of repo
# add tests for:
# * unicode chars like tilde-n
# * permissions (including directory permissions?)
# * symlinks
# * the remaining special chars -- *, ...?

ignore_api_limit=false
cache_flag=
# cache_flag='--test'

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
  github_fetch="$(pwd)/github-fetch $cache_flag"

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

setup "Downloading subdir to current directory"
git_checkout main
$github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test
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

# special chars -- some are missing, such as *
chars='! %22 %23 %24 %25 %26 '"'"' ( ) %2B %2C - %3B %3C %3D %3E %40 %5D _ %60 %7B %7B %7C %7D %7F'

base_url="https://github.com/ben-willmore/github-fetch/blob/main/test/special-chars/"
for char in $chars; do
  initial_setup
  url="${base_url}${char}"
  base=$(basename ${url})
  base=$(urldecode ${base})
  setup "Downloading file with special char \"${base}\" in filename"
  git_checkout main
  $github_fetch "${url}"
  test_file "$test_dir/${base}" "$check_dir/special-chars/${base}"
  teardown
done

if [[ $ignore_api_limit == true ]];; then
  base_url="https://github.com/ben-willmore/github-fetch/tree/main/test/special-chars/dirs/"
  for char in $chars; do
    initial_setup
    url="${base_url}${char}"
    base=$(basename ${url})
    base=$(urldecode ${base})
    setup "Downloading dir with special char \"${base}\" in dirname"
    git_checkout main
    $github_fetch "${url}"
    test_dir "$test_dir/${base}" "$check_dir/special-chars/dirs/${base}"
    teardown
  done

  base_url="https://github.com/ben-willmore/github-fetch/blob/main/test/special-chars/dirs/"
  for char in $chars; do
    initial_setup
    url="${base_url}${char}/testfile"
    base=$(basename ${url})
    base=$(urldecode ${base})
    setup "Downloading file with special char \"${char}\" in dirname"
    git_checkout main
    $github_fetch "${url}"
    cc=$(urldecode "${char}")
    test_file "$test_dir/testfile" "$check_dir/special-chars/dirs/${cc}/testfile"
    teardown
  done
fi

final_cleanup

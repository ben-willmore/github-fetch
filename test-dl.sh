#!/bin/bash

# need to git clone here to make sure checkout has right version of repo
# add tests for:
# different branches, commits, e.g.:
# https://github.com/ben-willmore/PortMaster-New/tree/58e7be051e7b24740d82dd65a4ac837d3d416006/ports/hurrican
# single files with pathological names
# pathological paths as well as final names
# unicode chars like tilde-n
# permissions
# symlinks

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
  if [[ $(md5file "${1}") != $(md5file "${2}") ]]; then
    echo Fail
    exit 1
  fi
}

test_dir () {
  if [[ $(md5dir "${1}") != $(md5dir "${2}") ]]; then
    echo Fail
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

github_fetch="$(pwd)/github-fetch"
echo $github_fetch

root_dir="$(pwd)"
test_dir="$(pwd)/test.tmp"
git_dir="$(pwd)/git.tmp"
check_dir="$git_dir/test"

git clone https://github.com/ben-willmore/github-fetch $git_dir

# setup "Downloading single file to current directory"
# git_checkout main
# $github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
# test_file $test_dir/three $check_dir/subdir/three
# teardown

# setup "Downloading single file to current directory - blocked, should fail"
# git_checkout main
# touch three
# $github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
# test_fail
# teardown

# setup "Downloading single file to alternate directory"
# git_checkout main
# mkdir ./alt_dir
# $github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three "./alt_dir"
# test_file ./alt_dir/three $check_dir/subdir/three
# teardown

# setup "Downloading single file to alternate directory - blocked, should fail"
# git_checkout main
# mkdir ./alt_dir
# touch ./alt_dir/three
# $github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three "./alt_dir"
# test_fail
# teardown

# setup "Downloading whole repo to current directory"
# git_checkout main
# $github_fetch https://github.com/ben-willmore/github-fetch
# test_dir ./github-fetch/test $check_dir
# teardown

# setup "Downloading subdir to current directory"
# git_checkout main
# $github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test
# test_dir ./test $check_dir
# # teardown

# setup "Downloading subdir to current directory - blocked, should fail"
# git_checkout main
# touch test
# $github_fetch https://github.com/ben-willmore/github-fetch/tree/main/test
# test_fail
# teardown

# setup "Downloading single file to current directory -- alt branch"
# git_checkout testbranch
# $github_fetch https://github.com/ben-willmore/github-fetch/blob/testbranch/test/subdir/three
# test_file $test_dir/three $check_dir/subdir/three
# teardown

# setup "Downloading whole repo to current directory -- alt branch"
# git_checkout testbranch
# $github_fetch https://github.com/ben-willmore/github-fetch/tree/testbranch
# test_dir ./github-fetch/test $check_dir
# teardown


#!/bin/bash

# could git clone here to make sure checkout has right version of repo

md5 () {
    md5sum "${1}" | awk '{print $1}'
}

github_fetch="$(pwd)/github-fetch"
echo $github_fetch

root_dir="$(pwd)"
test_dir="$(pwd)/test.tmp"
check_dir="$(pwd)/test"

rm -rf "${test_dir}"

echo "Downloading single file to current directory"
mkdir "${test_dir}"
cd "${test_dir}"
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
if [[ $(md5 $test_dir/three) != $(md5 $check_dir/subdir/three) ]]; then
  echo Fail
  exit 1
fi
cd "${root_dir}"
rm -rf "${test_dir}"

echo "Downloading single file to current directory - should fail"
rm -rf "${test_dir}"
mkdir "${test_dir}"
cd "${test_dir}"
touch three
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three
if [[ $? == 0 ]]; then
  echo Should have failed and did not
  exit 1
fi
cd "${root_dir}"
rm -rf "${test_dir}"

echo "Downloading single file to alternate directory"
rm -rf "${test_dir}"
mkdir "${test_dir}"
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three "${test_dir}"
if [[ $(md5 $test_dir/three) != $(md5 $check_dir/subdir/three) ]]; then
  echo Fail
  exit 1
fi
cd "${root_dir}"
rm -rf "${test_dir}"

echo "Downloading single file to alternate directory - should fail"
rm -rf "${test_dir}"
mkdir "${test_dir}"
touch "${test_dir}/three"
$github_fetch https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/three "${test_dir}"
if [[ $? == 0 ]]; then
  echo Should have failed and did not
  exit 1
fi
cd "${root_dir}"
rm -rf "${test_dir}"

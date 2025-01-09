#!/bin/bash

rm -rf github-fetch-test.tmp
mkdir github-fetch-test.tmp
cd github-fetch-test.tmp

# parse directory (tree) URLs
res=$(../github-fetch -p https://github.com/ben-willmore/github-fetch \
      | tr '\n' ' ' \
      | grep "user=ben-willmore repo=github-fetch type=tree ref= root=")
if [[ -z $res ]]; then
  echo Fail
  exit 1
fi

res=$(../github-fetch -p https://github.com/ben-willmore/github-fetch/tree/testbranch/test \
      | tr '\n' ' ' \
      | grep "user=ben-willmore repo=github-fetch type=tree ref=testbranch root=test")
if [[ -z $res ]]; then
  echo Fail
  exit 1
fi

res=$(../github-fetch -p https://github.com/ben-willmore/github-fetch/tree/aa25db658a2013f8a0004cbdbff3ff59ce3e0aaa/test \
      | tr '\n' ' ' \
      | grep "user=ben-willmore repo=github-fetch type=tree ref=aa25db658a2013f8a0004cbdbff3ff59ce3e0aaa root=test")
if [[ -z $res ]]; then
  echo Fail
  exit 1
fi

res=$(../github-fetch -p https://github.com/ben-willmore/github-fetch/tree/testbranch \
      | tr '\n' ' ' \
      | grep "user=ben-willmore repo=github-fetch type=tree ref=testbranch root=")
if [[ -z $res ]]; then
  echo Fail
  exit 1
fi



# parse file URLs
res=$(../github-fetch -p https://github.com/ben-willmore/github-fetch/blob/main/test/subdir/four \
      | tr '\n' ' ' \
      | grep "user=ben-willmore repo=github-fetch type=blob ref=main root=test/subdir/four")
if [[ -z $res ]]; then
  echo Fail
  exit 1
fi

res=$(../github-fetch -p https://github.com/ben-willmore/github-fetch/blob/b1b69d4039a1f14e20bf092d5d0bcead177ca24b/test/one \
      | tr '\n' ' ' \
      | grep "user=ben-willmore repo=github-fetch type=blob ref=b1b69d4039a1f14e20bf092d5d0bcead177ca24b root=test/one")
if [[ -z $res ]]; then
  echo Fail
  exit 1
fi

# get file
../github-fetch https://github.com/ben-willmore/github-fetch/blob/b1b69d4039a1f14e20bf092d5d0bcead177ca24b/test/one
if [[ -z $(md5sum one | grep 5bbf5a52328e7439ae6e719dfe712200) ]]; then
  echo Fail
  exit 1
fi
rm one

# get file from subdir
../github-fetch https://github.com/ben-willmore/github-fetch/blob/b1b69d4039a1f14e20bf092d5d0bcead177ca24b/test/subdir/three
if [[ -z $(md5sum three | grep febe6995bad457991331348f7b9c85fa) ]]; then
  echo Fail
  exit 1
fi
rm three

# get file into different destination directory
mkdir different_dir
../github-fetch https://github.com/ben-willmore/github-fetch/blob/b1b69d4039a1f14e20bf092d5d0bcead177ca24b/test/subdir/three ./different_dir
if [[ -z $(md5sum different_dir/three | grep febe6995bad457991331348f7b9c85fa) ]]; then
  echo Fail
  exit 1
fi
rm -r different_dir

# get whole repo
../github-fetch https://github.com/ben-willmore/github-fetch
if [[ -z $(md5sum github-fetch/test/subdir/four | grep 75ffdb827341e578959bfcabde3789d8) ]]; then
  echo Fail
  exit 1
fi
rm -r github-fetch

# get subdir
../github-fetch https://github.com/ben-willmore/github-fetch/tree/main/test
if [[ -z $(md5sum test/subdir/four | grep 75ffdb827341e578959bfcabde3789d8) ]]; then
  echo Fail
  exit 1
fi
rm -r test

# get subdir into different destination directory
mkdir different_dir
../github-fetch https://github.com/ben-willmore/github-fetch/tree/main/test ./different_dir
if [[ -z $(md5sum different_dir/test/subdir/four | grep 75ffdb827341e578959bfcabde3789d8) ]]; then
  echo Fail
  exit 1
fi
rm -r different_dir

# get subdir into different destination directory, using wget
mkdir different_dir
../github-fetch -w https://github.com/ben-willmore/github-fetch/tree/main/test ./different_dir
if [[ -z $(md5sum different_dir/test/subdir/four | grep 75ffdb827341e578959bfcabde3789d8) ]]; then
  echo Fail
  exit 1
fi
rm -r different_dir

cd ..
rm -r github-fetch-test.tmp

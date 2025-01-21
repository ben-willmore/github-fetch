#!/usr/bin/env python3

import string
from os import makedirs
from random import choice

all = ''.join([chr(i) for i in range(32,127)])

for s in '/':
  all = ''.join(all.split(s))

for s in string.ascii_letters+string.digits:
  all = ''.join(all.split(s))

print(len(all))
print(all)

makedirs('./special-chars')

for c in all:
  with open('./special-chars/file-'+c, 'w') as file:
    file.write('file-'+c)

root = './special-chars/dirs'
makedirs(root)

for c in all:
  subdir = root + '/dir-' + c
  makedirs(subdir)
  with open(subdir + "/testfile", 'w') as file:
    file.write('dir-'+c)

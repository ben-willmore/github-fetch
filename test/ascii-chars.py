#!/usr/bin/env python3

import string
from os import makedirs
from random import choice

all = ''.join([chr(i) for i in range(33,128)])

for s in ':?[\^~./':
  all = ''.join(all.split(s))

for s in string.ascii_letters+string.digits:
  all = ''.join(all.split(s))

print(len(all))
print(all)

def randomword(length):
   letters = string.ascii_lowercase
   return ''.join(choice(letters) for i in range(length))

makedirs('./special-chars')

for c in all:
  with open('./special-chars/'+c, 'w') as file:
    file.write(randomword(16))


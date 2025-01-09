#!/usr/bin/env python3

import string

all = ''.join([chr(i) for i in range(33,128)])

for s in ':?[\^~./':
  all = ''.join(all.split(s))

for s in string.ascii_letters+string.digits:
  all = ''.join(all.split(s))

print(len(all))
print(all)

for c in all:
  with open(c, 'w') as file:
    file.write('test')



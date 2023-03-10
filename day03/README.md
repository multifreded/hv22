CSS: ../meta/avenir-white.css

[← Day 02](../day02/) / [↑ TOC](../README.md) / [→ Day 04](../day04/)


# Day 03 / HV22.03 gh0st



## Challenge

* Author: 0xdf
* Tags:   `#crypto`, `#fun`
* Level:  easy

The elves found this Python script that Rudolph wrote for Santa, but it's
behaving very strangely. It shouldn't even run at all, and yet it does! It's
like there's some kind of ghost in the script! Can you figure out what's going
on and recover the flag?

**Resources**

A file download: [gh0st](gh0st.py)



## Solution

The file named `gh0st.py` contained the following python script:

``` python
#!/usr/bin/env python3.7

import random
import sys


if len(sys.argv) != 2:
    print(f'''usage: {sys.argv[0]} flag''')
    sys.exit()
    print('''Things ^@are not^@ what they seem?''')

# only one in a million shall pass
if random.randrange(1000000):
   sys.exit()

# this isn't going to work
print(''')#%^$&*(#$%@^&*(#@!''')
print('''Nice job getting lucky there! But did you get the flag?''')

# Santa only wants every third line!
song =  """You know Dasher, and Dancer, and^@"""
#song += """#Prancer, and Vixen,^@"""
#song += """#Comet, and Cupid, and"""
song += """Donder and Blitzen^@"""
#song += """#But do you recall^@"""
#song += """#The most famous reindeer of all"""
song += """Rudolph, the red-nosed reindeer^@"""
#song += """#had a very shiny nose^@"""
#song += """#and if you ever saw it"""
song += """you would even say it glows.^@"""
#song += """#All of the other reindeer^@"""
#song += """#used to laugh and call him names"""
song += """They never let poor Rudolph^@"""
#song += """#play in any reindeer games.^@"""
#song += """#Then one foggy Christmas eve"""
song += """Santa came to say:^@"""
#song += """    #Rudolph with your nose so bright,^@"""
#song += """    #won't you guide my sleigh tonight?"""
song += """Then all the reindeer loved him^@"""
#song += """#as they shouted out with glee,^@"""
#song += """#Rudolph the red-nosed reindeer,"""
song += """you'll go down in history!"""

flag = list(map(ord, sys.argv[1]))
correct = [17, 55, 18, 92, 91, 10, 38, 8, 76, 127, 17, 12, 17, 2, 20, 49, 3, 4, 16, 8, 3, 58, 67, 60, 10, 66, 31, 95, 1, 93]

for i,c in enumerate(flag):
    flag[i] ^= ord(song[i*10 % len(song)])

if all([c == f for c,f in zip(correct, flag)]):
    print('''Congrats!''')
else:
    print('''Try again!''') 
```

`^@` denotes null bytes at the end of various strings in the file.
Theoretically the python interpreter should trip over these, but the code is
neatly arranged with additional `#`-characters that somehow cancel out the
null bytes (I don't really understand what's happening exactly).

Anyway, the gist of what's happening flag-wise is that the input string in
`sys.argv[1]` should be the flag. Its characters get converted to decimal
numbers and are then XOR'd with every tenth character from the song (wrapping
around at the song's end). The result is the list in the variable `correct`.

XOR is a reversible operation. Therefore it's possible to rewrite the code in
order to feed the end result, i.e. the `correct`-list into the XOR-operation
instead of the flag. This yields the flag characters as numbers.

The code below additionally includes the conversion of the flag numbers back to
ASCII-characters (`chr()`) and add a `print()`-statement to output said
characters ...

``` python
#!/usr/bin/env python3.7

import random
import sys


if len(sys.argv) != 2:
    print(f'''usage: {sys.argv[0]} flag''')
    sys.exit()
    print('''Things ^@are not^@ what they seem?''')

# only one in a million shall pass
if random.randrange(1000000):
   sys.exit()

# this isn't going to work
print(''')#%^$&*(#$%@^&*(#@!''')
print('''Nice job getting lucky there! But did you get the flag?''')

# Santa only wants every third line!
song =  """You know Dasher, and Dancer, and^@"""
#song += """#Prancer, and Vixen,^@"""
#song += """#Comet, and Cupid, and"""
song += """Donder and Blitzen^@"""
#song += """#But do you recall^@"""
#song += """#The most famous reindeer of all"""
song += """Rudolph, the red-nosed reindeer^@"""
#song += """#had a very shiny nose^@"""
#song += """#and if you ever saw it"""
song += """you would even say it glows.^@"""
#song += """#All of the other reindeer^@"""
#song += """#used to laugh and call him names"""
song += """They never let poor Rudolph^@"""
#song += """#play in any reindeer games.^@"""
#song += """#Then one foggy Christmas eve"""
song += """Santa came to say:^@"""
#song += """    #Rudolph with your nose so bright,^@"""
#song += """    #won't you guide my sleigh tonight?"""
song += """Then all the reindeer loved him^@"""
#song += """#as they shouted out with glee,^@"""
#song += """#Rudolph the red-nosed reindeer,"""
song += """you'll go down in history!"""

flag = list(map(ord, sys.argv[1]))
correct = [17, 55, 18, 92, 91, 10, 38, 8, 76, 127, 17, 12, 17, 2, 20, 49, 3, 4, 16, 8, 3, 58, 67, 60, 10, 66, 31, 95, 1, 93]

flag = ""
for i,c in enumerate(correct):
    flag += chr( correct[i] ^ ord(song[i*10 % len(song)]) )

print(flag)
exit()

if all([c == f for c,f in zip(correct, flag)]):
    print('''Congrats!''')
else:
    print('''Try again!''') 
```

--------------------------------------------------------------------------------

Flag: `HV22{nUll_bytes_st0mp_cPy7h0n}`

[← Day 02](../day02/) / [↑ TOC](../README.md) / [→ Day 04](../day04/)

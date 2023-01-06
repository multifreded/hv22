CSS: ../meta/avenir-white.css

[↑ TOC](../README.md) / [→ Hidden 02](../hid02/)

# Hidden 01 / HV22.H1 Santa's Secret



## Challenge

* Tags:   `#fun`
* Level:  easy

_S4nt4444.....s0m3wh3r3 1n th3 34sy ch4ll4ng3sss.....th3r3s 4n 34sy fl4g
h1ddd3333nnnn.....sssshhhhh_

There is no 24h bonus on the hidden challenges!



## Solution

In the `hv22.gcode` file of [the challenge of day 5](../day05/) there was the
following gcode-comment buried somewhere ...

```
;G1 X34.st3r E36 ;)
;G1 X72.86 Y50.50 E123.104
;G1 X49.100 Y100.51 E110.45
;G1 X102.108 Y52.103 E33,125
```

The first line reads `3east3r e36 ;)` i.e. `easter egg ;)`. The numbers of the
following lines are decimal representations of ASCII characters ...

```
72 86 50 50 123 104 49 100 100 51 110 45 102 108 52 103 33 125
```

Converting these decimals to ASCII gives the first hidden flag.

--------------------------------------------------------------------------------

Flag: `HV22{h1dd3n-fl4g!}`

[↑ TOC](../README.md) / [→ Hidden 02](../hid02/)

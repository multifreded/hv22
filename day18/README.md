CSS: ../meta/avenir-white.css

[← Day 17](../day17/) / [↑ TOC](../README.md) / [→ Day 19](../day19/)


# Day 18 / HV22.18 Santa's Nice List



## Challenge

* Author: keep3r
* Tags:   `#crypto`
* Level:  hard

Santa stored this years "Nice List" in an encrypted zip archive. His mind
occupied with christmas madness made him forget the password. Luckily one of the
elves wrote down the SHA-1 hash of the password Santa used.

`xxxxxx69792b677e3e4c7a6d78545c205c4e5e26`

Can you help Santa access the list and make those kids happy?

Download: [nice-list.zip](nice-list.zip)



## Solution

The `nice-list.zip` is an encrypted ZIP archive that contains 2 files:
`flag.txt` and `nice-list-2022.txt` ...

(The capital B in `Bx` denotes that the file is encrypted.)

```sh
$ zipinfo nice-list.zip 
Archive:  nice-list.zip
Zip file size: 554 bytes, number of entries: 2
-rw-------  6.3 unx       65 Bx u099 22-Nov-29 02:23 flag.txt
-rw-------  6.3 unx      110 Bx u099 22-Nov-29 01:55 nice-list-2022.txt
2 files, 175 bytes uncompressed, 188 bytes compressed:  -7.4%
```

It showed in more detail ...

```sh
$ zipinfo -v nice-list.zip
Archive:  nice-list.zip
There is no zipfile comment.

End-of-central-directory record:
-------------------------------

  Zip archive file size:                       554 (000000000000022Ah)
  Actual end-cent-dir record offset:           532 (0000000000000214h)
  Expected end-cent-dir record offset:         532 (0000000000000214h)
  (based on the length of the central directory and its expected offset)

  This zipfile constitutes the sole disk of a single-part archive; its
  central directory contains 2 entries.
  The central directory is 212 (00000000000000D4h) bytes long,
  and its (expected) offset in bytes from the beginning of the zipfile
  is 320 (0000000000000140h).


Central directory entry #1:
---------------------------

  flag.txt

  offset of local header from start of archive:   0
                                                  (0000000000000000h) bytes
  file system or operating system of origin:      Unix
  version of encoding software:                   6.3
  minimum file system compatibility required:     Unix
  minimum software version required to extract:   5.1
  compression method:                             unknown (99)
  file security status:                           encrypted
  extended local header:                          no
  file last modified on (DOS date/time):          2022 Nov 29 02:23:40
  32-bit CRC value (hex):                         00000000
  compressed size:                                93 bytes
  uncompressed size:                              65 bytes
  length of filename:                             8 characters
  length of extra field:                          47 bytes
  length of file comment:                         0 characters
  disk number on which file begins:               disk 1
  apparent file type:                             binary
  Unix file attributes (100600 octal):            -rw-------
  MS-DOS file attributes (20 hex):                arc 

  The central-directory extra field contains:
  - A subfield with ID 0x000a (PKWARE Win32) and 32 data bytes.  The first
    20 are:   00 00 00 00 01 00 18 00 00 e6 e2 80 c3 03 d9 01 00 b6 d6 89.
  - A subfield with ID 0x9901 (unknown) and 7 data bytes:
    02 00 41 45 03 00 00.

  There is a local extra field with ID 0x5855 (old Info-ZIP Unix/OS2/NT) and
  8 data bytes (GMT modification/access times only).

  There is no file comment.

Central directory entry #2:
---------------------------

  There are an extra -44 bytes preceding this file.

  nice-list-2022.txt

  offset of local header from start of archive:   142
                                                  (000000000000008Eh) bytes
  file system or operating system of origin:      Unix
  version of encoding software:                   6.3
  minimum file system compatibility required:     Unix
  minimum software version required to extract:   5.1
  compression method:                             unknown (99)
  file security status:                           encrypted
  extended local header:                          no
  file last modified on (DOS date/time):          2022 Nov 29 01:55:36
  32-bit CRC value (hex):                         00000000
  compressed size:                                119 bytes
  uncompressed size:                              110 bytes
  length of filename:                             18 characters
  length of extra field:                          47 bytes
  length of file comment:                         0 characters
  disk number on which file begins:               disk 1
  apparent file type:                             binary
  Unix file attributes (100600 octal):            -rw-------
  MS-DOS file attributes (20 hex):                arc 

  The central-directory extra field contains:
  - A subfield with ID 0x000a (PKWARE Win32) and 32 data bytes.  The first
    20 are:   00 00 00 00 01 00 18 00 00 e4 24 95 bf 03 d9 01 80 fa bb b7.
  - A subfield with ID 0x9901 (unknown) and 7 data bytes:
    02 00 41 45 03 08 00.

  There is a local extra field with ID 0x5855 (old Info-ZIP Unix/OS2/NT) and
  8 data bytes (GMT modification/access times only).

  There is no file comment.
```

... that it is a `PKWARE` style version `5.1` ZIP archive.

As an already established reoccuring phenomenon of hard challenges, the begining
of this challenge was rocky too. In fact for the first few hours no progress
could be made. The problem: what good is a partially known SHA-1 hash value ?
Even if the value was whole this seeminlgy wouldn't be helpful at all, since it's
not feasible to turn a SHA-1 value back into its password form. There were
multiple attempts and theories:

*  Maybe we're supposed to to find the hash value in existing password lists ?
*  Maybe there is a list of leaked passwords by the name `Nice List` or
   `nice-list.txt` or `nice-list-2022.txt` ?
*  Maybe the file `nice-list-2022.txt` can somehow be recovered so it could be
   used for a known-plaintext-attack ? But what would be the point of the hash
   value then ?
*  ...

But all of this was wrong.

Things took a turn when I started to investigate what PKZIP does to the password
while encrypting data. Especially finding the following paragraph in
[_PKWARE_'s _APPNOTE.TXT_][appnoteTxt]

[appnoteTxt]: https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT

```
7.2.5 Useful Tips

        7.2.5.1 Strong Encryption is always applied to a file after compression. The
        block oriented algorithms all operate in Cypher Block Chaining (CBC) 
        mode.  The block size used for AES encryption is 16.  All other block
        algorithms use a block size of 8.  Two IDs are defined for RC2 to 
        account for a discrepancy found in the implementation of the RC2
        algorithm in the cryptographic library on Windows XP SP1 and all 
        earlier versions of Windows.  It is recommended that zero length files
        not be encrypted, however programs SHOULD be prepared to extract them
        if they are found within a ZIP file.

        7.2.5.2 A pseudo-code representation of the encryption process is as follows:

            Password = GetUserPassword()
            MasterSessionKey = DeriveKey(SHA1(Password)) 
            RD = CryptographicStrengthRandomData() 
            For Each File
               IV = CryptographicStrengthRandomData() 
               VData = CryptographicStrengthRandomData()
               VCRC32 = CRC32(VData)
               FileSessionKey = DeriveKey(SHA1(IV + RD) 
               ErdData = Encrypt(RD,MasterSessionKey,IV) 
               Encrypt(VData + VCRC32 + FileData, FileSessionKey,IV)
            Done

        7.2.5.3 The function names and parameter requirements will depend on
        the choice of the cryptographic toolkit selected.  Almost any
        toolkit supporting the reference implementations for each
        algorithm can be used.  The RSA BSAFE(r), OpenSSL, and Microsoft
        CryptoAPI libraries are all known to work well.
```

It says in this paragraph that producing a `MasterSessionKey` involves feeding
the password through a SHA-1 function as a first step.

Based on this new knowledge, I tried to find a way to use [_hashcat_][hashcat]
for password cracking but having it omit this first step of hashing password
attempts and instead feeding hash values directly. After wasting some time on
this endavour and not being able to accomplish it, I guessed that this was not
possible (at least with the current implementation of hashcat or the likes).

[hashcat]: https://hashcat.net/hashcat/

So I returned to searching the web again, this time specifically regarding the
handling of passwords within PKZIP. And after a while, almost ready to give up,
I found a _Bleeping Computer_ article that sounded very interesting: \
[An encrypted ZIP file can have two correct passwords — here's why][bleeping]

[bleeping]: https://en.wikipedia.org/wiki/PBKDF2

The gist of it: The password derivation function for ZIP-file-encryption is
_PBKDF2_. If a the password is too long (longer than the block size), it will
be SHA-1-hashed and the hash value will be used in its place. This is apparently
part of the [PBKDF2 algorithm when using HMAC][wenPbkdf2HmacColl]. 

[wenPbkdf2HmacColl]: https://en.wikipedia.org/wiki/PBKDF2#HMAC_collisions

So in other words: In this special case the SHA-1 hash value of the password is
the password (when used in ASCII encoded form) `:-)` How cool is that ?

And indeed turning the partial SHA-1 hash value into ASCII gives all printable
characters:

```sh
$ printf '69792b677e3e4c7a6d78545c205c4e5e26' | xxd -p -r; echo
iy+g~>LzmxT\ \N^&
```

So all that's missing are 6 ... no wait 3 characters in front of this string. \
"Off to hashcat then" ...

First the ZIP file needs to be turned into a hash for _hashcat_ to chew on ...

```sh
$ zip2john nice-list.zip
nice-list.zip/flag.txt:$zip2$*0*3*0*e07f14de6a21906d6353fd5f65bcb339*5664*41*e6f2437b18cd6bf346bab9beaa3051feba189a66c8d12b33e6d643c52d7362c9bb674d8626c119cb73146299db399b2f64e3edcfdaab8bc290fcfb9bcaccef695d*40663473539204e3cefd*$/zip2$:flag.txt:nice-list.zip:nice-list.zip
nice-list.zip/nice-list-2022.txt:$zip2$*0*3*0*a53ba8a665f2c94e798835ab626994dd*96cc*5b*72b0a11e9ef17568256695cf580c54400f41cfe0055f1b0800ff91374216313ff9b6dc2c9b1309f9765e3873122d8e422e2d9ecd2c7aa6cbf66105ce837a0fe46c18dc6ccc0cb25f59233c9223d699f43bc2e69c5117b307f813fc*6308b50240b2b882b61e*$/zip2$:nice-list-2022.txt:nice-list.zip:nice-list.zip

$ zip2john nice-list.zip > hash.txt
```

One of the output's lines is sufficient. Also the filename parts must to be
trimmed off manually. It then looked like this ...

```sh
$ cat hash.txt 
$zip2$*0*3*0*e07f14de6a21906d6353fd5f65bcb339*5664*41*e6f2437b18cd6bf346bab9beaa3051feba189a66c8d12b33e6d643c52d7362c9bb674d8626c119cb73146299db399b2f64e3edcfdaab8bc290fcfb9bcaccef695d*40663473539204e3cefd*$/zip2$
```

Then a _mask_ and _custom charset_ had to be created to have _hashcat_ try
different combinations of printable characters in front of the partial
SHA-1-ASCII-string (See [_hashcat_-Wiki: Masks][hcWikiMasks] for details) ...

[hcWikiMasks]: https://hashcat.net/wiki/doku.php?id=mask_attack#masks

```
-1 '?l?d?s?u' '?1?1?1iy+g~>LzmxT\ \N^&'
```

and lastly the correct hash mode had to by identified ...

```sh
$ hashcat --identify hash.txt
The following hash-mode match the structure of your input hash:

      # | Name                            | Category
  ======+=================================+===================================
  13600 | WinZip                          | Archive
```

Finally everything was ready for cracking the freaky SHA-1-ASCII-password ...

```sh
$ hashcat -a 3 -m 13600 hash.txt -1 '?l?d?s?u' '?1?1?1iy+g~>LzmxT\ \N^&'
hashcat (v6.2.6) starting

OpenCL API (OpenCL 3.0 PoCL 3.0+debian  Linux, None+Asserts, RELOC, LLVM 13.0.1, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
============================================================================================================================================
* Device #1: pthread-Intel(R) Core(TM) i5-8265U CPU @ 1.60GHz, 1441/2947 MB (512 MB allocatable), 2MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Optimizers applied:
* Zero-Byte
* Single-Hash
* Single-Salt
* Brute-Force
* Slow-Hash-SIMD-LOOP

Watchdog: Temperature abort trigger set to 90c

Host memory required for this attack: 0 MB

Cracking performance lower than expected?                 

* Append -w 3 to the commandline.
  This can cause your screen to lag.

* Append -S to the commandline.
  This has a drastic speed impact but can be better for specific attacks.
  Typical scenarios are a small wordlist but a large ruleset.

* Update your backend API runtime / driver the right way:
  https://hashcat.net/faq/wrongdriver

* Create more work items to make use of your parallelization power:
  https://hashcat.net/faq/morework

$zip2$*0*3*0*e07f14de6a21906d6353fd5f65bcb339*5664*41*e6f2437b18cd6bf346bab9beaa3051feba189a66c8d12b33e6d643c52d7362c9bb674d8626c119cb73146299db399b2f64e3edcfdaab8bc290fcfb9bcaccef695d*40663473539204e3cefd*$/zip2$:4Ltiy+g~>LzmxT\ \N^&
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 13600 (WinZip)
Hash.Target......: $zip2$*0*3*0*e07f14de6a21906d6353fd5f65bcb339*5664*.../zip2$
Time.Started.....: Sun Dec 18 06:04:18 2022 (21 secs)
Time.Estimated...: Sun Dec 18 06:04:39 2022 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Mask.......: ?1?1?1iy+g~>LzmxT\ \N^& [20]
Guess.Charset....: -1 ?l?d?s?u, -2 Undefined, -3 Undefined, -4 Undefined 
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:    23612 H/s (10.27ms) @ Accel:128 Loops:999 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 493056/857375 (57.51%)
Rejected.........: 0/493056 (0.00%)
Restore.Point....: 5120/9025 (56.73%)
Restore.Sub.#1...: Salt:0 Amplifier:25-26 Iteration:0-999
Candidate.Engine.: Device Generator
Candidates.#1....: 4%=iy+g~>LzmxT\ \N^& -> 4Ppiy+g~>LzmxT\ \N^&
Hardware.Mon.#1..: Util: 97%

Started: Sun Dec 18 06:04:16 2022
Stopped: Sun Dec 18 06:04:40 2022

$ printf '4Ltiy+g~>LzmxT\ \N^&' > password.txt
```

The files from the ZIP archive could be unpacked now ...

```sh
$ 7z e -p"$(cat ../password.txt)" nice-list.zip 

7-Zip [64] 17.04 : Copyright (c) 1999-2021 Igor Pavlov : 2017-08-28
p7zip Version 17.04 (locale=utf8,Utf16=on,HugeFiles=on,64 bits,8 CPUs x64)

Scanning the drive for archives:
1 file, 554 bytes (1 KiB)

Extracting archive: nice-list.zip
--
Path = nice-list.zip
Type = zip
Physical Size = 554

Everything is Ok

Files: 2
Size:       175
Compressed: 554

$ cat flag.txt
HV22{HAVING_FUN_WITH_CHOSEN_PREFIX_PBKDF2_HMAC_COLLISIONS_nzvwuj}
```

There was a fun aspect to this. The other file in the ZIP archive - 
`nice-list-2022.txt` - contained the top 10 ranking from the day before ...

```sh
$ cat nice-list-2022.txt
darkice
explo1t
darkstar
drschottky
smartsmurf
keep3r
0xi
mcia
jokker
logicaloverflow
engycz
daubsi
```

`:-D`

--------------------------------------------------------------------------------

Flag: `HV22{HAVING_FUN_WITH_CHOSEN_PREFIX_PBKDF2_HMAC_COLLISIONS_nzvwuj}`

[← Day 17](../day17/) / [↑ TOC](../README.md) / [→ Day 19](../day19/)

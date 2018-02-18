# Terafoo - Sined Distance Functions

https://terafoo.bandcamp.com

## How to run

These scripts can be run as-is with Sonic PI 2.10.
See http://sonic-pi.net for downloads.

Most of the files were written using Sonic Pi 2.10 running on Windows,
with the exception of "Land of the Brie" (Sonic Pi 2.09 on Linux).
Some post processing was done using Audacity, in order to achieve
similar volume and compression and to trim off edges.
Depending on your machine, Sonic Pi version, etc. the songs might
sound slightly different when re-running the script.

### samples_base
Most files contain a `samples_base` variable that needs to be set to the
location of the `samples` directory (and end in a forward slash).

### Limitations
There is a Bug in Sonic Pi 2.10 that won't let you run very large files.
Depending on your architecture and maximum packet size, you might not
be able to play some of the larger songs (Cabbage Engine, Cubeshackles).
In order to still play them, you can cut and paste some functions into
a separate buffer and run that buffer first before running the song.

A Raspberry Pi might be too weak to run most of this. I ran it on an
AMD Phenom II X6 1090T and had some problems in the more sample intensive
parts.

Finally, the code is not the most organized - it's the result of a
creative process after all :)

Enjoy! \m/

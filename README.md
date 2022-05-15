# How to use #

The program will use by default /dev/ttyUSB0.
The speed is fixed at 115200.
To use another port, specify it on the command line, e.g.

./brndumper --port=/dev/ttyS0

if you are using the windows binary:

brndumper.exe --port=\\.\com1

Before starting the program, make sure that the router is in the brn-boot administrator menu using a terminal emulation program (e.g. minicom):

```
ROM VER: 1.0.3
CFG 01
Read
ROM VER: 1.0.3
CFG 01
Read EEPROMX
 X



=======================================================================
Wireless ADSL Gateway DANUBE Loader 64M-V0.02 build Apr 24 2008 16:12:25
                    Arcadyan Technology Corporation
=======================================================================
MXIC MX29LV320ABTC bottom boot 16-bit mode found

Copying boot params.....DONE


Press Space Bar 3 times to enter command mode ...123
Yes, Enter command mode ...


[DANUBE Boot]:!

Enter Administrator Mode !

======================
 [u] Upload to Flash  
 [E] Erase Flash      
 [G] Run Runtime Code 
 [M] Upload to Memory 
 [R] Read from Memory 
 [W] Write to Memory  
 [T] Memory Test      
 [Y] Go to Memory     
 [A] Set MAC Address 
 [#] Set Serial Number 
 [V] Set Board Version 
 [H] Set Options 
 [P] Print Boot Params 
 [0] Use Normal Firmware
 [1] Use ART-Testing Firmware
======================

[DANUBE Boot]:
```

then start the program, write the start and end address (with $ prefix if you want to use hexadecimal) and press the "Dump" button. You will be prompted to select a file to dump to.

You can also send commands to the router entering them in the text entry box and pressing "Send"

# How to compile #

You'll need [lazarus 0.9.30](http://lazarus.freepascal.org), [ararat synapse and synaser](http://www.ararat.cz/synapse/).
Unzip synapse and synaser somewhere, put the source files (source/lib for synapse and source for synaser) in the same directory as well as the supplied synapse.lpk file.
From lazarus, "open package file", find synapse.lpk, press "Compile".
Then you can open, modify and compile brndumper.lpi.
A simpler way is to put synaser sources in the same directory as this project then, in lazarus, remove the dependency on synapse (I use the "complex" way since I use synapse/synaser in most of my projects, so it's actually more convenient).

I provide a  [windows binary](https://drive.google.com/file/d/0BwPmW2whNqGlMzl2d1dKeEhqR1k/view?usp=sharing&resourcekey=0-44neBS8mQccsRMgSZrnyGQ), I didn't test it with the router but it should work.
